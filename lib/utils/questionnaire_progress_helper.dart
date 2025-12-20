import '../services/user_data_cache.dart';

/// QuestionnaireProgressHelper - 动态计算问卷进度条的工具类
/// 
/// 根据用户选择的目标（如慢性病）动态计算当前步骤、总步骤数和进度值
class QuestionnaireProgressHelper {
  // 定义各问卷页面的基础步骤顺序
  static const List<String> _baseQuestionnaireFlow = [
    'userProfile',        // 1. 基本信息（年龄、体重等）
    'goalSelection',      // 2. 目标选择
    'preference',         // 3. 偏好选择
    'foodSource',         // 4. 食物来源
    'foodDislike',        // 5. 食物不喜欢
    'eatingStyle',        // 6. 饮食风格
    'eatingRoutine',      // 7. 饮食规律
    'allergy',            // 8. 过敏信息
    'activityLevel',      // 9. 活动水平
    'registrationComplete' // 10. 完成页面
  ];

  // 慢性病路径特有的额外步骤
  static const List<String> _chronicDiseaseSteps = [
    'chronicDisease',     // 慢性病详情页（在目标选择后插入）
  ];

  /// 获取完整的问卷流程列表
  static Future<List<String>> _getFullQuestionnaireFlow() async {
    final cachedData = await UserDataCache.getUserProfile();
    final mainGoal = cachedData['main_goal'] as String?;
    
    List<String> fullFlow = List.from(_baseQuestionnaireFlow);
    
    // 如果是慢性病路径，在目标选择后插入慢性病步骤
    if (mainGoal == 'Chronic Disease') {
      int insertIndex = fullFlow.indexOf('goalSelection') + 1;
      fullFlow.insertAll(insertIndex, _chronicDiseaseSteps);
    }
    
    return fullFlow;
  }

  /// 根据当前页面ID计算进度信息
  static Future<ProgressInfo> calculateProgress(String currentPageId) async {
    final fullFlow = await _getFullQuestionnaireFlow();
    final currentIndex = fullFlow.indexOf(currentPageId);
    
    if (currentIndex == -1) {
      // 如果找不到页面，返回默认值
      return ProgressInfo(
        currentStep: 1,
        totalSteps: 10,
        progressValue: 0.1,
      );
    }
    
    final currentStep = currentIndex + 1;
    final totalSteps = fullFlow.length;
    final progressValue = currentStep / totalSteps;
    
    return ProgressInfo(
      currentStep: currentStep,
      totalSteps: totalSteps,
      progressValue: progressValue,
    );
  }

  /// 检查是否为慢性病路径
  static Future<bool> isChronicDiseaseRoute() async {
    final cachedData = await UserDataCache.getUserProfile();
    final mainGoal = cachedData['main_goal'] as String?;
    return mainGoal == 'Chronic Disease';
  }

  /// 获取指定步骤的页面ID（用于导航等场景）
  static Future<String?> getPageIdByStep(int stepNumber) async {
    final fullFlow = await _getFullQuestionnaireFlow();
    if (stepNumber > 0 && stepNumber <= fullFlow.length) {
      return fullFlow[stepNumber - 1];
    }
    return null;
  }
}

/// 进度信息数据类
class ProgressInfo {
  final int currentStep;
  final int totalSteps;
  final double progressValue;

  const ProgressInfo({
    required this.currentStep,
    required this.totalSteps,
    required this.progressValue,
  });

  @override
  String toString() {
    return 'ProgressInfo(currentStep: $currentStep, totalSteps: $totalSteps, progressValue: $progressValue)';
  }
}