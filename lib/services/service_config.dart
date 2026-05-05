enum HttpMethod { get, post, put, delete, patch }

class ApiEndpoint {
  final String path;
  final HttpMethod method;

  const ApiEndpoint(this.path, this.method);
}

/// 仅保留工程内实际引用的端点；未使用定义已移除（见 `api.dart` / `ai_stream.dart`）。
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'http://118.195.149.172:8000',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String apiV2Version = "/api/v2";
  static const String mqttBrokerAddress = String.fromEnvironment(
    'MQTT_BROKER_ADDRESS',
    defaultValue: '118.195.149.172',
  );
  static const String _mqttPortString =
      String.fromEnvironment('MQTT_PORT', defaultValue: '1883');
  static final int mqttPort = int.tryParse(_mqttPortString) ?? 1883;
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // --- 用户 ---
  static const login = ApiEndpoint(
    '$apiV2Version/auth/login',
    HttpMethod.post,
  );
  static const register = ApiEndpoint(
    '$apiV2Version/auth/register',
    HttpMethod.post,
  );
  static const getUserProfile = ApiEndpoint(
    '$apiV2Version/profiles/me',
    HttpMethod.get,
  );

  // --- 食谱 / 食物（列表与详情）---
  static const getFoods = ApiEndpoint(
    '$apiV2Version/foods',
    HttpMethod.get,
  );
  // --- 当前用户食谱计划 ---
  static const getDailyRecommendation = ApiEndpoint(
    '$apiV2Version/recommendations/daily/current',
    HttpMethod.get,
  );
  static const generateDailyRecommendation = ApiEndpoint(
    '$apiV2Version/recommendations/daily/generate',
    HttpMethod.post,
  );
  static const replacePlanFood = ApiEndpoint(
    '$apiV2Version/recommendations/items/{recommendation_item_id}/replace',
    HttpMethod.put,
  );

  // --- 饮食记录（设备维度）---
  static const getUserTodayMealRecords = ApiEndpoint(
    '$apiV2Version/meal-records/today',
    HttpMethod.get,
  );
  static const getLatestMealRecord = ApiEndpoint(
    '$apiV2Version/meal-records/latest',
    HttpMethod.get,
  );
  static const getMealRecordsDetail = ApiEndpoint(
    '$apiV2Version/meal-records/{meal_record_id}',
    HttpMethod.get,
  );

  static const createMealSession = ApiEndpoint(
    '$apiV2Version/meal-sessions',
    HttpMethod.post,
  );
  static const uploadMealSessionRecognition = ApiEndpoint(
    '$apiV2Version/meal-sessions/{meal_session_id}/recognitions/upload',
    HttpMethod.post,
  );

  // --- 识别（MQTT 前缀路由）---
  static const getRecognitions = ApiEndpoint(
    '$apiV2Version/recognitions',
    HttpMethod.get,
  );
  static const getLatestRecognition = ApiEndpoint(
    '$apiV2Version/recognitions/latest',
    HttpMethod.get,
  );

  // --- 整餐替换 ---
  // --- 设备 ---
  static const bindDevice = ApiEndpoint(
    '$apiV2Version/devices/{hardware_device_id}/binding',
    HttpMethod.post,
  );
  static const getUserDevices = ApiEndpoint(
    '$apiV2Version/devices',
    HttpMethod.get,
  );
  static const unbindDevice = ApiEndpoint(
    '$apiV2Version/devices/{hardware_device_id}/binding',
    HttpMethod.delete,
  );

  // --- 对话（流式由 ai_stream 拼 URL）---
  static const aiChart = '$apiV2Version/chat';
  static const aiChartWithFile = '$apiV2Version/chat/with-file';
}
