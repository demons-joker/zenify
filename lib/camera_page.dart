import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:zenify/services/upload_service.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  XFile? _imageFile;
  bool _isTakingPhoto = false;
  bool _showPreview = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
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
    } catch (e) {
      print('Camera initialization error: $e');
      // 可以考虑在这里显示错误UI
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _takePhoto() async {
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
      print('Photo capture error: $e');
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
      print('Photo pick error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择照片失败: ${e.toString()}')),
      );
    }
  }

  void _retakePhoto() {
    if (mounted) {
      setState(() {
        _showPreview = false;
        _imageFile = null;
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
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: _showPreview && _imageFile != null
              ? TextButton(
                  child: Text('使用照片', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    final file = File(_imageFile!.path);
                    final result =
                        await UploadService.uploadImage(file, context);
                    if (result != null && mounted) {
                      Navigator.of(context).pop(result);
                    }
                  },
                )
              : null,
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
                  else if (_cameraController != null)
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
                child: Text('重拍', style: TextStyle(color: Colors.white)),
                onPressed: _retakePhoto,
              ),
              TextButton(
                child: Text('确认', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.of(context).pop(_imageFile!.path),
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
                onTap: _takePhoto,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
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
    _cameraController?.dispose();
    super.dispose();
  }
}
