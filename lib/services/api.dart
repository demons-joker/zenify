import 'package:zenify/services/user_session.dart';
import 'package:zenify/services/api_service.dart';
import 'package:zenify/services/service_config.dart';
import 'package:zenify/core/app_logger.dart';

class LoginRequest {
  final String name;
  final String email;
  final String fullName;
  final String password;
  final Map<String, dynamic>? userProfile;

  const LoginRequest({
    required this.name,
    this.email = '',
    this.fullName = '',
    required this.password,
    this.userProfile,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'password': password,
        if (email.isNotEmpty) 'email': email,
        if (fullName.isNotEmpty) 'full_name': fullName,
        if (userProfile != null) 'user_profile': userProfile,
      };
}

class FoodsRequest {
  final int skip;
  final int limit;
  final String? name;
  final String? category;
  final String? subcategory;

  const FoodsRequest({
    required this.skip,
    required this.limit,
    this.name,
    this.category,
    this.subcategory,
  });

  Map<String, dynamic> toJson() => {
        'skip': skip,
        'limit': limit,
        if (name != null) 'name': name,
        if (category != null) 'category': category,
        if (subcategory != null) 'subcategory': subcategory,
      };
}

class UserInfo {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String fullName;
  final String source;
  final DateTime createdAt;
  final bool isActive;
  final List<DeviceInfo> devices;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.source,
    required this.createdAt,
    required this.isActive,
    required this.devices,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      source: json['source'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isActive: json['is_active'] ?? json['isActive'] ?? false,
      devices: json['devices'] != null
          ? (json['devices'] as List)
              .map<DeviceInfo>((device) =>
                  DeviceInfo.fromJson(device as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class DeviceInfo {
  final int id;
  final String deviceId;
  final String deviceType;
  final Map<String, dynamic>? capabilityFlags;
  final DateTime? lastLoginAt;
  final bool isOnline;
  final String name;
  final DateTime createdAt;
  final int zoneCount;
  final String? bindingStatus;
  final String? status;

  DeviceInfo({
    required this.id,
    required this.deviceId,
    required this.deviceType,
    this.capabilityFlags,
    this.lastLoginAt,
    required this.isOnline,
    required this.name,
    required this.createdAt,
    this.zoneCount = 0,
    this.bindingStatus,
    this.status,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['id'] ?? 0,
      deviceId:
          (json['hardware_device_id'] ?? json['device_id'] ?? '').toString(),
      deviceType: (json['device_type'] ?? 'smart_plate').toString(),
      capabilityFlags: json['capability_flags'] is Map<String, dynamic>
          ? json['capability_flags'] as Map<String, dynamic>
          : {
              'supports_weight':
                  ((json['device_type'] ?? 'smart_plate').toString() ==
                          'smart_plate') ||
                      ((json['zone_count'] is int
                              ? json['zone_count'] as int
                              : int.tryParse('${json['zone_count'] ?? 0}') ??
                                  0) >
                          0),
              'supports_image_upload': true,
            },
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : json['bound_at'] != null
              ? DateTime.parse(json['bound_at'])
              : null,
      isOnline: json['is_online'] ?? false,
      name: json['device_name'] ?? json['name'] ?? '鏈煡璁惧',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : json['bound_at'] != null
              ? DateTime.parse(json['bound_at'])
              : DateTime.now(),
      zoneCount: json['zone_count'] is int
          ? json['zone_count'] as int
          : int.tryParse('${json['zone_count'] ?? 0}') ?? 0,
      bindingStatus: json['binding_status']?.toString(),
      status: json['status']?.toString(),
    );
  }

  bool get supportsWeight =>
      (capabilityFlags?['supports_weight'] as bool?) ?? deviceType == 'smart_plate';

  bool get supportsImageUpload =>
      (capabilityFlags?['supports_image_upload'] as bool?) ?? true;
}

class Api {
  // 榛樿璇锋眰澶?
  static Map<String, String> get _defaultHeaders {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'Accept-Charset': 'utf-8',
    };
  }

  // 娣诲姞璁よ瘉澶?
  static Future<Map<String, String>> _getAuthHeaders() async {
    // 姣忔閮介噸鏂拌幏鍙?token锛岀‘淇濅娇鐢ㄦ渶鏂扮殑璁よ瘉淇℃伅
    final token = await UserSession.token;
    if (token != null) {
      return {
        ..._defaultHeaders,
        'Authorization': 'Bearer $token',
      };
    } else {
      return _defaultHeaders;
    }
  }

  // 娓呴櫎璁よ瘉澶寸紦瀛橈紙宸茬Щ闄ょ紦瀛樻満鍒讹紝姝ゆ柟娉曚繚鐣欎絾涓嶆墽琛屼换浣曟搷浣滐級
  static void clearAuthCache() {
    // 缂撳瓨鏈哄埗宸茬Щ闄わ紝姝ゆ柟娉曚繚鐣欎互淇濇寔鍚戝悗鍏煎鎬?
  }

  // 缁熶竴璇锋眰澶勭悊
  static Future<dynamic> _handleRequest(
    ApiEndpoint endpoint, {
    dynamic body,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? pathParams,
    Map<String, String>? header,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final combinedHeaders = {...headers, ...?header};
      final response = await ApiService.request(
        endpoint,
        body: body,
        queryParams: queryParams,
        pathParams: pathParams,
        headers: combinedHeaders,
      );
      // 濡傛灉闇€瑕侊紝鍙互鍦ㄨ繖閲岀粺涓€澶勭悊鍝嶅簲鏁版嵁
      return response;
    } catch (e) {
      // 缁熶竴閿欒澶勭悊
      if (e is! FormatException) {
        rethrow;
      }
      throw Exception('璇锋眰澶勭悊澶辫触: ${e.message}');
    }
  }

  // 娉ㄥ唽
  static Future<dynamic> register(LoginRequest request) async {
    return _handleRequest(
      ApiConfig.register,
      body: request.toJson(),
    );
  }

  // 鐧诲綍
  static Future<dynamic> login(LoginRequest request) async {
    return _handleRequest(
      ApiConfig.login,
      body: request.toJson(),
    );
  }

  // 鑾峰彇鐢ㄦ埛淇℃伅
  static Future<dynamic> getUserInfo() async {
    final userId = await UserSession.userId;
    if (userId == null) {
      throw Exception('鐢ㄦ埛鏈櫥褰?');
    }
    final profileResponse = await _handleRequest(ApiConfig.getUserProfile);
    final devices = await getUserDevices();

    final profileMap = profileResponse is Map<String, dynamic>
        ? profileResponse
        : <String, dynamic>{};
    final userMap = profileMap['user'] is Map<String, dynamic>
        ? profileMap['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    return {
      'id': userMap['id'] ?? userId,
      'name': userMap['name'] ?? '',
      'email': userMap['email'] ?? '',
      'phone': userMap['phone'] ?? '',
      'full_name': userMap['full_name'] ?? '',
      'source': userMap['source'] ?? 'app_v2',
      'created_at':
          userMap['created_at'] ?? DateTime.now().toIso8601String(),
      'is_active': userMap['is_active'] ?? true,
      'devices': devices,
    };
  }

  // 鐧诲嚭
  static Future<dynamic> logout() async {
    // 娓呴櫎 API 璁よ瘉缂撳瓨
    clearAuthCache();
    // 娓呴櫎鐢ㄦ埛浼氳瘽
    await UserSession.clear();
    return true;
  }

  //鏂板鎺ュ彛--------------start-------------

  // 鑾峰彇鎵€鏈夐鐗╁垪琛?
  static Future<dynamic> getFoods(FoodsRequest request) async {
    print('璇锋眰鍙傛暟: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.getFoods,
        queryParams: request.toJson(),
      );
      return response;
    } catch (e) {
      print('鑾峰彇鎵€鏈夐鐗╁垪琛ㄦ暟鎹け璐? $e');
      throw Exception('鑾峰彇鎵€鏈夐鐗╁垪琛ㄦ暟鎹け璐? $e');
    }
  }

  // 鑾峰彇褰撳墠鐢ㄦ埛椋熺墿鏁版嵁
  static Future<Map<String, dynamic>> getCurrentUserFoods(
      Map<String, dynamic> request) async {
    AppLogger.info('璇锋眰鍙傛暟: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.getDailyRecommendation,
      );
      if (response is Map<String, dynamic> && response['meals'] is List) {
        return _adaptV2DailyRecommendation(response);
      }
      if (response is Map &&
          response['success'] == true &&
          response['data'] is Map) {
        final data = response['data'] as Map<String, dynamic>;
        final mealGroups = data['meal_groups'];
        if (mealGroups is List) {
          return {
            "meal_groups": mealGroups,
            "generated_today": data['generated_today'] == true,
            "recommendation_source":
                (data['recommendation_source'] ?? 'none').toString(),
          };
        }
      }
      return {
        "meal_groups": <dynamic>[],
        "generated_today": false,
        "recommendation_source": "none",
      };
    } catch (e) {
      final errorText = e.toString();
      if (errorText.contains('404') || errorText.contains('资源不存在')) {
        AppLogger.warning('当前用户暂无食物数据，返回空列表');
        return {
          "meal_groups": <dynamic>[],
          "generated_today": false,
          "recommendation_source": "none",
        };
      }
      AppLogger.error('获取当前用户食物数据失败: $e');
      throw Exception('获取当前用户食物数据失败: $e');
    }
  }

  static Future<Map<String, dynamic>> generateDailyRecommendation({
    bool forceRegenerate = false,
  }) async {
    try {
      final response = await _handleRequest(
        ApiConfig.generateDailyRecommendation,
        body: {
          'force_regenerate': forceRegenerate,
        },
      );
      if (response is Map<String, dynamic> && response['meals'] is List) {
        return _adaptV2DailyRecommendation(response);
      }
      throw Exception('Invalid recommendation generate response');
    } catch (e) {
      AppLogger.error('生成当日推荐失败: $e');
      throw Exception('生成当日推荐失败: $e');
    }
  }

  // 鏇挎崲璁″垝涓殑椋熺墿椤?
  static Future<dynamic> replacePlanFood(Map<String, dynamic> request) async {
    print('璇锋眰鍙傛暟: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.replacePlanFood,
        pathParams: {'recommendation_item_id': request['plan_food_id']},
        body: {'food_id': request['food_id']},
      );
      return response;
    } catch (e) {
      print('鏇挎崲璁″垝涓殑椋熺墿椤瑰け璐? $e');
      throw Exception('鏇挎崲璁″垝涓殑椋熺墿椤瑰け璐? $e');
    }
  }

