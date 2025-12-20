import 'package:shared_preferences/shared_preferences.dart';
import 'user_data_cache.dart';
import 'user_profile_service.dart';
import 'user_session.dart';

/// 用户数据同步服务
/// 负责将本地缓存的数据同步到服务端
class UserDataSyncService {
  /// 同步所有用户数据到服务端
  /// 在用户完成所有信息收集后调用
  static Future<bool> syncAllUserData() async {
    try {
      // 1. 检查用户登录状态
      final userId = await UserSession.userId;
      if (userId == null) {
        print('用户未登录，无法同步数据');
        return false;
      }

      // 2. 获取所有缓存数据
      final allUserData = await UserDataCache.getAllUserData();
      if (allUserData.isEmpty) {
        print('没有缓存数据需要同步');
        return true;
      }

      print('开始同步用户数据到服务端: $allUserData');

      // 3. 同步用户基本信息资料
      final profileData = await UserDataCache.getUserProfile();
      if (profileData.isNotEmpty) {
        await UserProfileService.createOrUpdateUserProfile(
          userId,
          gender: profileData['gender'] as String? ?? '',
          weight: int.parse(profileData['weight'] as String? ?? '0'),
          height: int.parse(profileData['height'] as String? ?? '0'),
          age: int.parse(profileData['age'] as String? ?? '0'),
        );
        print('用户基本信息同步成功');
      }

      // 4. 同步其他用户数据（可根据后续需求扩展）
      // 例如：目标选择、健康信息、饮食偏好等
      // await _syncUserGoals(userId, allUserData);
      // await _syncHealthInfo(userId, allUserData);
      // await _syncDietaryPreferences(userId, allUserData);

      // 5. 标记引导流程完成
      await UserDataCache.markOnboardingComplete();
      print('用户引导流程标记为完成');

      // 6. 可选：清除缓存（或保留用于后续离线访问）
      // await UserDataCache.clearCache();

      print('所有用户数据同步完成');
      return true;
    } catch (e) {
      print('同步用户数据失败: $e');
      return false;
    }
  }

  /// 检查是否需要同步数据
  static Future<bool> needsSync() async {
    try {
      final hasCachedData = await UserDataCache.hasCachedData();
      final isOnboardingComplete = await UserDataCache.isOnboardingComplete();
      final isLoggedIn = await UserSession.isLoggedIn();

      return hasCachedData && !isOnboardingComplete && isLoggedIn;
    } catch (e) {
      print('检查同步状态失败: $e');
      return false;
    }
  }

  /// 强制重新同步所有数据
  static Future<bool> forceResync() async {
    try {
      // 重置完成状态
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('onboarding_complete');

      // 重新同步
      return await syncAllUserData();
    } catch (e) {
      print('强制重新同步失败: $e');
      return false;
    }
  }

  /// 获取同步状态信息
  static Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final hasCachedData = await UserDataCache.hasCachedData();
      final isOnboardingComplete = await UserDataCache.isOnboardingComplete();
      final isLoggedIn = await UserSession.isLoggedIn();
      final userData = await UserDataCache.getAllUserData();

      return {
        'has_cached_data': hasCachedData,
        'is_onboarding_complete': isOnboardingComplete,
        'is_logged_in': isLoggedIn,
        'needs_sync': hasCachedData && !isOnboardingComplete && isLoggedIn,
        'cached_data_count': userData.length,
        'last_updated': userData['updated_at'],
      };
    } catch (e) {
      print('获取同步状态失败: $e');
      return {};
    }
  }
}
