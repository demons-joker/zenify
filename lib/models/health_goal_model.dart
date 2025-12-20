/// Priority levels for health goals
enum GoalPriority {
  low,
  medium,
  high,
}

/// Health goal model
class HealthGoalModel {
  final String id;
  final String name;
  final String? description;
  final GoalPriority priority;
  final String? category; // e.g., 'nutrition', 'exercise', 'health'
  final String? icon; // emoji or icon name
  bool isSelected;

  HealthGoalModel({
    required this.id,
    required this.name,
    this.description,
    required this.priority,
    this.category,
    this.icon,
    this.isSelected = false,
  });

  /// Copy with support for partial updates
  HealthGoalModel copyWith({
    String? id,
    String? name,
    String? description,
    GoalPriority? priority,
    String? category,
    String? icon,
    bool? isSelected,
  }) {
    return HealthGoalModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Get priority color
  static int getPriorityColor(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.high:
        return 0xFFE53935; // Red
      case GoalPriority.medium:
        return 0xFFFFA726; // Orange
      case GoalPriority.low:
        return 0xFF43A047; // Green
    }
  }

  /// Get priority label
  static String getPriorityLabel(GoalPriority priority) {
    switch (priority) {
      case GoalPriority.high:
        return '高';
      case GoalPriority.medium:
        return '中';
      case GoalPriority.low:
        return '低';
    }
  }
}
