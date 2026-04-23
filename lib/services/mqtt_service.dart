import 'dart:async';
import 'dart:math' as math;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:zenify/core/app_logger.dart';
import 'package:zenify/services/service_config.dart';
import 'package:zenify/services/user_session.dart';

enum MQTTConnectionStateView {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

class MQTTConnectionStatus {
  final MQTTConnectionStateView state;
  final String message;
  final int retryAttempt;

  const MQTTConnectionStatus({
    required this.state,
    required this.message,
    this.retryAttempt = 0,
  });
}

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();
  factory MQTTService() => _instance;
  MQTTService._internal();

  static const int _maxReconnectAttempts = 5;

  MqttServerClient? _client;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _manualDisconnect = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>?
      _updatesSubscription;
  bool get isConnected => _isConnected;

  /// 识别状态流 - 保持单例
  final StreamController<RecognitionStatus> _statusController =
      StreamController<RecognitionStatus>.broadcast();
  Stream<RecognitionStatus> get statusStream => _statusController.stream;

  final StreamController<MQTTConnectionStatus> _connectionStatusController =
      StreamController<MQTTConnectionStatus>.broadcast();
  Stream<MQTTConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  /// 主连接方法 - 逻辑更清晰
  Future<bool> connect({bool isReconnect = false}) async {
    // 防止重复连接
    if (_isConnected &&
        _client?.connectionStatus?.state == MqttConnectionState.connected) {
      AppLogger.info('MQTT 已经连接，跳过本次连接请求。');
      return true;
    }
    if (_isConnecting) {
      AppLogger.info('MQTT 正在连接中，跳过重复请求。');
      return false;
    }

    _manualDisconnect = false;
    _isConnecting = true;
    _emitConnectionStatus(
      isReconnect
          ? MQTTConnectionStateView.reconnecting
          : MQTTConnectionStateView.connecting,
      isReconnect ? 'MQTT 重连中...' : 'MQTT 连接中...',
      retryAttempt: _reconnectAttempts,
    );

    _reconnectTimer?.cancel();
    // 清理旧连接
    await _safeDisconnect();

    try {
      final userId = await UserSession.userId;
      if (userId == null) {
        AppLogger.error('无法连接：用户ID为空。');
        _emitConnectionStatus(
            MQTTConnectionStateView.failed, 'MQTT 连接失败：用户ID为空');
        _isConnecting = false;
        return false;
      }

      // 1. 生成唯一的客户端ID，避免连接冲突
      final randomSuffix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final clientId = 'zenify_${userId}_$randomSuffix';
      AppLogger.info('开始 MQTT 连接，Client ID: $clientId');

      // 2. 创建并配置客户端
      _client = MqttServerClient(ApiConfig.mqttBrokerAddress, clientId);
      _client!.port = ApiConfig.mqttPort;
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 30; // 降低 keepAlive 周期
      _client!.setProtocolV311();

      // 3. 【关键修复】正确设置回调，确保业务逻辑能被触发
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;

      // 4. 设置连接消息
      final connMess = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean() // 清除之前的会话状态
          .withWillQos(MqttQos.atMostOnce);

      _client!.connectionMessage = connMess;

      // 5. 开始连接
      AppLogger.info(
          '🔗 正在连接至 ${ApiConfig.mqttBrokerAddress}:${ApiConfig.mqttPort} ...');
      await _client!.connect();
      final state = _client?.connectionStatus?.state;
      if (state != MqttConnectionState.connected) {
        throw Exception('连接状态异常: $state');
      }

      // 6. 连接成功，_onConnected 回调会被自动调用，_isConnected 将在其中被设为 true
      _isConnecting = false;
      return true;
    } catch (e) {
      AppLogger.error('MQTT 连接失败: $e');
      _isConnected = false;
      _isConnecting = false;
      if (!_manualDisconnect) {
        _scheduleReconnect();
      } else {
        _emitConnectionStatus(MQTTConnectionStateView.failed, 'MQTT 连接失败：$e');
      }
      return false;
    }
  }

  /// 连接成功回调 - 现在能正确被调用了
  void _onConnected() {
    AppLogger.info('MQTT 连接成功');
    _isConnected = true;
    _isConnecting = false;
    _reconnectAttempts = 0;
    _emitConnectionStatus(MQTTConnectionStateView.connected, 'MQTT 已连接');
    _setupMessageListener(); // 先设置消息监听
    _subscribeToUserTopics(); // 再订阅主题
  }

