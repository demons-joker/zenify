import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenify/services/api.dart';

class UserSession {
  static const String _tokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userIdKey = 'user_id';
  static const String _nameKey = 'name';
  static const String _emailKey = 'email';
  static const String _fullNameKey = 'full_name';
  static const String _isActiveKey = 'is_active';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  // 保存登录响应数据
  static Future<void> saveLoginResponse(Map<String, dynamic> response) async {
    final prefs = await _prefs;
    final token = response['access_token'];
    final tokenType = response['token_type'];
    final userInfo = response['user_info'] ?? {};

    await prefs.setString(_tokenKey, token);
    await prefs.setString(_tokenTypeKey, tokenType);
    await prefs.setInt(_userIdKey, userInfo['id'] ?? 0);
    await prefs.setString(_nameKey, userInfo['name'] ?? '');
    await prefs.setString(_emailKey, userInfo['email'] ?? '');
    await prefs.setString(_fullNameKey, userInfo['full_name'] ?? '');
    await prefs.setBool(_isActiveKey, userInfo['is_active'] ?? false);
  }

  // 获取访问令牌
  static Future<String?> get token async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  // 获取令牌类型
  static Future<String?> get tokenType async {
    final prefs = await _prefs;
    return prefs.getString(_tokenTypeKey);
  }

  // 获取用户ID
  static Future<int?> get userId async {
    final prefs = await _prefs;
    return prefs.getInt(_userIdKey);
  }

  // 获取用户名
  static Future<String?> get name async {
    final prefs = await _prefs;
    return prefs.getString(_nameKey);
  }

  // 获取邮箱
  static Future<String?> get email async {
    final prefs = await _prefs;
    return prefs.getString(_emailKey);
  }

  // 获取全名
  static Future<String?> get fullName async {
    final prefs = await _prefs;
    return prefs.getString(_fullNameKey);
  }

  // 获取账号状态
  static Future<bool?> get isActive async {
    final prefs = await _prefs;
    return prefs.getBool(_isActiveKey);
  }

  // 获取完整用户信息
  static Future<UserInfo?> getUserInfo() async {
    final prefs = await _prefs;
    if (!prefs.containsKey(_userIdKey)) return null;

    return UserInfo(
      id: prefs.getInt(_userIdKey) ?? 0,
      name: prefs.getString(_nameKey) ?? '',
      email: prefs.getString(_emailKey) ?? '',
      fullName: prefs.getString(_fullNameKey) ?? '',
      isActive: prefs.getBool(_isActiveKey) ?? false,
    );
  }

  // 清除所有会话数据
  static Future<void> clear() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_isActiveKey);
  }

  // 检查是否已登录
  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.containsKey(_tokenKey) && prefs.containsKey(_userIdKey);
  }
}
