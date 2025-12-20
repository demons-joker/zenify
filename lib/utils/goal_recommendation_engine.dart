import 'package:zenify/models/health_goal_model.dart';
import 'package:zenify/models/registration_state.dart';
import 'package:zenify/utils/questionnaire_utils.dart';

/// Health goal recommendation engine
class GoalRecommendationEngine {
  /// Generate personalized health goals based on user profile
  static List<HealthGoalModel> recommendGoals({
    required DateTime birthDate,
    required String? gender,
    required Map<String, dynamic>? questionnaireData,
  }) {
    final goals = <HealthGoalModel>[];
    final age = QuestionnaireUtils.calculateAge(birthDate);
    final category = QuestionnaireUtils.determineCategory(birthDate, gender);

    // Age-based recommendations
    _addAgeBasedGoals(goals, age, category, gender);

    // Gender-specific recommendations
    _addGenderSpecificGoals(goals, gender, age);

    // Questionnaire-based enhancements
    if (questionnaireData != null && questionnaireData.isNotEmpty) {
      _addQuestionnaireBasedGoals(goals, questionnaireData, age);
    }

    // Remove duplicates and limit to 5 goals
    final uniqueGoals = <String, HealthGoalModel>{};
    for (var goal in goals) {
      uniqueGoals[goal.id] = goal;
    }

    return uniqueGoals.values.toList().take(5).toList();
  }