  /// 设置消息监听器
  void _setupMessageListener() {
    // 防御性判断，避免空指针
    _updatesSubscription?.cancel();
    _updatesSubscription = _client?.updates?.listen(
        (List<MqttReceivedMessage<MqttMessage>> messages) {
      for (var message in messages) {
        final payload = message.payload;
        if (payload is MqttPublishMessage) {
          final topic = message.topic;
          final payloadStr =
              MqttPublishPayload.bytesToStringAsString(payload.payload.message);
          AppLogger.info('收到消息 [主题: $topic]');
          _handleIncomingMessage(topic, payloadStr);
        }
      }
    }, onError: (error) {
      AppLogger.warning('消息监听出错: $error');
    });
  }

  /// 订阅用户主题
  Future<void> _subscribeToUserTopics() async {
    final userId = await UserSession.userId;
    if (userId == null || _client == null) {
      AppLogger.warning('无法订阅：用户ID为空或客户端未初始化。');
      return;
    }

    final topics = [
      'user/$userId/recognition_started',
      'user/$userId/recognition_completed',
    ];

    AppLogger.info('开始订阅用户主题');
    for (var topic in topics) {
      try {
        // QoS 根据实际需求选择，如果消息可丢失用 atMostOnce (0)，需要确保接收用 atLeastOnce (1)
        _client!.subscribe(topic, MqttQos.atLeastOnce);
        AppLogger.info('已订阅: $topic');
      } catch (e) {
        AppLogger.error('订阅失败 [$topic]: $e');
      }
    }
  }

  /// 处理收到的消息 - 逻辑优化
  void _handleIncomingMessage(String topic, String payload) {
    try {
      // final data = jsonDecode(payload);

      if (topic.contains('/recognition_started')) {
        _statusController.add(RecognitionStatus(
          status: RecognitionStatusType.analyzing,
        ));
        AppLogger.info('识别开始通知已处理。');
      } else if (topic.contains('/recognition_completed')) {
        _statusController.add(RecognitionStatus(
          status: RecognitionStatusType.completed,
        ));
        AppLogger.info('识别完成通知已处理。');
      } else {
        AppLogger.info('收到未明确处理的主题消息: $topic');
      }
    } catch (e) {
      AppLogger.error('处理 MQTT 消息出错 (主题: $topic): $e');
      AppLogger.warning('原始负载: $payload');
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    await _safeDisconnect();
    _emitConnectionStatus(MQTTConnectionStateView.disconnected, 'MQTT 已断开');
    AppLogger.info('MQTT 连接已主动断开。');
  }

  /// 安全断开连接，内部复用
  Future<void> _safeDisconnect() async {
    _isConnected = false;
    try {
      await _updatesSubscription?.cancel();
      _updatesSubscription = null;
      _client?.disconnect();
      _client = null; // 释放引用
    } catch (e) {
      AppLogger.warning('断开连接异常: $e');
    } finally {
      // 注意：不要在这里关闭 _statusController，除非服务完全销毁
      // 因为 statusStream 可能被多处监听
    }
  }

  // --- 原有的回调方法 (可根据需要精简或使用日志库) ---
  void _onDisconnected() {
    AppLogger.warning('MQTT 连接断开。');
    _isConnected = false;
    _emitConnectionStatus(MQTTConnectionStateView.disconnected, 'MQTT 连接断开');
    if (!_manualDisconnect) {
      _scheduleReconnect();
    }
  }

  void _onSubscribed(String topic) {
    // 可选详细日志
    // print('订阅确认: $topic');
  }

  void _emitConnectionStatus(
    MQTTConnectionStateView state,
    String message, {
    int retryAttempt = 0,
  }) {
    _connectionStatusController.add(
      MQTTConnectionStatus(
        state: state,
        message: message,
        retryAttempt: retryAttempt,
      ),
    );
  }

  void _scheduleReconnect() {
    if (_manualDisconnect) {
      return;
    }
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _emitConnectionStatus(
        MQTTConnectionStateView.failed,
        'MQTT 重连失败，请检查网络后重试',
        retryAttempt: _reconnectAttempts,
      );
      return;
    }

    _reconnectAttempts += 1;
    final delaySeconds = math.min(math.pow(2, _reconnectAttempts).toInt(), 30);
    _emitConnectionStatus(
      MQTTConnectionStateView.reconnecting,
      'MQTT 连接中断，${delaySeconds}s 后重试',
      retryAttempt: _reconnectAttempts,
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      connect(isReconnect: true);
    });
  }
}

/// 识别状态类型与数据模型 (保持不变)
enum RecognitionStatusType { analyzing, completed }

class RecognitionStatus {
  final RecognitionStatusType status;
  RecognitionStatus({required this.status});
}
