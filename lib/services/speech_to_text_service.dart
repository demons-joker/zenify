import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  static final SpeechToTextService _instance = SpeechToTextService._internal();
  factory SpeechToTextService() => _instance;
  SpeechToTextService._internal();

  SpeechToText? _speech;
  static const MethodChannel _androidSpeechChannel =
      MethodChannel('zenify/speech_recognition');
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isRetryingOnDevice = false;
  bool _isRecoveringRecognizer = false;
  bool _androidHandlerAttached = false;
  String? _lastError;
  _SpeechListenRequest? _lastListenRequest;

  bool get _usesNativeAndroidSpeech {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android;
  }

  bool get _needsSpeechPermission {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  // 语音识别状态回调
  Function(String)? onResult;
  Function(String)? onError;
  Function(bool)? onListeningStateChanged;
  Function(double)? onSoundLevelChanged;

  // 初始化语音识别
  Future<bool> initialize({bool requestIfNeeded = true}) async {
    if (_isInitialized) return true;

    try {
      final hasPermission =
          requestIfNeeded ? await requestPermission() : await checkPermission();
      if (!hasPermission) {
        _emitError('麦克风权限未开启');
        return false;
      }

      if (_usesNativeAndroidSpeech) {
        _ensureAndroidSpeechHandler();
        final isAvailable =
            await _androidSpeechChannel.invokeMethod<bool>('initialize') ??
                false;
        if (!isAvailable) {
          _emitError('Android 系统语音识别服务不可用');
          return false;
        }

        _isInitialized = true;
        _lastError = null;
        return true;
      }

      // 初始化语音识别
      _speech ??= SpeechToText();
      bool isAvailable = await _speech!.initialize(
        onError: (error) {
          debugPrint('语音识别错误: $error');
          if (_shouldRecoverRecognizer(error.errorMsg)) {
            _recoverRecognizerAndRetry();
            return;
          }
          if (_shouldRetryOnDevice(error.errorMsg)) {
            _retryWithOnDeviceRecognizer();
            return;
          }
          _emitError(error.errorMsg);
        },
        onStatus: (status) {
          debugPrint('语音状态: $status');
          _isListening = status == 'listening';
          onListeningStateChanged?.call(_isListening);
        },
        // Android 上禁用蓝牙路径，避免因蓝牙相关权限导致误判为语音权限错误
        options: defaultTargetPlatform == TargetPlatform.android
            ? [
                SpeechToText.androidNoBluetooth,
                SpeechToText.androidIntentLookup,
              ]
            : null,
      );

      if (!isAvailable) {
        _speech = null;
        _emitError('语音识别不可用');
        return false;
      }

      _isInitialized = true;
      _lastError = null;
      return true;
    } catch (e) {
      debugPrint('语音识别初始化失败: $e');
      _speech = null;
      _isInitialized = false;
      _emitError('语音识别初始化失败: $e');
      return false;
    }
  }

  // 开始语音识别
  Future<bool> startListening({
    String? localeId,
    Duration pauseFor = const Duration(seconds: 3),
    Duration listenFor = const Duration(seconds: 30),
    bool partialResults = true,
  }) async {
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return false;
    }

    if (_isListening) {
      debugPrint('已经在录音中');
      return true;
    }

    try {
      final request = _SpeechListenRequest(
        localeId: localeId,
        pauseFor: pauseFor,
        listenFor: listenFor,
        partialResults: partialResults,
      );
      _isRetryingOnDevice = false;
      _lastListenRequest = request;
      _lastError = null;

      if (_usesNativeAndroidSpeech) {
        return await _startNativeAndroidListening(request);
      }

      await _listen(request);
      return true;
    } catch (e) {
      debugPrint('开始录音失败: $e');
      _emitError('开始录音失败: $e');
      return false;
    }
  }

  Future<void> _listen(
    _SpeechListenRequest request, {
    bool onDevice = false,
  }) async {
    await _speech!.listen(
      onResult: (result) {
        debugPrint('语音识别结果: ${result.recognizedWords}');
        _lastError = null;
        onResult?.call(result.recognizedWords);
      },
      listenFor: request.listenFor,
      pauseFor: request.pauseFor,
      localeId: request.localeId ?? 'zh_CN',
      onSoundLevelChange: onSoundLevelChanged == null
          ? null
          : (level) => onSoundLevelChanged?.call(level),
      listenOptions: SpeechListenOptions(
        cancelOnError: true,
        partialResults: request.partialResults,
        onDevice: onDevice,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  // 停止语音识别
  Future<void> stopListening() async {
    if (_usesNativeAndroidSpeech) {
      await _androidSpeechChannel.invokeMethod<bool>('stopListening');
      return;
    }

    if (_speech != null && _isListening) {
      await _speech!.stop();
    }
  }

  // 取消语音识别
  Future<void> cancelListening() async {
    if (_usesNativeAndroidSpeech) {
      await _androidSpeechChannel.invokeMethod<bool>('cancelListening');
      return;
    }

    if (_speech != null && _isListening) {
      await _speech!.cancel();
    }
  }

  // 获取当前状态
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;

  // 获取可用语言列表
  Future<List<LocaleName>?> getAvailableLanguages() async {
    if (_usesNativeAndroidSpeech) return null;

    if (!_isInitialized) {
      await initialize();
    }
    return await _speech?.locales();
  }

  // 释放资源
  void dispose() {
    if (_usesNativeAndroidSpeech) {
      unawaited(_androidSpeechChannel.invokeMethod<bool>('dispose'));
    }
    _speech?.cancel();
    _speech = null;
    _isInitialized = false;
    _isListening = false;
    _isRetryingOnDevice = false;
    _isRecoveringRecognizer = false;
    _lastListenRequest = null;
  }

  // 检查权限
  Future<bool> checkPermission() async {
    final micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) return false;
    if (!_needsSpeechPermission) return true;
    final speechStatus = await Permission.speech.status;
    return speechStatus.isGranted;
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
    if (!micStatus.isGranted) return false;

    if (!_needsSpeechPermission) {
      return true;
    }

    var speechStatus = await Permission.speech.request();
    if (speechStatus.isDenied) {
      speechStatus = await Permission.speech.request();
    }
    if (speechStatus.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return speechStatus.isGranted;
  }

  // 跳转到应用设置页面
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  // 获取权限诊断信息，供页面展示详细状态
  Future<Map<String, String>> getPermissionDiagnostics() async {
    final micStatus = await Permission.microphone.status;
    final speechStatus =
        _needsSpeechPermission ? await Permission.speech.status : null;
    final appPermissionsGranted = micStatus.isGranted &&
        (!_needsSpeechPermission || speechStatus!.isGranted);
    final recognizerPermissionError = _isRecognizerPermissionError(_lastError);
    final recognizerServiceError = _isRecognizerServiceError(_lastError);
    final allGranted = appPermissionsGranted &&
        !recognizerPermissionError &&
        !recognizerServiceError;

    return {
      'microphone': micStatus.name,
      'speech': speechStatus?.name ?? 'notRequired',
      'appPermissionsGranted': appPermissionsGranted.toString(),
      'recognizerPermissionError': recognizerPermissionError.toString(),
      'recognizerServiceError': recognizerServiceError.toString(),
      'allGranted': allGranted.toString(),
      'platform': defaultTargetPlatform.name,
      'initialized': _isInitialized.toString(),
      'lastError': _lastError ?? '',
    };
  }

  void _emitError(String message) {
    _lastError = message;
    onError?.call(message);
  }

  bool _shouldRetryOnDevice(String message) {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    if (_isRetryingOnDevice) return false;
    if (_isRecoveringRecognizer) return false;
    if (_lastListenRequest == null) return false;

    final lower = message.toLowerCase();
    return _isRecognizerPermissionError(lower);
  }

  bool _shouldRecoverRecognizer(String message) {
    if (defaultTargetPlatform != TargetPlatform.android) return false;
    if (_isRecoveringRecognizer) return false;
    if (_lastListenRequest == null) return false;

    final lower = message.toLowerCase();
    return _isRecognizerServiceError(lower);
  }

  bool _isRecognizerPermissionError(String? message) {
    if (message == null || message.isEmpty) return false;
    final lower = message.toLowerCase();
    return lower.contains('error_permission') ||
        lower.contains('permission') ||
        lower.contains('权限');
  }

  bool _isRecognizerServiceError(String? message) {
    if (message == null || message.isEmpty) return false;
    final lower = message.toLowerCase();
    return lower.contains('error_server_disconnected') ||
        lower.contains('error_server') ||
        lower.contains('error_client') ||
        lower.contains('error_busy') ||
        lower.contains('recognizer_not_available') ||
        lower.contains('recognizernotavailable');
  }

  void _retryWithOnDeviceRecognizer() {
    final request = _lastListenRequest;
    if (request == null) return;

    if (_usesNativeAndroidSpeech) {
      _retryWithNativeAndroidOnDeviceRecognizer(request);
      return;
    }

    if (_speech == null) return;

    _isRetryingOnDevice = true;
    _isListening = false;
    debugPrint('默认语音识别权限不足，尝试切换到 Android 本机语音识别');

    unawaited(
      _speech!
          .cancel()
          .then((_) => Future<void>.delayed(const Duration(milliseconds: 250)))
          .then((_) => _listen(request, onDevice: true))
          .catchError((Object error) {
        _emitError('默认和本机语音识别都无法启动: $error');
      }),
    );
  }

  void _recoverRecognizerAndRetry() {
    final request = _lastListenRequest;
    if (request == null) return;

    _isRecoveringRecognizer = true;
    _isListening = false;
    debugPrint('Android 语音识别服务断开，重建识别器后重试');

    unawaited(_recoverRecognizerAndRetryAsync(request));
  }

  Future<void> _recoverRecognizerAndRetryAsync(
      _SpeechListenRequest request) async {
    try {
      await _speech?.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 350));

      _speech = null;
      _isInitialized = false;
      final initialized = await initialize();
      if (!initialized) return;

      await _listen(request, onDevice: true);
    } catch (error) {
      _emitError('语音识别服务连接断开，重建后仍无法启动: $error');
    } finally {
      _isRecoveringRecognizer = false;
    }
  }

  void _ensureAndroidSpeechHandler() {
    if (_androidHandlerAttached) return;

    _androidSpeechChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onStatus':
          final status = call.arguments as String? ?? '';
          debugPrint('语音状态: $status');
          _isListening = status == 'listening';
          onListeningStateChanged?.call(_isListening);
          return;
        case 'onResult':
          final words = call.arguments as String? ?? '';
          debugPrint('语音识别结果: $words');
          _lastError = null;
          onResult?.call(words);
          return;
        case 'onError':
          final error = call.arguments as String? ?? 'error_unknown';
          debugPrint('语音识别错误: $error');
          if (_shouldRetryOnDevice(error) || _shouldRecoverRecognizer(error)) {
            final request = _lastListenRequest;
            if (request != null) {
              _retryWithNativeAndroidOnDeviceRecognizer(request);
              return;
            }
          }
          _emitError(error);
          return;
        case 'onSoundLevel':
          final level = call.arguments;
          if (level is num) {
            onSoundLevelChanged?.call(level.toDouble());
          }
          return;
      }
    });
    _androidHandlerAttached = true;
  }

  Future<bool> _startNativeAndroidListening(
    _SpeechListenRequest request, {
    bool onDevice = false,
  }) async {
    _ensureAndroidSpeechHandler();
    final started = await _androidSpeechChannel.invokeMethod<bool>(
          'startListening',
          {
            'localeId': request.localeId ?? 'zh_CN',
            'listenForMillis': request.listenFor.inMilliseconds,
            'pauseForMillis': request.pauseFor.inMilliseconds,
            'partialResults': request.partialResults,
            'onDevice': onDevice,
          },
        ) ??
        false;

    if (!started) {
      _emitError(onDevice ? 'Android 本机语音识别无法启动' : 'Android 语音识别无法启动');
    }
    return started;
  }

  void _retryWithNativeAndroidOnDeviceRecognizer(_SpeechListenRequest request) {
    if (_isRetryingOnDevice) return;

    _isRetryingOnDevice = true;
    _isListening = false;
    debugPrint('Android 语音识别失败，尝试切换到带 attribution 的本机识别器');

    unawaited(
      _androidSpeechChannel
          .invokeMethod<bool>('cancelListening')
          .then((_) => Future<void>.delayed(const Duration(milliseconds: 250)))
          .then((_) => _startNativeAndroidListening(request, onDevice: true))
          .then((started) {
        if (!started) {
          _emitError('默认和本机 Android 语音识别都无法启动');
        }
      }).catchError((Object error) {
        _emitError('默认和本机 Android 语音识别都无法启动: $error');
      }),
    );
  }
}

class _SpeechListenRequest {
  const _SpeechListenRequest({
    required this.localeId,
    required this.pauseFor,
    required this.listenFor,
    required this.partialResults,
  });

  final String? localeId;
  final Duration pauseFor;
  final Duration listenFor;
  final bool partialResults;
}
