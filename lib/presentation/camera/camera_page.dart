import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:zenify/core/app_logger.dart';
import 'package:zenify/services/mqtt_service.dart';
import 'package:zenify/presentation/camera/camera_upload_coordinator.dart';
import 'package:zenify/services/upload_service.dart';
import 'dart:async';
import 'package:zenify/utils/toast_helper.dart';
import 'package:zenify/utils/error_message_helper.dart';

enum CameraAnalyzeStage {
  idle,
  uploading,
  waitingMqtt,
  analyzing,
  completed,
  failed,
}

class CameraPage extends StatefulWidget {
  final CameraUploadCoordinator? uploadCoordinator;
  final Stream<RecognitionStatus>? statusStream;
  final String? initialImagePath;
  final bool skipCameraInitialization;
  final Duration mqttWaitTimeout;
  final Duration completionNavigationDelay;

  const CameraPage({
    super.key,
    this.uploadCoordinator,
    this.statusStream,
    this.initialImagePath,
    this.skipCameraInitialization = false,
    this.mqttWaitTimeout = const Duration(seconds: 25),
    this.completionNavigationDelay = const Duration(milliseconds: 700),
  });

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  XFile? _imageFile;
  bool _cameraAvailable = false;
  bool _isTakingPhoto = false;
  bool _showPreview = false;
  bool _isInitializing = true;
  CameraAnalyzeStage _analyzeStage = CameraAnalyzeStage.idle;
  String? _statusMessage;
  File? _lastSubmittedFile;
  Timer? _mqttWaitTimer;
  late final CameraUploadCoordinator _uploadCoordinator;
  StreamSubscription<RecognitionStatus>? _mqttSubscription;

  @override
  void initState() {
    super.initState();
    _uploadCoordinator = widget.uploadCoordinator ?? CameraUploadCoordinator();
    if (widget.initialImagePath != null) {
      _imageFile = XFile(widget.initialImagePath!);
      _showPreview = true;
    }
    if (widget.skipCameraInitialization) {
      _cameraAvailable = false;
      _isInitializing = false;
    } else {
      _initializeCamera();
    }
    _listenToMQTT();
  }

  /// 监听 MQTT 消息
  void _listenToMQTT() {
    final statusStream = widget.statusStream ?? MQTTService().statusStream;
    _mqttSubscription = statusStream.listen((status) {
      if (!mounted) return;

      // The camera page should not block on recognition state once upload starts.
      // Ignore MQTT status transitions during the upload request itself, because
      // they can arrive before the HTTP call returns 202 and re-enable the old
      // "wait on camera page" behavior.
      if (_analyzeStage == CameraAnalyzeStage.uploading) {
        return;
      }

      if (status.status == RecognitionStatusType.analyzing) {
        _cancelWaitTimeout();
        setState(() {
          _analyzeStage = CameraAnalyzeStage.analyzing;
          _statusMessage = '识别已开始，正在处理...';
        });
      }

      if (status.status == RecognitionStatusType.completed) {
        _cancelWaitTimeout();
        setState(() {
          _analyzeStage = CameraAnalyzeStage.completed;
          _statusMessage = '识别完成，正在返回结果页...';
        });
        Future.delayed(widget.completionNavigationDelay, () {
          if (mounted) {
            Navigator.of(context).pop({'switchToATE': true});
          }
        });
      }
    });
  }

  bool get _isSubmitting {
    return _analyzeStage == CameraAnalyzeStage.uploading ||
        _analyzeStage == CameraAnalyzeStage.waitingMqtt ||
        _analyzeStage == CameraAnalyzeStage.analyzing;
  }

  void _cancelWaitTimeout() {
    _mqttWaitTimer?.cancel();
    _mqttWaitTimer = null;
  }

  void _startWaitTimeout() {
    _cancelWaitTimeout();
    _mqttWaitTimer = Timer(widget.mqttWaitTimeout, () {
      if (!mounted) return;
      setState(() {
        _analyzeStage = CameraAnalyzeStage.failed;
        _statusMessage = '等待识别通知超时，请重试';
      });
      ToastHelper.error(context, '识别通知超时，请重试');
    });
  }

