import 'package:zenify/services/user_session.dart';
import './api_service.dart';
import './service_config.dart';

class LoginRequest {
  final String name;
  final String email;
  final String fullName;
  final String password;

  const LoginRequest({
    required this.name,
    this.email = '',
    this.fullName = '',
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'full_name': fullName,
        'password': password,
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

class Recipe {
  final String name;
  final String description;
  final int durationDays;
  final String? dietaryRules;
  final bool isPreset;
  final int id;

  Recipe({
    required this.name,
    required this.description,
    required this.durationDays,
    this.dietaryRules,
    required this.isPreset,
    required this.id,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'],
      description: json['description'],
      durationDays: json['duration_days'],
      dietaryRules: json['dietary_rules'],
      isPreset: json['is_preset'],
      id: json['id'],
    );
  }
}

class RecipesRequest {
  final int skip;
  final int limit;
  final bool? isPreset;

  const RecipesRequest({
    required this.skip,
    required this.limit,
    this.isPreset,
  });

  Map<String, dynamic> toJson() => {
        'skip': skip,
        'limit': limit,
        if (isPreset != null) 'is_preset': isPreset,
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
  final DateTime? lastLoginAt;
  final bool isOnline;
  final String name;
  final DateTime createdAt;

  DeviceInfo({
    required this.id,
    required this.deviceId,
    this.lastLoginAt,
    required this.isOnline,
    required this.name,
    required this.createdAt,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['id'] ?? 0,
      deviceId: json['device_id'] ?? '',
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
      isOnline: json['is_online'] ?? false,
      name: json['name'] ?? '未知设备',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class Api {
  // 默认请求头
  static Map<String, String> get _defaultHeaders {
    return {
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'Accept-Charset': 'utf-8',
    };
  }

  // 添加认证头
  static Map<String, String>? _cachedAuthHeaders;
  static Future<Map<String, String>> _getAuthHeaders() async {
    if (_cachedAuthHeaders != null) return _cachedAuthHeaders!;
    final token = await UserSession.token;
    print('Token: $token');
    if (token != null) {
      _cachedAuthHeaders = {
        ..._defaultHeaders,
        'Authorization': 'Bearer $token',
      };
    } else {
      _cachedAuthHeaders = _defaultHeaders;
    }
    return _cachedAuthHeaders!;
  }

  // 统一请求处理
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
      // 如果需要，可以在这里统一处理响应数据
      return response;
    } catch (e) {
      // 统一错误处理
      if (e is! FormatException) {
        rethrow;
      }
      throw Exception('请求处理失败: ${e.message}');
    }
  }

  // 注册
  static Future<dynamic> register(LoginRequest request) async {
    return _handleRequest(
      ApiConfig.register,
      body: request.toJson(),
    );
  }

  // 登录
  static Future<dynamic> login(LoginRequest request) async {
    return _handleRequest(
      ApiConfig.login,
      body: request.toJson(),
    );
  }

  // 获取用户信息
  static Future<dynamic> getUserInfo() async {
    final userId = await UserSession.userId;
    if (userId == null) {
      throw Exception('用户未登录');
    }
    return _handleRequest(
      ApiConfig.userInfo,
      pathParams: {'user_id': userId},
    );
  }

  // 登出
  static Future<dynamic> logout() async {
    await UserSession.clear();
    return true;
  }

  // 获取所有食谱数据
  static Future<List<Recipe>> getRecipes(RecipesRequest request) async {
    print('请求参数: ${request.toJson()}');
    try {
      final dynamic response = await _handleRequest(
        ApiConfig.getRecipes,
        queryParams: request.toJson(),
      );
      if (response is List) {
        return response
            .map<Recipe>(
                (item) => Recipe.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Invalid response format');
    } catch (e) {
      print('获取食谱api失败: $e');
      throw Exception('获取食谱数据失败: $e');
    }
  }

  // 获取食谱数据
  static Future<dynamic> getRecipesById(String id) async {
    try {
      final response = await _handleRequest(
        ApiConfig.getRecipe,
        pathParams: {'recipe_id': id},
      );
      return response;
    } catch (e) {
      print('获取食谱byid失败: $e');
      throw Exception('获取食谱数据失败: $e');
    }
  }

  //新增接口--------------start-------------

  // 获取所有食物列表
  static Future<dynamic> getFoods(FoodsRequest request) async {
    print('请求参数: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.getFoods,
        queryParams: request.toJson(),
      );
      return response;
    } catch (e) {
      print('获取所有食物列表数据失败: $e');
      throw Exception('获取所有食物列表数据失败: $e');
    }
  }

  // 获取当前用户食谱数据
  static Future<Map<String, dynamic>> getCurrentUserRecipes(
      Map<String, dynamic> request) async {
    print('请求参数: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.getCurrentUserRecipes,
        pathParams: request,
      );
      return response;
    } catch (e) {
      print('获取当前用户食谱数据失败: $e');
      throw Exception('获取当前用户食谱数据失败: $e');
    }
  }

  // 获取当前用户食物数据
  static Future<dynamic> getCurrentUserFoods(
      Map<String, dynamic> request) async {
    print('请求参数: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.getCurrentUserFoods,
        pathParams: request,
      );
      return response;
    } catch (e) {
      print('获取当前用户食物数据失败: $e');
      throw Exception('获取当前用户食物数据失败: $e');
    }
  }

  // 修改当前用户食谱
  static Future<dynamic> updateCurrentUserRecipes(
      Map<String, dynamic> request) async {
    print('请求参数: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.updateCurrentUserRecipes,
        pathParams: request,
        queryParams: request,
      );
      return response;
    } catch (e) {
      print('修改当前用户食谱数据失败: $e');
      throw Exception('修改当前用户食谱数据失败: $e');
    }
  }

  // 替换计划中的食物项
  static Future<dynamic> replacePlanFood(Map<String, dynamic> request) async {
    print('请求参数: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.replacePlanFood,
        pathParams: request,
        queryParams: request,
      );
      return response;
    } catch (e) {
      print('替换计划中的食物项失败: $e');
      throw Exception('替换计划中的食物项失败: $e');
    }
  }

  //获取用户当天的饮食记录
  static Future<dynamic> getUserTodayMealRecords(
      Map<String, dynamic> request) async {
    print('请求参数: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.getUserTodayMealRecords,
        pathParams: request,
      );
      return response;
    } catch (e) {
      print('获取当天饮食记录失败: $e');
      throw Exception('获取当天饮食记录失败: $e');
    }
  }

  //获取用户当天的饮食记录
  static Future<dynamic> getMealRecordsDetail(
      Map<String, dynamic> request) async {
    print('请求参数: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.getMealRecordsDetail,
        pathParams: request,
      );
      return response;
    } catch (e) {
      print('获取饮食记录详情失败: $e');
      throw Exception('获取饮食记录详情失败: $e');
    }
  }