  /// Add age-based health goals
  static void _addAgeBasedGoals(
    List<HealthGoalModel> goals,
    int age,
    QuestionnaireCategory category,
    String? gender,
  ) {
    if (age <= 12) {
      // Child goals
      goals.addAll([
        HealthGoalModel(
          id: 'growth_promotion',
          name: '促进身高增长',
          description: '补充营养，促进骨骼健康发育',
          priority: GoalPriority.high,
          category: 'nutrition',
          icon: '🌱',
        ),
        HealthGoalModel(
          id: 'picky_eating',
          name: '改善挑食习惯',
          description: '扩大食物种类，均衡营养摄入',
          priority: GoalPriority.high,
          category: 'nutrition',
          icon: '🥗',
        ),
        HealthGoalModel(
          id: 'regular_exercise',
          name: '坚持规律运动',
          description: '每天至少1小时户外活动',
          priority: GoalPriority.medium,
          category: 'exercise',
          icon: '🏃',
        ),
        HealthGoalModel(
          id: 'good_sleep',
          name: '保证充足睡眠',
          description: '每天8-10小时睡眠时间',
          priority: GoalPriority.high,
          category: 'health',
          icon: '😴',
        ),
        HealthGoalModel(
          id: 'eye_care',
          name: '保护视力',
          description: '控制电子产品使用时间',
          priority: GoalPriority.medium,
          category: 'health',
          icon: '👁️',
        ),
      ]);
    } else if (age <= 18) {
      // Teen goals
      goals.addAll([
        HealthGoalModel(
          id: 'bone_health',
          name: '骨骼健康建设',
          description: '青春期是骨骼发育关键期，需充分钙摄入',
          priority: GoalPriority.high,
          category: 'nutrition',
          icon: '🦴',
        ),
        HealthGoalModel(
          id: 'screen_time',
          name: '控制屏幕时间',
          description: '减少电子产品使用，保护眼睛',
          priority: GoalPriority.high,
          category: 'health',
          icon: '📱',
        ),
        HealthGoalModel(
          id: 'stress_management',
          name: '学会压力管理',
          description: '学业压力大，需要学会放松和释压',
          priority: GoalPriority.medium,
          category: 'health',
          icon: '🧘',
        ),
        HealthGoalModel(
          id: 'healthy_diet',
          name: '养成健康饮食',
          description: '避免过多零食和垃圾食品',
          priority: GoalPriority.medium,
          category: 'nutrition',
          icon: '🥗',
        ),
        HealthGoalModel(
          id: 'regular_sport',
          name: '参与运动活动',
          description: '每周至少3次运动，强健体魄',
          priority: GoalPriority.medium,
          category: 'exercise',
          icon: '⚽',
        ),
      ]);
    } else if (age <= 45) {
      // Adult goals
      if (gender == 'male') {
        goals.addAll([
          HealthGoalModel(
            id: 'work_balance',
            name: '工作生活平衡',
            description: '减少工作压力，保留充足休息时间',
            priority: GoalPriority.high,
            category: 'health',
            icon: '⚖️',
          ),
          HealthGoalModel(
            id: 'fitness_routine',
            name: '建立健身习惯',
            description: '每周3-5次有氧和力量训练',
            priority: GoalPriority.medium,
            category: 'exercise',
            icon: '💪',
          ),
          HealthGoalModel(
            id: 'heart_health',
            name: '心血管健康',
            description: '定期体检，控制血压和血脂',
            priority: GoalPriority.high,
            category: 'health',
            icon: '❤️',
          ),
          HealthGoalModel(
            id: 'nutrition_balance',
            name: '均衡营养摄入',
            description: '合理控制蛋白质、脂肪、碳水化合物',
            priority: GoalPriority.medium,
            category: 'nutrition',
            icon: '🥘',
          ),
          HealthGoalModel(
            id: 'stress_relief',
            name: '释放压力',
            description: '冥想、瑜伽或户外活动来缓解压力',
            priority: GoalPriority.medium,
            category: 'health',
            icon: '🌳',
          ),
        ]);
      } else {
        // Female-specific goals
        goals.addAll([
          HealthGoalModel(
            id: 'hormone_balance',
            name: '激素平衡',
            description: '维持月经规律，关注女性激素健康',
            priority: GoalPriority.high,
            category: 'health',
            icon: '🌸',
          ),
          HealthGoalModel(
            id: 'fitness_routine',
            name: '规律健身',
            description: '每周3-5次适度运动，保持身材',
            priority: GoalPriority.medium,
            category: 'exercise',
            icon: '🧘‍♀️',
          ),
          HealthGoalModel(
            id: 'skin_care',
            name: '皮肤护理',
            description: '充足睡眠、防晒和补水保养',
            priority: GoalPriority.medium,
            category: 'health',
            icon: '✨',
          ),
          HealthGoalModel(
            id: 'work_balance',
            name: '工作生活平衡',
            description: '管理工作压力，保持身心健康',
            priority: GoalPriority.high,
            category: 'health',
            icon: '⚖️',
          ),
          HealthGoalModel(
            id: 'nutrition_iron',
            name: '铁质摄入',
            description: '预防贫血，保证充足的铁元素摄入',
            priority: GoalPriority.medium,
            category: 'nutrition',
            icon: '🥩',
          ),
        ]);
      }
    } else if (age <= 65) {
      // Middle age goals
      goals.addAll([
        HealthGoalModel(
          id: 'chronic_disease_management',
          name: '慢性病管理',
          description: '定期检查，控制高血压、糖尿病等',
          priority: GoalPriority.high,
          category: 'health',
          icon: '💊',
        ),
        HealthGoalModel(
          id: 'weight_management',
          name: '体重管理',
          description: '保持理想体重，预防肥胖',
          priority: GoalPriority.medium,
          category: 'nutrition',
          icon: '⚖️',
        ),
        HealthGoalModel(
          id: 'moderate_exercise',
          name: '适度运动',
          description: '每周150分钟中等强度运动',
          priority: GoalPriority.high,
          category: 'exercise',
          icon: '🚴',
        ),
        HealthGoalModel(
          id: 'sleep_quality',
          name: '改善睡眠质量',
          description: '建立规律作息，每天7-8小时睡眠',
          priority: GoalPriority.medium,
          category: 'health',
          icon: '😴',
        ),
        HealthGoalModel(
          id: 'mental_health',
          name: '心理健康',
          description: '社交活动、冥想或心理咨询',
          priority: GoalPriority.high,
          category: 'health',
          icon: '🧠',
        ),
      ]);
    } else {
      // Elderly goals
      goals.addAll([
        HealthGoalModel(
          id: 'chronic_disease_control',
          name: '慢性病控制',
          description: '规律用药，定期复诊',
          priority: GoalPriority.high,
          category: 'health',
          icon: '💊',
        ),
        HealthGoalModel(
          id: 'bone_strength',
          name: '骨强度维持',
          description: '补钙、维生素D，预防骨质疏松',
          priority: GoalPriority.high,
          category: 'nutrition',
          icon: '🦴',
        ),
        HealthGoalModel(
          id: 'fall_prevention',
          name: '跌倒预防',
          description: '平衡训练和居家安全改造',
          priority: GoalPriority.high,
          category: 'exercise',
          icon: '🏠',
        ),
        HealthGoalModel(
          id: 'social_activity',
          name: '社交活动',
          description: '参与社交活动，预防认知下降',
          priority: GoalPriority.medium,
          category: 'health',
          icon: '👥',
        ),
        HealthGoalModel(
          id: 'nutrition_adequacy',
          name: '营养充足',
          description: '确保蛋白质、维生素、矿物质充足',
          priority: GoalPriority.high,
          category: 'nutrition',
          icon: '🥘',
        ),
      ]);
    }
  }

