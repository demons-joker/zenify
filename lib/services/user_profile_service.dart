import '../services/service_config.dart';
import '../services/api_service.dart';

class UserProfileService {
  /// 创建或更新用户资料
  static Future<dynamic> createOrUpdateUserProfile(
    int userId, {
    required String gender,
    required int weight,
    required int height,
    required int age,
  }) async {
    try {
      final userData = {
        'gender': gender,
        'weight': weight,
        'height': height,
        'age': age,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await ApiService.request(
        ApiConfig.createOrUpdateUserProfile,
        pathParams: {'user_id': userId},
        body: userData,
      );

      print('用户资料保存成功: $userData');
      return response;
    } catch (e) {
      print('保存用户资料失败: $e');
      throw Exception('保存用户资料失败: $e');
    }
  }

  /// 获取用户资料
  static Future<dynamic> getUserProfile(String userId) async {
    try {
      final response = await ApiService.request(
        ApiConfig.getUserProfile,
        pathParams: {'user_id': userId},
      );

      print('获取用户资料成功: $response');
      return response;
    } catch (e) {
      print('获取用户资料失败: $e');
      throw Exception('获取用户资料失败: $e');
    }
  }

  /// 更新用户资料
  static Future<dynamic> updateUserProfile(
    int userId, {
    String? gender,
    int? weight,
    int? height,
    int? age,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (gender != null) updateData['gender'] = gender;
      if (weight != null) updateData['weight'] = weight;
      if (height != null) updateData['height'] = height;
      if (age != null) updateData['age'] = age;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await ApiService.request(
        ApiConfig.updateUserProfile,
        pathParams: {'user_id': userId},
        body: updateData,
      );

      print('用户资料更新成功: $updateData');
      return response;
    } catch (e) {
      print('更新用户资料失败: $e');
      throw Exception('更新用户资料失败: $e');
    }
  }
}
