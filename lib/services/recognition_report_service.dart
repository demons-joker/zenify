import 'package:zenify/services/api.dart';

class RecognitionReportService {
  static Future<Map<String, dynamic>?> getLatestRecord() {
    return Api.getLatestRecognition();
  }

  static List<dynamic> resolveFoods(Map<String, dynamic>? record) {
    if (record == null) return const [];
    final foods = record['foods'];
    if (foods is List) {
      return foods;
    }
    return const [];
  }
}
