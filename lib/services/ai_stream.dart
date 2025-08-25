import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zenify/services/service_config.dart';

class StreamApiClient {
  final String? token;

  StreamApiClient({this.token});

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
}
