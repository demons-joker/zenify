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
  final String fullName;
  final bool isActive;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.fullName,
    required this.isActive,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      isActive: json['is_active'] ?? json['isActive'] ?? false,
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
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? header,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await ApiService.request(
        endpoint,
        body: body,
        queryParams: queryParams,
        pathParams: pathParams,
        headers: {...headers, ...?header},
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
    print('$userId,用户未登录');
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

  // 替换食谱中的食物项
  static Future<dynamic> replaceRecipeFood(Map<String, dynamic> request) async {
    print('请求参数: $request');
    try {
      final response = await _handleRequest(
        ApiConfig.replaceRecipeFood,
        pathParams: request,
        queryParams: request,
      );
      return response;
    } catch (e) {
      print('替换食谱中的食物项失败: $e');
      throw Exception('替换食谱中的食物项失败: $e');
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
        queryParams: params,
      );
      return response;
    } catch (e) {
      print('获取图像识别结果（会耗费很多时间）失败: $e');
      throw Exception('获取图像识别结果（会耗费很多时间）失败: $e');
    }
  }
}