  //鑾峰彇鐢ㄦ埛褰撳ぉ鐨勯ギ椋熻褰?
  static Future<dynamic> getUserTodayMealRecords(
      Map<String, dynamic> request) async {
    print('璇锋眰鍙傛暟: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.getUserTodayMealRecords,
        queryParams: {
          if (request['device_id'] != null)
            'hardware_device_id': request['device_id'],
        },
      );
      if (response is List) {
        return response
            .map((item) => _adaptV2MealRecordSummary(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return response;
    } catch (e) {
      print('鑾峰彇褰撳ぉ楗璁板綍澶辫触: $e');
      throw Exception('鑾峰彇褰撳ぉ楗璁板綍澶辫触: $e');
    }
  }

  //鑾峰彇鐢ㄦ埛褰撳ぉ鐨勯ギ椋熻褰?
  static Future<Map<String, dynamic>?> getLatestMealRecord(
      Map<String, dynamic> request) async {
    try {
      final response = await _handleRequest(
        ApiConfig.getLatestMealRecord,
        queryParams: {
          if (request['device_id'] != null)
            'hardware_device_id': request['device_id'],
        },
      );
      if (response is Map<String, dynamic>) {
        return _adaptV2MealRecordDetail(response);
      }
      return null;
    } catch (e) {
      final errorText = e.toString();
      if (errorText.contains('404') || errorText.contains('资源不存在')) {
        return null;
      }
      throw Exception('获取最新饮食记录失败: $e');
    }
  }

  static Future<dynamic> getMealRecordsDetail(
      Map<String, dynamic> request) async {
    print('璇锋眰鍙傛暟: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.getMealRecordsDetail,
        pathParams: {'meal_record_id': request['meal_record_id']},
      );
      if (response is Map<String, dynamic>) {
        return _adaptV2MealRecordDetail(response);
      }
      return response;
    } catch (e) {
      print('鑾峰彇楗璁板綍璇︽儏澶辫触: $e');
      throw Exception('鑾峰彇楗璁板綍璇︽儏澶辫触: $e');
    }
  }

  // 璁惧鐩稿叧API
  // 缁戝畾璁惧
  static Future<dynamic> bindDevice(String deviceId) async {
    print('缁戝畾璁惧璇锋眰鍙傛暟: {"device_id": "$deviceId"}');
    try {
      final response = await _handleRequest(
        ApiConfig.bindDevice,
        pathParams: {'hardware_device_id': deviceId},
      );
      await getUserDevices();
      print('缁戝畾璁惧鎴愬姛: $response');
      return response;
    } catch (e) {
      print('缁戝畾璁惧澶辫触: $e');
      throw Exception('缁戝畾璁惧澶辫触: $e');
    }
  }

  // 鑾峰彇鐢ㄦ埛缁戝畾鐨勮澶囧垪琛?
  static Future<List<dynamic>> getUserDevices() async {
    try {
      final response = await _handleRequest(
        ApiConfig.getUserDevices,
      );
      print('鑾峰彇鐢ㄦ埛璁惧鍒楄〃鎴愬姛: $response');
      if (response is List) {
        final normalizedDevices = response.map((device) {
          if (device is! Map) return device;
          final raw = device.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          return {
            ...raw,
            'device_id':
                raw['hardware_device_id'] ?? raw['device_id'] ?? '',
            'name': raw['device_name'] ?? raw['name'] ?? 'Unknown device',
          };
        }).toList();
        await UserSession.syncActiveDeviceFromPayload(normalizedDevices);
        return normalizedDevices;
      }
      await UserSession.clearActiveDeviceId();
      return [];
    } catch (e) {
      print('鑾峰彇鐢ㄦ埛璁惧鍒楄〃澶辫触: $e');
      throw Exception('鑾峰彇鐢ㄦ埛璁惧鍒楄〃澶辫触: $e');
    }
  }

  // 瑙ｇ粦璁惧
  static Future<dynamic> unbindDevice(String deviceId) async {
    print('瑙ｇ粦璁惧璇锋眰鍙傛暟: device_id=$deviceId');
    try {
      final response = await _handleRequest(
        ApiConfig.unbindDevice,
        pathParams: {'hardware_device_id': deviceId},
      );
      await getUserDevices();
      print('瑙ｇ粦璁惧鎴愬姛: $response');
      return response;
    } catch (e) {
      print('瑙ｇ粦璁惧澶辫触: $e');
      throw Exception('瑙ｇ粦璁惧澶辫触: $e');
    }
  }

  // 鑾峰彇鍒嗘瀽璇︽儏鍒楄〃
  static Future<List<dynamic>> getRecognitions(
      Map<String, dynamic> params) async {
    try {
      final response = await _handleRequest(
        ApiConfig.getRecognitions,
        queryParams: {
          if (params['date'] != null) 'date': params['date'],
          if (params['device_id'] != null)
            'hardware_device_id': params['device_id'],
        },
      );
      print('获取分析详情列表: $response');
      if (response is List) {
        final recognitions = response;
        print('获取到 ${recognitions.length} 条识别记录');
        return recognitions
            .map((item) => _adaptV2Recognition(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList();
      }
      return [];
    } catch (e) {
      print('获取分析详情列表失败: $e');
      throw Exception('获取分析详情列表失败: $e');
    }
  }

  // 鑾峰彇鏈€鏂颁竴鏉¤瘑鍒褰?
  static Future<Map<String, dynamic>?> getLatestRecognition() async {
    try {
      final deviceId = await UserSession.deviceId;
      final response = await _handleRequest(
        ApiConfig.getLatestRecognition,
        queryParams: {
          if (deviceId != null) 'hardware_device_id': deviceId,
        },
      );
      print('获取最新识别记录: $response');
      if (response is Map<String, dynamic>) {
        return _adaptV2Recognition(response);
      }
      return null;
    } catch (e) {
      final errorText = e.toString();
      if (errorText.contains('404') || errorText.contains('资源不存在')) {
        return null;
      }
      print('获取最新识别记录失败: $e');
      throw Exception('获取最新识别记录失败: $e');
    }
  }

  // 鑾峰彇鐢ㄦ埛璧勬枡
  static Future<Map<String, dynamic>> getUserProfile() async {
    final directResponse = await _handleRequest(ApiConfig.getUserProfile);
    if (directResponse is Map<String, dynamic>) {
      return directResponse;
    }
    return {}; /*

    final userId = await UserSession.userId;
    if (userId == null) {
      throw Exception('鐢ㄦ埛鏈櫥褰?);
    }

    print('鑾峰彇鐢ㄦ埛璧勬枡璇锋眰: user_id=$userId');
    try {
      final response = await _handleRequest(
        ApiConfig.getUserProfile,
        pathParams: {'user_id': userId},
      );
      print('鑾峰彇鐢ㄦ埛璧勬枡鎴愬姛: $response');
      return response;
    } catch (e) {
      print('鑾峰彇鐢ㄦ埛璧勬枡澶辫触: $e');
      throw Exception('鑾峰彇鐢ㄦ埛璧勬枡澶辫触: $e');
    }
    */
  }

  static Map<String, dynamic> _adaptV2DailyRecommendation(
      Map<String, dynamic> response) {
    final recommendationDate =
        (response['recommendation_date'] ?? '').toString().split('T').first;
    final generatedAt =
        (response['generated_at'] ?? '').toString().split('T').first;
    final today = DateTime.now().toIso8601String().split('T').first;
    final meals = response['meals'] as List? ?? const [];

    final mealGroups = meals.map<Map<String, dynamic>>((meal) {
      final mealMap = meal is Map<String, dynamic>
          ? meal
          : Map<String, dynamic>.from(meal as Map);
      final items = mealMap['items'] as List? ?? const [];

      final normalizedFoods = items.map<Map<String, dynamic>>((item) {
        final itemMap = item is Map<String, dynamic>
            ? item
            : Map<String, dynamic>.from(item as Map);
        final quantity =
            (itemMap['quantity_grams'] as num?)?.toDouble() ?? 0.0;
        final itemCalories = (itemMap['calories'] as num?)?.toDouble() ?? 0.0;
        final caloriesPer100g =
            (itemMap['food_calories_per_100g'] as num?)?.toDouble() ??
                (quantity > 0 ? (itemCalories / quantity) * 100.0 : 0.0);

        return {
          'id': itemMap['id'],
          'quantity': quantity,
          'unit': 'g',
          'food': {
            'id': itemMap['food_id'],
            'name': itemMap['food_name'] ?? '',
            'name_en':
                itemMap['food_name_en'] ?? itemMap['display_name'] ?? '',
            'category': itemMap['food_category'] ?? itemMap['item_role'],
            'image_url': itemMap['food_image_url'],
            'calories_per_100g': caloriesPer100g,
          },
        };
      }).toList();

      return {
        'meal_type': (mealMap['meal_type'] ?? '').toString().toUpperCase(),
        'calories': (mealMap['actual_calories'] ??
            mealMap['target_calories'] ??
            0.0),
        'foods': normalizedFoods,
      };
    }).toList();

    return {
      'meal_groups': mealGroups,
      'generated_today': recommendationDate == today || generatedAt == today,
      'recommendation_source': 'generated_from_profile',
    };
  }

  static Map<String, dynamic> _adaptV2Recognition(
      Map<String, dynamic> response) {
    final items = response['items'] as List? ?? const [];
    final foods = items.map<Map<String, dynamic>>((item) {
      final itemMap = item is Map<String, dynamic>
          ? item
          : Map<String, dynamic>.from(item as Map);
      return {
        'quantity': (itemMap['estimated_weight_grams'] as num?)?.toDouble() ?? 0.0,
        'unit': 'g',
        'food': {
          'id': itemMap['food_id'],
          'name': itemMap['food_name'] ?? itemMap['recognized_name'] ?? '',
          'name_en': itemMap['food_name_en'] ?? itemMap['food_name'] ?? '',
          'category': itemMap['food_category'],
          'image_url': itemMap['food_image_url'],
          'calories_per_100g':
              (itemMap['food_calories_per_100g'] as num?)?.toDouble() ?? 0.0,
        },
      };
    }).toList();

    return {
      'id': response['id'],
      'image_url': response['image_url'],
      'status': response['status'] ?? 'completed',
      'session_id': response['meal_session_id'],
      'created_at': response['completed_at'] ?? response['requested_at'],
      'foods': foods,
    };
  }

  static Map<String, dynamic> _adaptV2MealRecordSummary(
      Map<String, dynamic> response) {
    final items = response['items'] as List? ?? const [];
    return {
      'id': response['id'],
      'meal_session_id': response['meal_session_id'],
      'hardware_device_id': response['hardware_device_id'],
      'meal_type': response['meal_type'],
      'start_time': response['start_time'],
      'duration_minutes':
          ((response['duration_seconds'] as num?)?.toDouble() ?? 0.0) / 60.0,
      'total_calories': (response['total_calories'] as num?)?.toDouble() ?? 0.0,
      'image_url': response['image_url'],
      'foods': items
          .map((item) => _adaptV2MealRecordFood(
                item is Map<String, dynamic>
                    ? item
                    : Map<String, dynamic>.from(item as Map),
              ))
          .toList(),
    };
  }

  static Map<String, dynamic> _adaptV2MealRecordDetail(
      Map<String, dynamic> response) {
    final items = response['items'] as List? ?? const [];
    final foods = items
        .map((item) => _adaptV2MealRecordFood(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
            ))
        .toList();

    final totalProtein =
        (response['total_protein_grams'] as num?)?.toDouble() ?? 0.0;
    final totalFat = (response['total_fat_grams'] as num?)?.toDouble() ?? 0.0;
    final totalCarb = (response['total_carb_grams'] as num?)?.toDouble() ?? 0.0;
    final totalFiber = foods.fold<double>(
      0.0,
      (sum, item) =>
          sum + (((item['food'] as Map)['nutrition_per_100g']?['fiber'] as num?)
                      ?.toDouble() ??
                  0.0),
    );
    final hasVegetable = foods.any(
      (item) => ((item['food'] as Map)['category'] ?? '') == 'vegetable',
    );
    final hasProtein = foods.any(
      (item) => ((item['food'] as Map)['category'] ?? '') == 'protein',
    );
    final hasCarb = foods.any(
      (item) => ((item['food'] as Map)['category'] ?? '') == 'carbohydrate',
    );
    final mealScore = hasVegetable && hasProtein && hasCarb ? 8.5 : 6.5;

    final proteinFoods = foods
        .where((item) => ((item['food'] as Map)['category'] ?? '') == 'protein')
        .map((item) => item['food'])
        .toList();
    final highFiberFoods = foods
        .where((item) =>
            ((item['food'] as Map)['category'] ?? '') == 'vegetable' ||
            ((((item['food'] as Map)['nutrition_per_100g']?['fiber'] as num?)
                        ?.toDouble() ??
                    0.0) >
                3.0))
        .map((item) => item['food'])
        .toList();

    return {
      'id': response['id'],
      'image_url': response['image_url'] ?? '',
      'start_time': response['start_time'],
      'duration_minutes':
          ((response['duration_seconds'] as num?)?.toDouble() ?? 0.0) / 60.0,
      'total_calories': (response['total_calories'] as num?)?.toDouble() ?? 0.0,
      'meal_type': response['meal_type'] ?? 'unknown',
      'notes': '',
      'foods': foods,
      'nutritive_proportion': {
        'carbohydrate': totalCarb,
        'protein': totalProtein,
        'fat': totalFat,
        'fiber': totalFiber,
        'vitamins': <dynamic>[],
      },
      'nutrition_analysis': {
        'balanced_meal': hasVegetable && hasProtein && hasCarb,
        'meal_score': mealScore / 10.0,
        'high_quality_protein': proteinFoods,
        'high_fiber': highFiberFoods,
        'low_gi': <dynamic>[],
        'immunity_boosting': <dynamic>[],
        'antioxidant': <dynamic>[],
        'calcium_rich': <dynamic>[],
        'acne_promoting': <dynamic>[],
        'sleep_affecting': <dynamic>[],
      },
      'health_tips': {
        'post_meal_exercise': 'Light walking for 10-15 minutes is recommended.',
        'dietary_suggestions':
            hasVegetable ? 'Keep the current balance and hydration.' : 'Add more vegetables in the next meal.',
        'digestion_note': 'Eat slowly and stay hydrated.',
        'cooking_method_advice': 'Prefer steaming, boiling, or light stir-frying.',
      },
    };
  }

  static Map<String, dynamic> _adaptV2MealRecordFood(
      Map<String, dynamic> item) {
    final quantity = (item['quantity_grams'] as num?)?.toDouble() ?? 0.0;
    final calories = (item['calories'] as num?)?.toDouble() ?? 0.0;
    final caloriesPer100g =
        (item['food_calories_per_100g'] as num?)?.toDouble() ??
            (quantity > 0 ? (calories / quantity) * 100.0 : 0.0);
    final nutritionPer100g = item['food_nutrition_per_100g'] is Map<String, dynamic>
        ? item['food_nutrition_per_100g'] as Map<String, dynamic>
        : <String, dynamic>{};

    return {
      'quantity': quantity,
      'unit': 'g',
      'calories': calories,
      'zone_id': item['zone_index'] ?? 0,
      'supply_proportion': 0.0,
      'food': {
        'id': item['food_id'] ?? 0,
        'name': item['food_name'] ?? item['recognized_name'] ?? '',
        'name_en': item['food_name_en'] ?? item['food_name'] ?? '',
        'image_url': item['food_image_url'] ?? '',
        'description': item['food_description'] ?? '',
        'preparation_method': item['food_preparation_method'] ?? '',
        'category': item['food_category'] ?? '',
        'subcategory': item['food_subcategory'] ?? '',
        'calories_per_100g': caloriesPer100g,
        'nutrition_per_100g': {
          'protein':
              (nutritionPer100g['protein'] as num?)?.toDouble() ?? 0.0,
          'fat': (nutritionPer100g['fat'] as num?)?.toDouble() ?? 0.0,
          'carbohydrate':
              (nutritionPer100g['carbohydrate'] as num?)?.toDouble() ??
                  (nutritionPer100g['carbs'] as num?)?.toDouble() ??
                  0.0,
          'calories':
              (nutritionPer100g['calories'] as num?)?.toDouble() ??
                  caloriesPer100g,
          'fiber':
              (nutritionPer100g['fiber'] as num?)?.toDouble() ?? 0.0,
          'vitamins': <dynamic>[],
        },
      },
    };
  }
}

