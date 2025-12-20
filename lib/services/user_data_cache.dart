import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataCache {
  static const String _userProfileKey = 'user_profile_cache';
  static const String _onboardingCompleteKey = 'onboarding_complete';

  /// 保存用户资料到缓存
  static Future<void> saveUserProfile({
    String? gender,
    String? weight,
    String? height,
    String? age,
    String? mainGoal,
    String? chronicDisease,
    String? preference,
    String? foodSource,
    String? foodDislikes,
    String? eatingStyle,
    String? eatingRoutine,
    String? allergies,
    String? activityLevel,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 获取现有数据
      final existingData = await getUserProfile();
      
      // 合并新数据
      final updatedData = {
        ...existingData,
        if (gender != null) 'gender': gender,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (age != null) 'age': age,
        if (mainGoal != null) 'main_goal': mainGoal,
        if (chronicDisease != null) 'chronic_disease': chronicDisease,
        if (preference != null) 'preference': preference,
        if (foodSource != null) 'food_source': foodSource,
        if (foodDislikes != null) 'food_dislikes': foodDislikes,
        if (eatingStyle != null) 'eating_style': eatingStyle,
        if (eatingRoutine != null) 'eating_routine': eatingRoutine,
        if (allergies != null) 'allergies': allergies,
        if (activityLevel != null) 'activity_level': activityLevel,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // 保存到缓存
      await prefs.setString(_userProfileKey, jsonEncode(updatedData));
      print('用户资料已缓存: $updatedData');
    } catch (e) {
      print('保存用户资料到缓存失败: $e');
      throw Exception('保存用户资料到缓存失败: $e');
    }
  }

  /// 获取缓存中的用户资料
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_userProfileKey);
      
      if (cachedData != null) {
        final userData = jsonDecode(cachedData) as Map<String, dynamic>;
        print('获取缓存中的用户资料: $userData');
        return userData;
      }
      
      return {};
    } catch (e) {
      print('获取缓存中的用户资料失败: $e');
      return {};
    }
  }

  /// 清除所有缓存数据
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userProfileKey);
      await prefs.remove(_onboardingCompleteKey);
      print('用户缓存数据已清除');
    } catch (e) {
      print('清除缓存数据失败: $e');
    }
  }

  /// 标记引导流程完成
  static Future<void> markOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompleteKey, true);
      print('引导流程已完成');
    } catch (e) {
      print('标记引导流程完成失败: $e');
    }
  }

  /// 检查引导流程是否完成
  static Future<bool> isOnboardingComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompleteKey) ?? false;
    } catch (e) {
      print('检查引导流程状态失败: $e');
      return false;
    }
  }

  /// 获取完整的用户数据（包含所有缓存的数据）
  static Future<Map<String, dynamic>> getAllUserData() async {
    try {
      final profileData = await getUserProfile();
      final isComplete = await isOnboardingComplete();
      
      return {
        ...profileData,
        'onboarding_complete': isComplete,
        'cached_at': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('获取完整用户数据失败: $e');
      return {};
    }
  }

  /// 检查是否有缓存的用户数据
  static Future<bool> hasCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userProfileKey);
    } catch (e) {
      print('检查缓存数据失败: $e');
      return false;
    }
  }
}