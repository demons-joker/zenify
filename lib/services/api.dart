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

class RecipesRequest {
  final int skip;
  final int limit;
  final bool isPreset;

  const RecipesRequest({
    required this.skip,
    required this.limit,
    required this.isPreset,
  });

  Map<String, dynamic> toJson() => {
        'skip': skip,
        'limit': limit,
        'is_preset': isPreset,
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
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await UserSession.token;
    if (token != null) {
      return {
        ..._defaultHeaders,
        'Authorization': 'Bearer $token',
      };
    }
    return _defaultHeaders;
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
  static Future<dynamic> getRecipes(RecipesRequest request) async {
    print('请求参数: ${request.toJson()}');
    try {
      final response = await _handleRequest(
        ApiConfig.getRecipes,
        queryParams: request.toJson(),
      );
      return response;
    } catch (e) {
      print('获取食谱失败: $e');
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
      print('获取食谱失败: $e');
      throw Exception('获取食谱数据失败: $e');
    }
  }

  //新增接口--------------start-------------

  // 获取当前用户食谱数据

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

  //获取用户当天的饮食记录
  static Future<Map<String, dynamic>> getUserTodayMealRecords(
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
}
