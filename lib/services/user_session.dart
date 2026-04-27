import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenify/services/api.dart';
import 'dart:convert';

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
  static const String _deviceIdKey = 'device_id';
  static const String _deviceTypeKey = 'device_type';
  static const String _deviceCapabilitiesKey = 'device_capability_flags';

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

    // 登录返回的 device_ids 为对外 device_id 字符串列表；取第一个作为当前活跃设备
    final deviceIds = userInfo['device_ids'];
    if (deviceIds != null && deviceIds is List && deviceIds.isNotEmpty) {
      final first = deviceIds.first;
      await prefs.setString(
        _deviceIdKey,
        first is String ? first : first.toString(),
      );
    }
  }

  /// 绑定后或拉取用户信息后，将当前用于 API 路径的设备对外 ID 写入本地。
  static Future<void> setActiveDeviceId(String deviceId) async {
    final prefs = await _prefs;
    await prefs.setString(_deviceIdKey, deviceId);
  }

  static Future<void> setActiveDeviceContext(
    String deviceId, {
    String? deviceType,
    Map<String, dynamic>? capabilityFlags,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_deviceIdKey, deviceId);
    if (deviceType != null) {
      await prefs.setString(_deviceTypeKey, deviceType);
    }
    if (capabilityFlags != null) {
      await prefs.setString(_deviceCapabilitiesKey, jsonEncode(capabilityFlags));
    }
  }

  static Future<void> clearActiveDeviceId() async {
    final prefs = await _prefs;
    await prefs.remove(_deviceIdKey);
    await prefs.remove(_deviceTypeKey);
    await prefs.remove(_deviceCapabilitiesKey);
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

  /// 当前活跃设备的对外 `device_id`（与后端路径 `/devices/{device_id}/...` 一致）。
  static Future<String?> get deviceId async {
    final prefs = await _prefs;
    return prefs.getString(_deviceIdKey);
  }

  static Future<String?> get deviceType async {
    final prefs = await _prefs;
    return prefs.getString(_deviceTypeKey);
  }

  static Future<Map<String, dynamic>?> get deviceCapabilityFlags async {
    final prefs = await _prefs;
    final raw = prefs.getString(_deviceCapabilitiesKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> get activeDeviceSupportsWeight async {
    final flags = await deviceCapabilityFlags;
    if (flags != null && flags.containsKey('supports_weight')) {
      return flags['supports_weight'] == true;
    }
    final type = await deviceType;
    return type == null || type == 'smart_plate';
  }

  static Future<bool> get activeDeviceSupportsImageUpload async {
    final flags = await deviceCapabilityFlags;
    if (flags != null && flags.containsKey('supports_image_upload')) {
      return flags['supports_image_upload'] == true;
    }
    return true;
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
    await prefs.remove(_deviceIdKey);
    await prefs.remove(_deviceTypeKey);
    await prefs.remove(_deviceCapabilitiesKey);
  }

  // 检查是否已登录
  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.containsKey(_tokenKey) && prefs.containsKey(_userIdKey);
  }
}