  Future<void> _submitImage() async {
    if (_imageFile == null || _isSubmitting) {
      return;
    }

    final file = File(_imageFile!.path);
    _lastSubmittedFile = file;
    setState(() {
      _analyzeStage = CameraAnalyzeStage.uploading;
      _statusMessage = '图片上传中...';
    });

    final result = await _uploadCoordinator.submitImage(file);
    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _analyzeStage = CameraAnalyzeStage.failed;
        _statusMessage = result.errorMessage ?? '上传失败，请稍后重试';
      });
      ToastHelper.error(
          context, ErrorMessageHelper.format(result.errorMessage));
      return;
    }

    if (_analyzeStage == CameraAnalyzeStage.analyzing ||
        _analyzeStage == CameraAnalyzeStage.completed) {
      return;
    }

    _cancelWaitTimeout();
    Navigator.of(context).pop({
      'switchToATE': true,
      'recognitionPending': true,
      'recognitionData': result.payload,
    });
    return;

    setState(() {
      _analyzeStage = CameraAnalyzeStage.waitingMqtt;
      _statusMessage = '上传成功，等待识别开始...';
    });
    _startWaitTimeout();
  }

  void _cancelWaiting() {
    _cancelWaitTimeout();
    if (!mounted) return;
    setState(() {
      _analyzeStage = CameraAnalyzeStage.idle;
      _statusMessage = null;
    });
  }

  Future<void> _retrySubmit() async {
    if (_lastSubmittedFile == null && _imageFile == null) {
      return;
    }
    await _submitImage();
  }

  Future<void> _initializeCamera() async {
    try {
      if (!kIsWeb && !(Platform.isAndroid || Platform.isIOS)) {
        AppLogger.warning('当前平台不支持 camera 插件，已降级为相册模式');
        if (mounted) {
          setState(() {
            _cameraAvailable = false;
          });
        }
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;
      _cameraAvailable = true;
    } catch (e) {
      _cameraAvailable = false;
      AppLogger.warning('Camera initialization unavailable: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _takePhoto() async {
    if (!_cameraAvailable) {
      if (!mounted) return;
      ToastHelper.warning(context, '当前设备不支持拍照，请使用相册上传');
      return;
    }
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isTakingPhoto) {
      return;
    }

    setState(() => _isTakingPhoto = true);

    try {
      final imageFile = await _cameraController!.takePicture();
      final file = File(imageFile.path);

      if (await file.exists()) {
        setState(() {
          _imageFile = imageFile;
          _showPreview = true;
        });
      } else {
        throw Exception('Failed to create photo file');
      }
    } catch (e) {
      AppLogger.error('Photo capture error: $e');
      if (!mounted) return;
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('拍照失败: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isTakingPhoto = false);
      }
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = pickedFile;
          _showPreview = true;
        });
      }
    } catch (e) {
      AppLogger.error('Photo pick error: $e');
      if (!mounted) return;
      ToastHelper.error(context, ErrorMessageHelper.format(e));
    }
  }

  void _retakePhoto() {
    if (mounted) {
      setState(() {
        _showPreview = false;
        _imageFile = null;
        _analyzeStage = CameraAnalyzeStage.idle;
        _statusMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 允许返回并确保main.dart会恢复导航栏
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: _isSubmitting
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.white),
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          ),
        ),
        body: _isInitializing
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Camera preview or photo preview
                  if (_showPreview && _imageFile != null)
                    Positioned.fill(
                      child:
                          Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                    )
                  else if (_cameraAvailable && _cameraController != null)
                    Positioned.fill(
                      child: CameraPreview(_cameraController!),
                    ),

                  // Bottom controls
                  if (_analyzeStage == CameraAnalyzeStage.idle)
                    Positioned(
                      bottom: MediaQuery.of(context).padding.bottom + 24,
                      left: 0,
                      right: 0,
                      child: _buildBottomControls(),
                    ),

                  // Loading indicator when taking photo
                  if (_isTakingPhoto)
                    const Center(
                      child: CircularProgressIndicator(
                        key: Key('camera_capture_loading_indicator'),
                      ),
                    ),
                  if (_analyzeStage != CameraAnalyzeStage.idle)
                    Positioned.fill(
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 220),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_analyzeStage ==
                                          CameraAnalyzeStage.completed)
                                        Icon(
                                          Icons.check_circle,
                                          key: const Key(
                                              'camera_status_completed_icon'),
                                          color: Colors.green,
                                          size: 48,
                                        )
                                      else if (_analyzeStage ==
                                          CameraAnalyzeStage.failed)
                                        Icon(
                                          Icons.error_outline,
                                          key: const Key(
                                              'camera_status_failed_icon'),
                                          color: Colors.redAccent,
                                          size: 48,
                                        )
                                      else
                                        const CircularProgressIndicator(
                                          key: Key(
                                              'camera_status_loading_indicator'),
                                        ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _statusMessage ?? '',
                                        key: const Key('camera_status_text'),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      if (_analyzeStage ==
                                          CameraAnalyzeStage.waitingMqtt)
                                        TextButton(
                                          key: const Key(
                                              'camera_cancel_wait_button'),
                                          onPressed: _cancelWaiting,
                                          child: const Text(
                                            '取消等待',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      if (_analyzeStage ==
                                          CameraAnalyzeStage.failed)
                                        TextButton(
                                          key:
                                              const Key('camera_retry_button'),
                                          onPressed: _retrySubmit,
                                          child: const Text(
                                            '重试上传',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_showPreview)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                key: const Key('camera_reshoot_button'),
                child: Text('Reshoot',
                    style: TextStyle(
                        color: _isSubmitting
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.white)),
                onPressed: _isSubmitting ? null : _retakePhoto,
              ),
              TextButton(
                key: const Key('camera_ok_button'),
                child: Text('OK',
                    style: TextStyle(
                        color: _isSubmitting
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.white)),
                onPressed: _isSubmitting ? null : _submitImage,
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.photo_library, color: Colors.white),
                onPressed: _pickPhoto,
              ),
              GestureDetector(
                onTap: _cameraAvailable ? _takePhoto : null,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _cameraAvailable
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                      width: 4,
                    ),
                  ),
                  child: !_cameraAvailable
                      ? const Icon(Icons.block, color: Colors.white70, size: 24)
                      : null,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
      ],
    );
  }

  @override
  void dispose() {
    _cancelWaitTimeout();
    _cameraController?.dispose();
    _mqttSubscription?.cancel();
    super.dispose();
  }
}
