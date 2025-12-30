import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenify/services/api.dart';

class UserSession {
  static const String _tokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _userIdKey = 'user_id';
  static const String _nameKey = 'name';
  static const String _emailKey = 'email';
  static const String _fullNameKey = 'full_name';
  static const String _phoneKey = 'phone';
  static const String _sourceKey = 'source';
  static const String _createdAtKey = 'created_at';
  static const String _isActiveKey = 'is_active';
  static const String _plateIdKey = 'plate_id';

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
    await prefs.setString(_phoneKey, userInfo['phone'] ?? '');
    await prefs.setString(_sourceKey, userInfo['source'] ?? '');
    await prefs.setString(_createdAtKey, userInfo['created_at'] ?? '');
    await prefs.setBool(_isActiveKey, userInfo['is_active'] ?? false);

    // 保存 device_ids 中的第一个值为 plate_id
    final deviceIds = userInfo['device_ids'];
    if (deviceIds != null && deviceIds is List && deviceIds.isNotEmpty) {
      await prefs.setInt(_plateIdKey, deviceIds[0]);
    }
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

  // 获取手机号
  static Future<String?> get phone async {
    final prefs = await _prefs;
    return prefs.getString(_phoneKey);
  }

  // 获取来源
  static Future<String?> get source async {
    final prefs = await _prefs;
    return prefs.getString(_sourceKey);
  }

  // 获取创建时间
  static Future<String?> get createdAt async {
    final prefs = await _prefs;
    return prefs.getString(_createdAtKey);
  }

  // 获取账号状态
  static Future<bool?> get isActive async {
    final prefs = await _prefs;
    return prefs.getBool(_isActiveKey);
  }

  // 获取 plate_id
  static Future<int?> get plateId async {
    final prefs = await _prefs;
    return prefs.getInt(_plateIdKey);
  }

  // 获取完整用户信息
  static Future<UserInfo?> getUserInfo() async {
    final prefs = await _prefs;
    if (!prefs.containsKey(_userIdKey)) return null;

    final createdAtString = prefs.getString(_createdAtKey);
    DateTime createdAt;
    try {
      createdAt = createdAtString != null ? DateTime.parse(createdAtString) : DateTime.now();
    } catch (e) {
      createdAt = DateTime.now();
    }

    return UserInfo(
      id: prefs.getInt(_userIdKey) ?? 0,
      name: prefs.getString(_nameKey) ?? '',
      email: prefs.getString(_emailKey) ?? '',
      phone: prefs.getString(_phoneKey) ?? '',
      fullName: prefs.getString(_fullNameKey) ?? '',
      source: prefs.getString(_sourceKey) ?? '',
      createdAt: createdAt,
      isActive: prefs.getBool(_isActiveKey) ?? false,
      devices: [], // 本地存储不包含设备信息，从服务器获取
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
    await prefs.remove(_plateIdKey);
  }

  // 检查是否已登录
  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.containsKey(_tokenKey) && prefs.containsKey(_userIdKey);
  }
}
