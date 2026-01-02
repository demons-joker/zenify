import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataCache {
  static const String _userProfileKey = 'user_profile_cache';
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _collectedMealsKey = 'collected_meals';

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

  /// 保存收藏的餐食（单个食物）
  static Future<void> saveCollectedMeal(Map<String, dynamic> mealData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final collectedMeals = await getCollectedMeals();

      // 检查是否已经收藏过该食物（根据food_id）
      final foodId = mealData['food_id']?.toString();
      final existingIndex = collectedMeals.indexWhere((meal) =>
          meal['food_id']?.toString() == foodId);

      if (existingIndex == -1) {
        // 添加新收藏
        collectedMeals.add({
          ...mealData,
          'collected_at': DateTime.now().toIso8601String(),
        });
        await prefs.setString(_collectedMealsKey, jsonEncode(collectedMeals));
        print('餐食已收藏: $mealData');
      }
    } catch (e) {
      print('保存收藏餐食失败: $e');
      throw Exception('保存收藏餐食失败: $e');
    }
  }

  /// 移除收藏的餐食（移除该日期和餐食类型对应的所有食物）
  static Future<void> removeCollectedMeal(String date, String mealType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final collectedMeals = await getCollectedMeals();

      collectedMeals.removeWhere((meal) =>
          meal['date'] == date && meal['meal_type'] == mealType);

      await prefs.setString(_collectedMealsKey, jsonEncode(collectedMeals));
      print('餐食已取消收藏: $date - $mealType');
    } catch (e) {
      print('移除收藏餐食失败: $e');
    }
  }

  /// 获取所有收藏的餐食
  static Future<List<Map<String, dynamic>>> getCollectedMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_collectedMealsKey);

      if (cachedData != null) {
        final meals = jsonDecode(cachedData) as List;
        return meals.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      print('获取收藏餐食失败: $e');
      return [];
    }
  }

  /// 检查指定餐食是否已收藏
  static Future<bool> isMealCollected(String date, String mealType) async {
    try {
      final collectedMeals = await getCollectedMeals();
      return collectedMeals.any((meal) =>
          meal['date'] == date && meal['meal_type'] == mealType);
    } catch (e) {
      print('检查餐食收藏状态失败: $e');
      return false;
    }
  }
}