  //获取图像识别结果（会耗费很多时间）
  static Future<dynamic> getRecognize(
      Map<String, dynamic> request, Map<String, dynamic> params) async {
    print('请求参数: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.getRecognize,
        pathParams: request,
        body: params,
      );
      return response;
    } catch (e) {
      print('获取图像识别结果（会耗费很多时间）失败: $e');
      throw Exception('获取图像识别结果（会耗费很多时间）失败: $e');
    }
  }

  // //ai机器人
  // static Future<dynamic> chartToAi(List request) async {
  //   print('请求参数: $request');
  //   try {
  //     final response = await _handleRequest(
  //       ApiConfig.aiChart,
  //       body: request,
  //     );
  //     print('chartToAi: $response');
  //     return response;
  //   } catch (e) {
  //     print('获取ai机器人消息失败: $e');
  //     throw Exception('获取ai机器人消息失败: $e');
  //   }
  // }

  //整餐切换
  static Future<dynamic> replaceFoods(
      Map<String, dynamic> request, Map<String, dynamic> body) async {
    print('请求参数: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.replaceFoods,
        pathParams: request,
        body: body,
      );
      print('replaceFoods: $response');
      return response;
    } catch (e) {
      print('整餐切换失败: $e');
      throw Exception('整餐切换失败: $e');
    }
  }

  // 设备相关API
  // 绑定设备
  static Future<dynamic> bindDevice(String deviceId) async {
    print('绑定设备请求参数: {"device_id": "$deviceId"}');
    try {
      final response = await _handleRequest(
        ApiConfig.bindDevice,
        body: {'device_id': deviceId},
      );
      print('绑定设备成功: $response');
      return response;
    } catch (e) {
      print('绑定设备失败: $e');
      throw Exception('绑定设备失败: $e');
    }
  }

  // 获取用户绑定的设备列表
  static Future<List<dynamic>> getUserDevices() async {
    try {
      final response = await _handleRequest(
        ApiConfig.getUserDevices,
      );
      print('获取用户设备列表成功: $response');
      if (response is List) {
        return response;
      }
      return [];
    } catch (e) {
      print('获取用户设备列表失败: $e');
      throw Exception('获取用户设备列表失败: $e');
    }
  }

  // 解绑设备
  static Future<dynamic> unbindDevice(String deviceId) async {
    print('解绑设备请求参数: device_id=$deviceId');
    try {
      final response = await _handleRequest(
        ApiConfig.unbindDevice,
        body: {'device_id': deviceId},
      );
      print('解绑设备成功: $response');
      return response;
    } catch (e) {
      print('解绑设备失败: $e');
      throw Exception('解绑设备失败: $e');
    }
  }

  // 获取分析详情列表
  static Future<List<dynamic>> getRecognitions(params) async {
    try {
      final response = await _handleRequest(
        ApiConfig.getRecognitions,
        queryParams: params,
      );
      print('获取分析详情列表: $response');
      if (response is Map && response['success'] == true) {
        final recognitions = response['recognitions'] as List? ?? [];
        print('获取到${recognitions.length}条识别记录');
        return recognitions;
      }
      return [];
    } catch (e) {
      print('获取分析详情列表失败: $e');
      throw Exception('获取分析详情列表失败: $e');
    }
  }

  // 获取最新一条识别记录
  static Future<Map<String, dynamic>?> getLatestRecognition() async {
    try {
      final userId = await UserSession.userId;
      final response = await _handleRequest(
        ApiConfig.getLatestRecognition,
        queryParams: {'user_id': userId},
      );
      print('获取最新识别记录: $response');
      if (response is Map && response['success'] == true) {
        final mealRecord = response['meal_record'] as Map<String, dynamic>?;
        return mealRecord;
      }
      return null;
    } catch (e) {
      print('获取最新识别记录失败: $e');
      throw Exception('获取最新识别记录失败: $e');
    }
  }
}
