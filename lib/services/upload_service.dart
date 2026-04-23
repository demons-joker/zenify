import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:zenify/core/app_logger.dart';
import 'package:zenify/services/service_config.dart';
import 'package:zenify/services/user_session.dart';

class UploadResult {
  final bool success;
  final int? statusCode;
  final String? responseBody;
  final String? errorMessage;

  const UploadResult._({
    required this.success,
    this.statusCode,
    this.responseBody,
    this.errorMessage,
  });

  factory UploadResult.success({required int statusCode, String? body}) {
    return UploadResult._(
      success: true,
      statusCode: statusCode,
      responseBody: body,
    );
  }

  factory UploadResult.failure({
    int? statusCode,
    String? body,
    required String message,
  }) {
    return UploadResult._(
      success: false,
      statusCode: statusCode,
      responseBody: body,
      errorMessage: message,
    );
  }
}

class UploadService {
  static Future<UploadResult> uploadImage(
    File imageFile,
  ) async {
    try {
      final userId = await UserSession.userId;
      final plateId = await UserSession.plateId;
      if (userId == null || plateId == null) {
        return UploadResult.failure(message: '用户或设备信息缺失');
      }

      final uri = Uri.parse(
          '${ApiConfig.baseUrl}/api/mqtt/users/$userId/plates/$plateId/recognize/upload');
      AppLogger.info('upload uri: $uri');
      final request = http.MultipartRequest('POST', uri);

      // 添加文件
      final fileName = imageFile.uri.pathSegments.last;
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
        return UploadResult.success(
          statusCode: response.statusCode,
          body: responseData,
        );
      } else {
        return UploadResult.failure(
          statusCode: response.statusCode,
          body: responseData,
          message: '上传失败: ${response.statusCode}',
        );
      }
    } catch (e) {
      return UploadResult.failure(message: '上传错误: $e');
    }
  }
}
