import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:zenify/core/app_logger.dart';
import 'package:zenify/services/mqtt_service.dart';
import 'package:zenify/presentation/camera/camera_upload_coordinator.dart';
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
  final CameraUploadCoordinator _uploadCoordinator = CameraUploadCoordinator();
  StreamSubscription<RecognitionStatus>? _mqttSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _listenToMQTT();
  }

  /// 监听 MQTT 消息
  void _listenToMQTT() {
    _mqttSubscription = MQTTService().statusStream.listen((status) {
      if (!mounted) return;

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
        Future.delayed(const Duration(milliseconds: 700), () {
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
    _mqttWaitTimer = Timer(const Duration(seconds: 25), () {
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
                  Positioned(
                    bottom: MediaQuery.of(context).padding.bottom + 24,
                    left: 0,
                    right: 0,
                    child: _buildBottomControls(),
                  ),

                  // Loading indicator when taking photo
                  if (_isTakingPhoto)
                    Center(child: CircularProgressIndicator()),
                  if (_analyzeStage != CameraAnalyzeStage.idle)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_analyzeStage == CameraAnalyzeStage.completed)
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 48)
                          else if (_analyzeStage == CameraAnalyzeStage.failed)
                            Icon(Icons.error_outline,
                                color: Colors.redAccent, size: 48)
                          else
                            CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            _statusMessage ?? '',
                            style: TextStyle(color: Colors.white),
                          ),
                          if (_analyzeStage == CameraAnalyzeStage.waitingMqtt)
                            TextButton(
                              onPressed: _cancelWaiting,
                              child: const Text(
                                '取消等待',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          if (_analyzeStage == CameraAnalyzeStage.failed)
                            TextButton(
                              onPressed: _retrySubmit,
                              child: const Text(
                                '重试上传',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
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
                child: Text('Reshoot',
                    style: TextStyle(
                        color: _isSubmitting
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.white)),
                onPressed: _isSubmitting ? null : _retakePhoto,
              ),
              TextButton(
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
