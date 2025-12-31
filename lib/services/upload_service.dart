import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:zenify/services/service_config.dart';
import 'package:zenify/services/user_session.dart';

class UploadService {
  static Future<String?> uploadImage(
    File imageFile,
    BuildContext context,
  ) async {
    try {
      final userId = await UserSession.userId;
      final uri = Uri.parse(
          '${ApiConfig.baseUrl}/api/mqtt/users/$userId/plates/1/recognize/upload');
      print('uri: $uri');
      final request = http.MultipartRequest('POST', uri);

      // 添加文件
      final fileName = path.basename(imageFile.path);
      final fileStream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();

      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        length,
        filename: fileName,
      );
      request.files.add(multipartFile);

      // 显示上传进度
      // if (context.mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('正在上传图片...')),
      //   );
      // }

      // 发送请求
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // if (context.mounted) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(content: Text('上传成功')),
        //   );
        // }
        return responseData;
      } else {
        throw Exception('上传失败: ${response.statusCode}');
      }
    } catch (e) {
      // if (context.mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('上传错误: $e')),
      //   );
      // }
      return null;
    }
  }
}
