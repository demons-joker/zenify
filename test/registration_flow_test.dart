import 'package:flutter_test/flutter_test.dart';
import 'package:zenify/models/advanced_health_info.dart';
import 'package:zenify/models/health_goal_model.dart';
import 'package:zenify/models/registration_state.dart';
import 'package:zenify/utils/questionnaire_utils.dart';
import 'package:zenify/utils/goal_recommendation_engine.dart';

void main() {
  group('Registration Flow Integration Tests', () {
    /// Test Step 1: Basic Info
    test('Step 1 - Basic Info should store user data correctly', () {
      final registrationData = UserRegistrationData(
        name: '张三',
        gender: '男',
        birthDate: DateTime(1990, 5, 15),
      );

      expect(registrationData.name, '张三');
      expect(registrationData.gender, '男');
      expect(registrationData.birthDate, DateTime(1990, 5, 15));
      expect(registrationData.isStep1Complete, true);
    });

    /// Test Step 2: Questionnaire Category Determination
    test(
        'Step 2 - Questionnaire category should be determined by age and gender',
        () {
      // Test Child (8 years old)
      final childBirthDate = DateTime.now().subtract(Duration(days: 365 * 8));
      final childCategory =
          QuestionnaireUtils.determineCategory(childBirthDate, 'male');
      expect(childCategory, QuestionnaireCategory.child);

      // Test Teenager (16 years old)
      final teenBirthDate = DateTime.now().subtract(Duration(days: 365 * 16));
      final teenCategory =
          QuestionnaireUtils.determineCategory(teenBirthDate, 'female');
      expect(teenCategory, QuestionnaireCategory.teen);

      // Test Adult Male (30 years old)
      final adultMaleBirthDate =
          DateTime.now().subtract(Duration(days: 365 * 30));
      final adultMaleCategory =
          QuestionnaireUtils.determineCategory(adultMaleBirthDate, 'male');
      expect(adultMaleCategory, QuestionnaireCategory.adultMale);

      // Test Adult Female (35 years old)
      final adultFemaleBirthDate =
          DateTime.now().subtract(Duration(days: 365 * 35));
      final adultFemaleCategory =
          QuestionnaireUtils.determineCategory(adultFemaleBirthDate, 'female');
      expect(adultFemaleCategory, QuestionnaireCategory.adultFemale);

      // Test Middle Age (55 years old)
      final middleAgeBirthDate =
          DateTime.now().subtract(Duration(days: 365 * 55));
      final middleAgeCategory =
          QuestionnaireUtils.determineCategory(middleAgeBirthDate, 'female');
      expect(middleAgeCategory, QuestionnaireCategory.middleAge);

      // Test Elderly (70 years old)
      final elderlyBirthDate =
          DateTime.now().subtract(Duration(days: 365 * 70));
      final elderlyCategory =
          QuestionnaireUtils.determineCategory(elderlyBirthDate, 'male');
      expect(elderlyCategory, QuestionnaireCategory.elderly);
    });

    /// Test Step 2: Store Questionnaire Data
    test('Step 2 - Questionnaire data should be stored correctly', () {
      var registrationData = UserRegistrationData(
        name: '李四',
        gender: '女',
        birthDate: DateTime(1995, 3, 20),
      );

      final questionnaireData = {
        'schoolPerformance': '优秀',
        'dietaryHabits': '正常',
        'exerciseFrequency': '每周3次',
      };

      registrationData = registrationData.copyWith(
        questionnaireData: questionnaireData,
      );

      expect(registrationData.questionnaireData, questionnaireData);
      expect(registrationData.isStep2Complete, true);
    });

    /// Test Step 3: Goal Recommendation
    test('Step 3 - Health goals should be recommended based on profile', () {
      final birthDate =
          DateTime.now().subtract(Duration(days: 365 * 30)); // 30岁
      final gender = 'female';
      final questionnaireData = {
        'exerciseFrequency': '每周少于3次',
        'sleepQuality': '经常失眠',
        'stressLevel': '高',
      };

      final recommendedGoals = GoalRecommendationEngine.recommendGoals(
        birthDate: birthDate,
        gender: gender,
        questionnaireData: questionnaireData,
      );

      expect(recommendedGoals, isNotEmpty);
      expect(recommendedGoals.length, lessThanOrEqualTo(5));
    });

    /// Test Step 3: Goal Selection
    test('Step 3 - Selected goals should be stored correctly', () {
      var registrationData = UserRegistrationData(
        name: '王五',
        gender: '男',
        birthDate: DateTime(1988, 7, 10),
        questionnaireData: {'exerciseFrequency': '每周3次'},
      );

      final selectedGoalIds = ['goal_1', 'goal_2', 'goal_3'];
      registrationData = registrationData.copyWith(
        selectedGoalIds: selectedGoalIds,
      );

      expect(registrationData.selectedGoalIds, selectedGoalIds);
      expect(registrationData.isStep3Complete, true);
    });

    /// Test Step 4: Advanced Info
    test('Step 4 - Advanced health information should be stored correctly', () {
      final advancedInfo = AdvancedHealthInfo(
        chronicDiseases: ['高血压', '糖尿病'],
        foodAllergies: ['花生', '海鲜'],
        currentMedications: '血压药 - 每天一次\n糖尿病药 - 每天两次',
        reportFiles: ['/path/to/report1.jpg', '/path/to/report2.jpg'],
      );

      expect(advancedInfo.chronicDiseases, ['高血压', '糖尿病']);
      expect(advancedInfo.foodAllergies, ['花生', '海鲜']);
      expect(advancedInfo.currentMedications, contains('血压药'));
      expect(advancedInfo.reportFiles.length, 2);
      expect(advancedInfo.hasAnyInfo, true);
    });

    /// Test Step 4: Optional Nature of Advanced Info
    test('Step 4 - Advanced info should be optional', () {
      final advancedInfoEmpty = AdvancedHealthInfo(
        chronicDiseases: [],
        foodAllergies: [],
        currentMedications: null,
        reportFiles: [],
      );

      expect(advancedInfoEmpty.hasAnyInfo, false);

      var registrationData = UserRegistrationData(
        name: '赵六',
        gender: 'female',
        birthDate: DateTime(2000, 1, 1),
        questionnaireData: {
          'someField': 'someValue'
        }, // Must have at least one field
        selectedGoalIds: ['goal_1'],
        advancedInfo: advancedInfoEmpty,
      );

      // Step 4 is complete if advancedInfo is not null (even if empty)
      expect(registrationData.advancedInfo, isNotNull);
      expect(registrationData.isComplete, true);
    });

    /// Test Complete Flow
    test('Complete registration flow should work end-to-end', () {
      // Step 1: Basic Info
      var registrationData = UserRegistrationData(
        name: '孙七',
        gender: 'male',
        birthDate: DateTime(1992, 6, 15),
      );

      expect(registrationData.isStep1Complete, true);
      expect(registrationData.isStep2Complete, false);

      // Step 2: Questionnaire
      registrationData = registrationData.copyWith(
        questionnaireData: {
          'workStress': '高',
          'exerciseFrequency': '每周1次',
          'dietaryHabits': '不规律',
        },
      );

      expect(registrationData.isStep2Complete, true);
      expect(registrationData.isStep3Complete, false);

      // Step 3: Goals
      registrationData = registrationData.copyWith(
        selectedGoalIds: ['goal_fitness', 'goal_stress', 'goal_nutrition'],
      );

      expect(registrationData.isStep3Complete, true);

      // Step 4: Advanced Info (Optional - can be empty)
      final advancedInfo = AdvancedHealthInfo(
        chronicDiseases: [],
        foodAllergies: ['花生'],
        currentMedications: null,
        reportFiles: [],
      );

      registrationData = registrationData.copyWith(
        advancedInfo: advancedInfo,
      );

      expect(registrationData.advancedInfo, isNotNull);
      expect(registrationData.isComplete, true);
    });

    /// Test Data Persistence through copyWith
    test('Data should persist through all steps via copyWith', () {
      var data = UserRegistrationData(
        name: '周八',
        gender: 'female',
        birthDate: DateTime(1998, 11, 25),
      );

      // Add step 2 data
      data = data.copyWith(
        questionnaireData: {'someKey': 'someValue'},
      );

      // Add step 3 data - previous data should remain
      data = data.copyWith(
        selectedGoalIds: ['goal_1', 'goal_2'],
      );

      expect(data.name, '周八');
      expect(data.questionnaireData, isNotEmpty);

      // Add step 4 data - all previous data should remain
      data = data.copyWith(
        advancedInfo: AdvancedHealthInfo(
          chronicDiseases: [],
          foodAllergies: [],
          currentMedications: null,
          reportFiles: [],
        ),
      );

      expect(data.name, '周八');
      expect(data.questionnaireData, isNotEmpty);
      expect(data.selectedGoalIds, isNotEmpty);
      expect(data.advancedInfo, isNotNull);
    });

    /// Test Goal Priority System
    test('Health goals should have priority levels', () {
      final highPriorityGoal = HealthGoalModel(
        id: 'high_goal',
        name: '紧急健康管理',
        description: '需要立即关注',
        priority: GoalPriority.high,
        category: '健康',
        icon: 'warning',
        isSelected: true,
      );

      final mediumPriorityGoal = HealthGoalModel(
        id: 'medium_goal',
        name: '适度健身',
        description: '逐步改善',
        priority: GoalPriority.medium,
        category: '运动',
        icon: 'fitness',
        isSelected: false,
      );

      final lowPriorityGoal = HealthGoalModel(
        id: 'low_goal',
        name: '日常保健',
        description: '长期维护',
        priority: GoalPriority.low,
        category: '营养',
        icon: 'health',
        isSelected: true,
      );

      expect(HealthGoalModel.getPriorityLabel(GoalPriority.high), '高');
      expect(HealthGoalModel.getPriorityLabel(GoalPriority.medium), '中');
      expect(HealthGoalModel.getPriorityLabel(GoalPriority.low), '低');

      expect(HealthGoalModel.getPriorityColor(GoalPriority.high), isNotNull);
      expect(HealthGoalModel.getPriorityColor(GoalPriority.medium), isNotNull);
      expect(HealthGoalModel.getPriorityColor(GoalPriority.low), isNotNull);
    });

    /// Test Age Calculation Accuracy
    test('Age calculation should be accurate', () {
      final birthDate = DateTime(1990, 5, 15);
      final age = QuestionnaireUtils.calculateAge(birthDate);

      // Current date: 2025-12-11
      expect(age, 35); // 1990 to 2025 = 35 years
    });
  });
}
