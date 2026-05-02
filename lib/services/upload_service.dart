import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:zenify/core/app_logger.dart';
import 'package:zenify/services/api_service.dart';
import 'package:zenify/services/service_config.dart';
import 'package:zenify/services/user_session.dart';

class UploadResult {
  final bool success;
  final int? statusCode;
  final String? responseBody;
  final String? errorMessage;
  final Map<String, dynamic>? payload;

  const UploadResult._({
    required this.success,
    this.statusCode,
    this.responseBody,
    this.errorMessage,
    this.payload,
  });

  factory UploadResult.success({
    required int statusCode,
    String? body,
    Map<String, dynamic>? payload,
  }) {
    return UploadResult._(
      success: true,
      statusCode: statusCode,
      responseBody: body,
      payload: payload,
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
      final deviceId = await UserSession.deviceId;
      final token = await UserSession.token;
      if (deviceId == null || token == null) {
        return UploadResult.failure(message: '用户或设备信息缺失');
      }

      final mealSessionResponse = await ApiService.request(
        ApiConfig.createMealSession,
        body: {
          'hardware_device_id': deviceId,
          'session_type': 'ad_hoc',
          'trigger_source': 'app',
          'source': 'camera_upload',
        },
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (mealSessionResponse is! Map<String, dynamic> ||
          mealSessionResponse['id'] == null) {
        return UploadResult.failure(message: '创建用餐会话失败');
      }

      final mealSessionId = mealSessionResponse['id'];
      final uploadPath = ApiConfig.uploadMealSessionRecognition.path
          .replaceAll('{meal_session_id}', mealSessionId.toString());
      final uri = Uri.parse('${ApiConfig.baseUrl}$uploadPath');
      AppLogger.info('upload uri: $uri');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

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

      Map<String, dynamic>? responsePayload;
      try {
        final parsed = jsonDecode(responseData);
        if (parsed is Map<String, dynamic>) {
          responsePayload = parsed;
        }
      } catch (_) {}

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        return UploadResult.success(
          statusCode: response.statusCode,
          body: responseData,
          payload: responsePayload,
        );
      } else {
        String errorMessage = '上传失败: ${response.statusCode}';
        try {
          final parsed = jsonDecode(responseData);
          if (parsed is Map<String, dynamic> && parsed['detail'] != null) {
            errorMessage = parsed['detail'].toString();
          }
        } catch (_) {}
        return UploadResult.failure(
          statusCode: response.statusCode,
          body: responseData,
          message: errorMessage,
        );
      }
    } catch (e) {
      return UploadResult.failure(message: '上传错误: $e');
    }
  }
}
