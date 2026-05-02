import 'package:zenify/services/api.dart';
import 'package:zenify/services/user_session.dart';

class RecognitionReportService {
  static Future<Map<String, dynamic>?> getLatestRecord() async {
    final deviceId = await UserSession.deviceId;
    return Api.getLatestMealRecord({
      if (deviceId != null) 'device_id': deviceId,
    });
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
