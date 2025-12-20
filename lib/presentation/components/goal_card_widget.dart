import 'package:flutter/material.dart';
import 'package:zenify/models/health_goal_model.dart';

/// Goal card widget for displaying a single health goal
class GoalCardWidget extends StatelessWidget {
  final HealthGoalModel goal;
  final VoidCallback? onTap;
  final bool showDescription;

  const GoalCardWidget({
    super.key,
    required this.goal,
    this.onTap,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = HealthGoalModel.getPriorityColor(goal.priority);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(priorityColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(goal.icon ?? '🎯',
                    style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (showDescription && goal.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                    if (goal.category != null) ...[
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          goal.category!,
                          style: const TextStyle(fontSize: 11),
                        ),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Color(priorityColor).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: Color(priorityColor),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Priority indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(priorityColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  HealthGoalModel.getPriorityLabel(goal.priority),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid display widget for multiple goals
class GoalsGridWidget extends StatelessWidget {
  final List<HealthGoalModel> goals;
  final Function(HealthGoalModel)? onGoalTap;
  final bool showDescription;

  const GoalsGridWidget({
    super.key,
    required this.goals,
    this.onGoalTap,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            '暂无目标',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: goals.length,
      itemBuilder: (context, index) {
        return GoalCardWidget(
          goal: goals[index],
          onTap: () => onGoalTap?.call(goals[index]),
          showDescription: showDescription,
        );
      },
    );
  }
}
