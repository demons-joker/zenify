import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _image;
  bool _showCompletion = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _showCompletion = true;
      });

      // 3秒后自动关闭完成动画
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _showCompletion = false);
        }
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSourceButton('拍照', Icons.camera_alt, () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            }),
            SizedBox(height: 16),
            _buildSourceButton('从相册选择', Icons.photo_library, () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 主内容
        Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 60, color: Colors.white54),
                SizedBox(height: 20),
                Text(
                  '点击下方按钮拍照或选择照片',
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: _showImageSourceDialog,
                  child: Text('选择照片来源', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),

        // 完成动画（使用Iconfont）
        if (_showCompletion) _buildCompletionOverlay(),
      ],
    );
  }

  Widget _buildCompletionOverlay() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 使用Iconfont中的完成图标
            Icon(
              Icons.check_circle_outlined,
              size: 80,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              '完成',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '已将数据同步到餐盘',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
