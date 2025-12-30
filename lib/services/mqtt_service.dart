import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:zenify/services/service_config.dart';
import 'package:zenify/services/user_session.dart';

/// MQTT 服务类
/// 用于接收服务端推送的识别结果
class MQTTService {
  static final MQTTService _instance = MQTTService._internal();
  factory MQTTService() => _instance;
  MQTTService._internal();

  MqttServerClient? _client;
  final List<void Function(String topic, dynamic message)> _listeners = [];

  /// 识别状态变化回调
  final StreamController<RecognitionStatus> _statusController =
      StreamController<RecognitionStatus>.broadcast();

  Stream<RecognitionStatus> get statusStream => _statusController.stream;

  /// 连接状态
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  /// 连接 MQTT 服务器
  Future<void> connect() async {
    if (_client != null &&
        _client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT already connected');
      return;
    }

    try {
      final userId = await UserSession.userId;
      if (userId == null) {
        print('User ID not available');
        return;
      }

      // 创建客户端
      _client = MqttServerClient(
        ApiConfig.mqttBrokerAddress,
        'zenify_client_$userId',
      );

      // 设置连接回调
      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onUnsubscribed = _onUnsubscribed;
      _client!.onSubscribed = _onSubscribed;
      _client!.onSubscribeFail = _onSubscribeFail;

      // 设置协议版本为 MQTT 3.1.1
      _client!.logging(on: false);
      _client!.keepAlivePeriod = 30;
      _client!.setProtocolV311();
      final connMess = MqttConnectMessage()
          .withClientIdentifier('zenify_client_$userId')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);
      _client!.connectionMessage = connMess;

      // 连接
      print('Connecting to MQTT broker...');
      await _client!.connect();
    } catch (e) {
      print('MQTT connection error: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// 连接成功回调
  void _onConnected() {
    print('MQTT connected');
    _isConnected = true;
    _subscribeToUserTopics();
  }

  /// 订阅用户相关的主题
  Future<void> _subscribeToUserTopics() async {
    final userId = await UserSession.userId;
    if (userId == null) return;

    // 订阅识别通知主题
    final topics = [
      'user/$userId/recognition_started',
      'user/$userId/recognition_completed',
      'device/+/user/$userId/user_session/+/recognize',
    ];

    for (var topic in topics) {
      print('Subscribing to: $topic');
      _client!.subscribe(topic, MqttQos.atMostOnce);
    }

    // 监听消息
    _client!.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String topic = c[0].topic;
      final String payload =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print('Received message on topic: $topic');
      print('Payload: $payload');

      _handleMessage(topic, payload);
    });
  }

  /// 处理接收到的消息
  void _handleMessage(String topic, String payload) {
    try {
      final data = jsonDecode(payload);

      // 识别开始通知
      if (topic.contains('/recognition_started')) {
        _statusController.add(RecognitionStatus(
          sessionId: '',
          status: RecognitionStatusType.analyzing,
          data: null,
        ));
      }
      // 识别完成通知
      else if (topic.contains('/recognition_completed')) {
        _statusController.add(RecognitionStatus(
          sessionId: '',
          status: RecognitionStatusType.completed,
          data: data,
        ));
      }
      // 识别结果
      else if (topic.endsWith('/recognize')) {
        final topicParts = topic.split('/');
        final sessionIndex = topicParts.indexOf('user_session');
        if (sessionIndex != -1 && sessionIndex + 1 < topicParts.length) {
          final sessionId = topicParts[sessionIndex + 1];
          _statusController.add(RecognitionStatus(
            sessionId: sessionId,
            status: RecognitionStatusType.completed,
            data: data,
          ));
        }
      }
    } catch (e) {
      print('Error handling MQTT message: $e');
    }
  }

  /// 断开连接回调
  void _onDisconnected() {
    print('MQTT disconnected');
    _isConnected = false;
  }

  /// 订阅成功回调
  void _onSubscribed(String topic) {
    print('Subscribed to: $topic');
  }

  /// 取消订阅回调
  void _onUnsubscribed(String? topic) {
    print('Unsubscribed from: $topic');
  }

  /// 订阅失败回调
  void _onSubscribeFail(String topic) {
    print('Failed to subscribe to: $topic');
  }

  /// 断开连接
  Future<void> disconnect() async {
    _client?.disconnect();
    _isConnected = false;
    await _statusController.close();
  }

  /// 添加监听器
  void addListener(void Function(String, dynamic) listener) {
    _listeners.add(listener);
  }

  /// 移除监听器
  void removeListener(void Function(String, dynamic) listener) {
    _listeners.remove(listener);
  }
}

/// 识别状态类型
enum RecognitionStatusType {
  analyzing, // 分析中
  completed, // 完成
}

/// 识别状态数据模型
class RecognitionStatus {
  final String sessionId;
  final RecognitionStatusType status;
  final dynamic data;

  RecognitionStatus({
    required this.sessionId,
    required this.status,
    required this.data,
  });
}