  /// Add gender-specific health goals
  static void _addGenderSpecificGoals(
    List<HealthGoalModel> goals,
    String? gender,
    int age,
  ) {
    // Additional gender-specific considerations
    if (gender == 'female' && age >= 40 && age <= 55) {
      // Perimenopause and menopause considerations
      goals.add(HealthGoalModel(
        id: 'menopause_management',
        name: '更年期管理',
        description: '缓解更年期症状，保持身心健康',
        priority: GoalPriority.high,
        category: 'health',
        icon: '🌺',
      ));
    }
  }

  /// Add questionnaire-based goal recommendations
  static void _addQuestionnaireBasedGoals(
    List<HealthGoalModel> goals,
    Map<String, dynamic> questionnaireData,
    int age,
  ) {
    // Check for high stress level
    if (questionnaireData['workStressLevel'] == '非常高' ||
        questionnaireData['workStressLevel'] == '较高') {
      goals.add(HealthGoalModel(
        id: 'stress_management_urgent',
        name: '紧急压力管理',
        description: '寻求专业心理咨询或进行冥想训练',
        priority: GoalPriority.high,
        category: 'health',
        icon: '🆘',
      ));
    }

    // Check for inadequate exercise
    final exerciseHours = questionnaireData['exerciseHours'] ??
        questionnaireData['exerciseHoursPerWeek'];
    if (exerciseHours is num && exerciseHours < 3) {
      goals.add(HealthGoalModel(
        id: 'increase_exercise',
        name: '增加运动时间',
        description: '从每周${exerciseHours.toInt()}小时逐步增加到5小时以上',
        priority: GoalPriority.high,
        category: 'exercise',
        icon: '🚴',
      ));
    }

    // Check for sleep issues
    if (questionnaireData['sleepHours'] == '6小时以下' ||
        questionnaireData['sleepHours'] == '9小时以上') {
      goals.add(HealthGoalModel(
        id: 'sleep_regulation',
        name: '规范睡眠时间',
        description: '调整作息，保证每晚7-8小时睡眠',
        priority: GoalPriority.high,
        category: 'health',
        icon: '⏰',
      ));
    }

    // Check for device overuse
    if (questionnaireData['deviceUsage'] == '几乎一直' ||
        questionnaireData['deviceUsage'] == '大部分时间') {
      goals.add(HealthGoalModel(
        id: 'reduce_device_usage',
        name: '减少设备使用',
        description: '每天屏幕时间不超过8小时（除工作外）',
        priority: GoalPriority.medium,
        category: 'health',
        icon: '📵',
      ));
    }

    // Check for chronic disease management
    final chronicDiseases =
        questionnaireData['chronicDiseases'] as List<dynamic>?;
    if (chronicDiseases != null && chronicDiseases.isNotEmpty) {
      if (!chronicDiseases.contains('无')) {
        goals.add(HealthGoalModel(
          id: 'disease_management',
          name: '疾病管理',
          description: '定期复诊，监测病情指标',
          priority: GoalPriority.high,
          category: 'health',
          icon: '🩺',
        ));
      }
    }

    // Check for weight management needs
    if (questionnaireData['weightManagement'] == '超重' ||
        questionnaireData['weightManagement'] == '肥胖') {
      goals.add(HealthGoalModel(
        id: 'weight_loss',
        name: '健康减重',
        description: '制定合理的减重计划，每月2-4kg',
        priority: GoalPriority.high,
        category: 'nutrition',
        icon: '⬇️',
      ));
    }

    // Check for dietary concerns
    if (questionnaireData['dietaryFocus'] is List) {
      final dietaryFocus = questionnaireData['dietaryFocus'] as List<dynamic>;
      if (dietaryFocus.contains('低盐')) {
        goals.add(HealthGoalModel(
          id: 'sodium_control',
          name: '控制钠盐摄入',
          description: '日常饮食中减少盐分，预防高血压',
          priority: GoalPriority.medium,
          category: 'nutrition',
          icon: '🧂',
        ));
      }
    }

    // Check mobility and cognitive issues (elderly)
    if (questionnaireData['mobilityLevel'] == '需要大量帮助' ||
        questionnaireData['mobilityLevel'] == '完全依赖') {
      goals.add(HealthGoalModel(
        id: 'mobility_improvement',
        name: '改善活动能力',
        description: '物理治疗和康复训练',
        priority: GoalPriority.high,
        category: 'exercise',
        icon: '🏥',
      ));
    }
  }
}
