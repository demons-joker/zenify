import 'package:flutter_test/flutter_test.dart';
import 'package:zenify/services/recognition_report_service.dart';

void main() {
  group('RecognitionReportService.resolveFoods', () {
    test('returns foods when data contains foods list', () {
      final record = {
        'foods': [
          {'name': 'apple'},
          {'name': 'egg'}
        ]
      };

      final foods = RecognitionReportService.resolveFoods(record);
      expect(foods.length, 2);
    });

    test('returns empty list when foods is missing', () {
      final foods = RecognitionReportService.resolveFoods({'id': 1});
      expect(foods, isEmpty);
    });
  });
}
