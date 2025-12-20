import 'package:zenify/models/health_goal_model.dart';

/// User health goals selection model
class UserHealthGoals {
  final List<HealthGoalModel> selectedGoals;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserHealthGoals({
    required this.selectedGoals,
    this.createdAt,
    this.updatedAt,
  });

  /// Get selected goal IDs
  List<String> get selectedGoalIds => selectedGoals.map((g) => g.id).toList();

  /// Get high priority goals
  List<HealthGoalModel> get highPriorityGoals =>
      selectedGoals.where((g) => g.priority == GoalPriority.high).toList();

  /// Copy with support for partial updates
  UserHealthGoals copyWith({
    List<HealthGoalModel>? selectedGoals,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserHealthGoals(
      selectedGoals: selectedGoals ?? this.selectedGoals,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'UserHealthGoals(count: ${selectedGoals.length}, highPriority: ${highPriorityGoals.length})';
}
