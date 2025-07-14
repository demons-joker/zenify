import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  XFile? _imageFile;
  bool _isTakingPhoto = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('没有可用的相机');
      }

      _cameraController = CameraController(
        cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        ),
        ResolutionPreset.medium,
      );

      _initializeControllerFuture = _cameraController.initialize();
      await _initializeControllerFuture;
    } catch (e) {
      print('相机初始化失败: $e');
      // 可以在这里添加错误处理UI
    }
  }

  Future<void> _takePhoto() async {
    if (!_cameraController.value.isInitialized || _isTakingPhoto) {
      return;
    }

    setState(() => _isTakingPhoto = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/photo_$timestamp.jpg';

      final imageFile = await _cameraController.takePicture();

      // 检查文件是否存在
      final file = File(imageFile.path);
      if (await file.exists()) {
        setState(() {
          _imageFile = imageFile;
        });

        // 可以在这里添加照片处理逻辑
        // 例如上传到服务器或保存到相册
      } else {
        throw Exception('照片文件未创建成功');
      }
    } catch (e) {
      print('拍照失败: $e');
      // 可以在这里添加错误提示
    } finally {
      setState(() => _isTakingPhoto = false);
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

      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });

        // 可以在这里添加照片处理逻辑
      }
    } catch (e) {
      print('选择照片失败: $e');
      // 可以在这里添加错误提示
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('拍照')),
      body: Stack(
        children: [
          if (_cameraController.value.isInitialized)
            CameraPreview(_cameraController),
          if (_imageFile != null)
            Positioned.fill(
              child: Image.file(File(_imageFile!.path), fit: BoxFit.cover),
            ),
          if (_isTakingPhoto) Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: _takePhoto,
            child: Icon(Icons.camera),
            heroTag: 'camera',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _pickPhoto,
            child: Icon(Icons.photo_library),
            heroTag: 'gallery',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
