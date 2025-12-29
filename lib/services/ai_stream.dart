import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:zenify/services/service_config.dart';

class StreamApiClient {
  final String? token;

  StreamApiClient({this.token});

  /// 普通文本聊天流式请求
  Stream<String> streamPost({
    required dynamic body,
    Map<String, String>? headers,
  }) async* {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.aiChart}');
    print('streamPost: $body');
    final request = http.Request('POST', uri)
      ..headers.addAll(headers ??
          {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          })
      ..body = json.encode(body);

    try {
      final streamedResponse = await http.Client().send(request);
      print('streamedResponse:');
      print(streamedResponse.statusCode);
      print(streamedResponse.headers);
      print(streamedResponse.request);
      print(streamedResponse);
      if (streamedResponse.statusCode != 200) {
        throw Exception(
            'Failed to stream AI response: ${streamedResponse.statusCode}');
      }
      final stream = streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final chunk in stream) {
        yield chunk;
      }
    } catch (e) {
      throw Exception('Failed to stream AI response: $e');
    }
  }

  /// 带文件的聊天流式请求
  /// 服务端期望格式：
  /// messages: List[Dict[str, str]] = Form(...)
  /// files: List[UploadFile] = File(...)
  Stream<String> streamPostWithFiles({
    required List<Map<String, dynamic>> messages,
    required List<Map<String, dynamic>> fileDataList,
    Map<String, String>? headers,
  }) async* {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.aiChartWithFile}');
    print('streamPostWithFiles: messages count: ${messages.length}');
    print('streamPostWithFiles: files count: ${fileDataList.length}');
    print('Messages content: ${json.encode(messages)}');

    // 创建multipart/form-data请求
    final request = http.MultipartRequest('POST', uri);

    // 添加headers
    request.headers.addAll(headers ?? {});
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // 发送messages作为JSON字符串（正确的做法）
    // 服务端应该修改为使用 Body() 或者手动解析JSON字符串
    request.fields['messages'] = json.encode(messages);

    // 添加文件（如果有的话）
    for (int i = 0; i < fileDataList.length; i++) {
      final fileData = fileDataList[i];
      final dataUri = fileData['data'] as String;
      final fileName = fileData['name'] as String;

      // 解析data URI
      final commaIndex = dataUri.indexOf(',');
      if (commaIndex == -1) {
        throw Exception('Invalid data URI format for file: $fileName');
      }

      final base64Data = dataUri.substring(commaIndex + 1);
      final fileBytes = base64.decode(base64Data);

      final multipartFile = http.MultipartFile.fromBytes(
        'files', // 字段名，与服务器期望的参数名匹配
        fileBytes,
        filename: fileName,
      );
      request.files.add(multipartFile);
    }

    // 如果没有文件，仍然发送请求（服务端可以处理空文件列表）
    // 注意：不创建空文件，让服务端处理files为null的情况

    try {
      // 打印请求详情用于调试
    print('Request details:');
    print('URL: ${request.url}');
    print('Method: ${request.method}');
    print('Headers: ${request.headers}');
    print('Fields: ${request.fields}');
    print('Messages field: ${request.fields['messages']}');
    print('Files count: ${request.files.length}');
    for (var file in request.files) {
      print(
          'File: ${file.field}, name: ${file.filename}, size: ${file.length}');
    }

      final streamedResponse = await request.send();
      print('streamPostWithFiles response:');
      print('Status: ${streamedResponse.statusCode}');
      print('Headers: ${streamedResponse.headers}');

      if (streamedResponse.statusCode != 200) {
        final responseBody = await streamedResponse.stream.bytesToString();
        print('Error response: $responseBody');
        throw Exception(
            'Failed to stream AI response with files: ${streamedResponse.statusCode}, Body: $responseBody');
      }

      final stream = streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final chunk in stream) {
        yield chunk;
      }
    } catch (e) {
      print('streamPostWithFiles error: $e');
      throw Exception('Failed to stream AI response with files: $e');
    }
  }

  /// 便捷方法：构建带文件的用户消息
  /// 自动转换文件内容为base64格式
  static Map<String, dynamic> buildUserMessageWithFiles({
    required String text,
    required List<Map<String, dynamic>> files,
  }) {
    final contentItems = <Map<String, dynamic>>[];

    // 添加文本内容
    if (text.isNotEmpty) {
      contentItems.add({
        'type': 'text',
        'text': text,
      });
    }

    // 添加文件内容
    for (final file in files) {
      final filePath = file['path'] as String;
      final fileObj = File(filePath);

      if (!fileObj.existsSync()) {
        throw Exception('File not found: $filePath');
      }

      final bytes = fileObj.readAsBytesSync();
      final base64 = base64Encode(bytes);
      final fileName = file['name'] ?? filePath.split('/').last;
      final fileSize = bytes.length;

      // 根据文件扩展名确定MIME类型
      final extension = fileName.toLowerCase().split('.').last;
      String mimeType = 'application/octet-stream';

      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'pdf':
          mimeType = 'application/pdf';
          break;
        case 'doc':
        case 'docx':
          mimeType = 'application/msword';
          break;
        case 'txt':
          mimeType = 'text/plain';
          break;
      }

      final dataUri = 'data:$mimeType;base64,$base64';

      contentItems.add({
        'type': mimeType.startsWith('image/')
            ? 'image'
            : mimeType.startsWith('application/')
                ? 'document'
                : 'file',
        'name': fileName,
        'size': fileSize,
        'mime_type': mimeType,
        'data': dataUri,
      });
    }

    return {
      'role': 'user',
      'content': contentItems,
    };
  }
}
