import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:zenify/services/service_config.dart';

class ApiService {
  static final _client = http.Client();
  static const _headers = {'Content-Type': 'application/json'};
  static Future<dynamic> request(
    ApiEndpoint endpoint, {
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      print('queryParams: $queryParams');
      print('pathParams: $pathParams');
      print('body: $body');
      print('headers: $headers');
      String processedPath = endpoint.path;
      pathParams?.forEach((key, value) {
        processedPath = processedPath.replaceAll('{$key}', value.toString());
      });
      var uri = Uri.parse('${ApiConfig.baseUrl}$processedPath');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: _convertParams(queryParams ?? {}));
      }
      print('uri: $uri');

      print('API请求: ${_methodToString(endpoint.method)} ${uri.toString()}');

      final request = http.Request(_methodToString(endpoint.method), uri)
        ..headers.addAll(_headers)
        ..body = body != null ? jsonEncode(body) : ''
        ..followRedirects = true;

      final response = await _client
          .send(request)
          .timeout(const Duration(milliseconds: ApiConfig.connectTimeout))
          .then(http.Response.fromStream);

      // print('API响应: ${response.statusCode} ${response.body}');

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('请求超时，请检查网络连接');
    } catch (e) {
      print('Error details: $e');
      throw Exception('请求失败: $e');
    }
  }

  static String _methodToString(HttpMethod method) {
    switch (method) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.delete:
        return 'DELETE';
      case HttpMethod.patch:
        return 'PATCH';
    }
  }

  static dynamic _handleResponse(http.Response response) {
    print('_handleResponse:$response');
    switch (response.statusCode) {
      case 200:
      case 201:
        final responseBody = response.body;
        if (responseBody.isNotEmpty) {
          try {
            final jsonData = jsonDecode(responseBody);
            return jsonData;
          } catch (e) {
            throw Exception('Failed to parse response: $e');
          }
        }
        return null;
      case 204:
        return null;
      case 400:
        throw Exception('请求参数错误: ${response.body}');
      case 401:
        throw Exception('未授权，请登录');
      case 403:
        throw Exception('拒绝访问');
      case 404:
        throw Exception('资源不存在');
      case 500:
        throw Exception('服务器错误: ${response.body}');
      default:
        throw Exception('请求失败，状态码: ${response.statusCode}');
    }
  }

  static void close() {
    _client.close();
  }
}

Map<String, String> _convertParams(Map<String, dynamic> params) {
  return params.map((key, value) => MapEntry(key, value.toString()));
}
