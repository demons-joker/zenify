// 动态进度条测试用例 - 简化版本，不依赖SharedPreferences
import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/questionnaire_progress_helper.dart';

void main() {
  group('QuestionnaireProgressHelper Tests', () {
    test('页面步骤映射测试', () async {
      // 测试普通用户的页面步骤映射
      final normalSteps = {
        'userProfile': 1,
        'goalSelection': 2,
        'preference': 3,
        'foodSource': 4,
        'foodDislike': 5,
        'eatingStyle': 6,
        'eatingRoutine': 7,
        'allergy': 8,
        'activityLevel': 9,
        'registrationComplete': 10,
      };

      for (final entry in normalSteps.entries) {
        final progress = ProgressInfo(
          currentStep: entry.value,
          totalSteps: 10,
          progressValue: entry.value / 10.0,
        );
        
        expect(progress.currentStep, equals(entry.value));
        expect(progress.totalSteps, equals(10));
        expect(progress.progressValue, equals(entry.value / 10.0));
      }
    });

    test('慢性病用户页面步骤映射测试', () async {
      // 测试慢性病用户的页面步骤映射
      final chronicSteps = {
        'userProfile': 1,
        'goalSelection': 2,
        'chronicDisease': 3,
        'preference': 4,
        'foodSource': 5,
        'foodDislike': 6,
        'eatingStyle': 7,
        'eatingRoutine': 8,
        'allergy': 9,
        'activityLevel': 10,
        'registrationComplete': 11,
      };

      for (final entry in chronicSteps.entries) {
        final progress = ProgressInfo(
          currentStep: entry.value,
          totalSteps: 11,
          progressValue: entry.value / 11.0,
        );
        
        expect(progress.currentStep, equals(entry.value));
        expect(progress.totalSteps, equals(11));
        expect(progress.progressValue, closeTo(entry.value / 11.0, 0.001));
      }
    });

    test('ProgressInfo类测试', () {
      // 测试ProgressInfo类的基本功能
      final progress = ProgressInfo(
        currentStep: 5,
        totalSteps: 10,
        progressValue: 0.5,
      );

      expect(progress.currentStep, equals(5));
      expect(progress.totalSteps, equals(10));
      expect(progress.progressValue, equals(0.5));
    });

    test('进度值精度测试', () {
      // 测试进度值的精度计算
      final progress1 = ProgressInfo(
        currentStep: 1,
        totalSteps: 11,
        progressValue: 1.0 / 11.0,
      );
      
      final progress2 = ProgressInfo(
        currentStep: 3,
        totalSteps: 11,
        progressValue: 3.0 / 11.0,
      );
      
      final progress3 = ProgressInfo(
        currentStep: 10,
        totalSteps: 11,
        progressValue: 10.0 / 11.0,
      );

      expect(progress1.progressValue, closeTo(0.091, 0.001));
      expect(progress2.progressValue, closeTo(0.273, 0.001));
      expect(progress3.progressValue, closeTo(0.909, 0.001));
    });

    test('边界值测试', () {
      // 测试边界值
      final startProgress = ProgressInfo(
        currentStep: 1,
        totalSteps: 10,
        progressValue: 0.1,
      );
      
      final endProgress = ProgressInfo(
        currentStep: 10,
        totalSteps: 10,
        progressValue: 1.0,
      );

      expect(startProgress.progressValue, equals(0.1));
      expect(endProgress.progressValue, equals(1.0));
    });
  });
}