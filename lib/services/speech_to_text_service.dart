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
      // 请求麦克风权限
      var micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        onError?.call('麦克风权限被拒绝');
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
    var status = await Permission.microphone.status;
    return status.isGranted;
  }

  // 请求权限
  Future<bool> requestPermission() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }
}