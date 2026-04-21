import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  static final SpeechToTextService _instance = SpeechToTextService._internal();
  factory SpeechToTextService() => _instance;
  SpeechToTextService._internal();

  SpeechToText? _speech;
  bool _isInitialized = false;
  bool _isListening = false;

  // 语音识别状态回调
  Function(String)? onResult;
  Function(String)? onError;
  Function(bool)? onListeningStateChanged;
  Function(double)? onSoundLevelChanged;

  // 初始化语音识别
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // 初始化前先确保语音相关权限齐全（麦克风 + 语音识别）
      final granted = await requestPermission();
      if (!granted) {
        onError?.call('语音输入权限未授权');
        return false;
      }

      // 初始化语音识别
      _speech = SpeechToText();
      bool isAvailable = await _speech!.initialize(
        onError: (error) {
          debugPrint('语音识别错误: $error');
          onError?.call(error.errorMsg);
        },
        onStatus: (status) {
          debugPrint('语音状态: $status');
          _isListening = status == 'listening';
          onListeningStateChanged?.call(_isListening);
        },
      );

      if (!isAvailable) {
        onError?.call('语音识别不可用');
        return false;
      }

      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('语音识别初始化失败: $e');
      onError?.call('语音识别初始化失败: $e');
      return false;
    }
  }

  // 开始语音识别
  Future<void> startListening({
    String? localeId,
    Duration pauseFor = const Duration(seconds: 3),
    Duration listenFor = const Duration(seconds: 30),
    bool partialResults = true,
  }) async {
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return;
    }

    if (_isListening) {
      debugPrint('已经在录音中');
      return;
    }

    try {
      await _speech!.listen(
        onResult: (result) {
          debugPrint('语音识别结果: ${result.recognizedWords}');
          onResult?.call(result.recognizedWords);
        },
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: partialResults,
        localeId: localeId ?? 'zh_CN',
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );
    } catch (e) {
      debugPrint('开始录音失败: $e');
      onError?.call('开始录音失败: $e');
    }
  }

  // 停止语音识别
  Future<void> stopListening() async {
    if (_speech != null && _isListening) {
      await _speech!.stop();
    }
  }

  // 取消语音识别
  Future<void> cancelListening() async {
    if (_speech != null && _isListening) {
      await _speech!.cancel();
    }
  }

  // 获取当前状态
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  // 获取可用语言列表
  Future<List<LocaleName>?> getAvailableLanguages() async {
    if (!_isInitialized) {
      await initialize();
    }
    return await _speech?.locales();
  }

  // 释放资源
  void dispose() {
    _speech?.cancel();
    _speech = null;
    _isInitialized = false;
    _isListening = false;
  }

  // 检查权限
  Future<bool> checkPermission() async {
    final micGranted = (await Permission.microphone.status).isGranted;
    bool speechGranted = true;
    try {
      speechGranted = (await Permission.speech.status).isGranted;
    } catch (_) {
      // 某些平台没有独立语音识别权限，默认按已满足处理
      speechGranted = true;
    }
    return micGranted && speechGranted;
  }

  // 请求权限
  Future<bool> requestPermission() async {
    var micStatus = await Permission.microphone.request();
    if (micStatus.isDenied) {
      // 权限被拒绝，尝试再次请求
      micStatus = await Permission.microphone.request();
    }

    if (micStatus.isPermanentlyDenied) {
      // 权限被永久拒绝，跳转到设置页面
      await openAppSettings();
      return false;
    }

    if (!micStatus.isGranted) {
      return false;
    }

    // iOS 等平台可能还需要语音识别权限；不支持的平台会抛异常，直接忽略
    try {
      var speechStatus = await Permission.speech.request();
      if (speechStatus.isDenied) {
        speechStatus = await Permission.speech.request();
      }
      if (speechStatus.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      if (!speechStatus.isGranted) {
        return false;
      }
    } catch (_) {
      // 平台不支持独立语音权限时，忽略该步骤
    }

    return true;
  }

  // 获取权限诊断信息
  Future<Map<String, String>> getPermissionDiagnostics() async {
    final micStatus = await Permission.microphone.status;
    String speechStatusText = 'not_supported';

    try {
      final speechStatus = await Permission.speech.status;
      speechStatusText = _statusToText(speechStatus);
    } catch (_) {
      speechStatusText = 'not_supported';
    }

    return {
      'microphone': _statusToText(micStatus),
      'speech': speechStatusText,
      'allGranted': (await checkPermission()).toString(),
    };
  }

  String _statusToText(PermissionStatus status) {
    if (status.isGranted) return 'granted';
    if (status.isDenied) return 'denied';
    if (status.isPermanentlyDenied) return 'permanentlyDenied';
    if (status.isRestricted) return 'restricted';
    if (status.isLimited) return 'limited';
    if (status.isProvisional) return 'provisional';
    return status.toString();
  }

  // 跳转到应用设置页面
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}