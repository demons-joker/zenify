import 'package:zenify/services/api.dart';

class HomeHistoryCoordinator {
  Future<Map<String, List<Map<String, dynamic>>>> loadAteFoods({
    required String userId,
    required int selectedDay,
  }) async {
    final targetDate = _resolveTargetDate(selectedDay);
    final dateStr =
        '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

    final result = await Api.getRecognitions({'date': dateStr});
    final groupedFoods = {
      'BREAKFAST': <Map<String, dynamic>>[],
      'LUNCH': <Map<String, dynamic>>[],
      'DINNER': <Map<String, dynamic>>[],
      'OTHER': <Map<String, dynamic>>[],
    };

    for (final record in result) {
      final mealType = resolveMealTypeByTimeOfDay(record['created_at']);
      groupedFoods[mealType]?.add(buildFoodCard(record));
    }
    return groupedFoods;
  }

  DateTime _resolveTargetDate(int selectedDay) {
    final now = DateTime.now();
    final selectedWeekday = selectedDay == 0 ? 7 : selectedDay;
    final daysToSubtract = now.weekday - selectedWeekday;
    return now.subtract(Duration(days: daysToSubtract));
  }

  Map<String, dynamic> buildFoodCard(Map<String, dynamic> record) {
    final status = (record['status'] ?? 'unknown').toString().toLowerCase();
    final isAnalyzing = {
      'accepted',
      'processing',
      'pending',
      'queued',
    }.contains(status);
    final foods = record['foods'] as List? ?? [];
    final foodNames = foods
        .map((f) => f['food']?['name_en'] ?? f['food']?['name'] ?? 'Unknown')
        .join(', ');
    final title = isAnalyzing
        ? 'Recognizing your meal...'
        : (foodNames.isNotEmpty ? foodNames : 'Recognition Result');

    return {
      'id': record['id'],
      'imageUrl': record['image_url'],
      'title': title,
      'isLiked': false,
      'isAnalyzing': isAnalyzing,
      'status': status,
      'sessionId': record['session_id']?.toString(),
      'timestamp': record['created_at'],
      'data': record,
    };
  }

  String resolveMealTypeByTimeOfDay(dynamic timeStr) {
    try {
      final DateTime time =
          timeStr is String ? DateTime.parse(timeStr) : timeStr as DateTime;
      final hour = time.hour;
      if (hour >= 5 && hour < 11) {
        return 'BREAKFAST';
      }
      if (hour >= 11 && hour < 14) {
        return 'LUNCH';
      }
      if (hour >= 17 && hour < 21) {
        return 'DINNER';
      }
      return 'OTHER';
    } catch (_) {
      return 'OTHER';
    }
  }
}
