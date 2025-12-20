import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenify/models/health_goal_model.dart';
import 'package:zenify/providers/registration_provider.dart';
import 'package:zenify/utils/goal_recommendation_engine.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  late List<HealthGoalModel> _recommendedGoals;
  late List<HealthGoalModel> _selectedGoals;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendedGoals();
  }

  void _loadRecommendedGoals() {
    final provider = context.read<RegistrationProvider>();
    final data = provider.registrationData;

    // Generate recommended goals based on user profile
    _recommendedGoals = GoalRecommendationEngine.recommendGoals(
      birthDate: data.birthDate!,
      gender: data.gender,
      questionnaireData: data.questionnaireData,
    );

    // Initialize selected goals from provider or empty list
    _selectedGoals = (data.selectedGoalIds ?? [])
        .map((id) => _recommendedGoals.firstWhere((g) => g.id == id,
            orElse: () => HealthGoalModel(
                  id: id,
                  name: '未知目标',
                  priority: GoalPriority.low,
                )))
        .toList();

    // Mark selected goals as selected
    for (var goal in _recommendedGoals) {
      goal.isSelected =
          _selectedGoals.any((selected) => selected.id == goal.id);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleGoalSelection(HealthGoalModel goal) {
    setState(() {
      final index = _recommendedGoals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _recommendedGoals[index].isSelected =
            !_recommendedGoals[index].isSelected;

        // Update selected goals list
        _selectedGoals = _recommendedGoals.where((g) => g.isSelected).toList();

        // Update provider
        context
            .read<RegistrationProvider>()
            .updateSelectedGoals(_selectedGoals.map((g) => g.id).toList());
      }
    });
  }

  void _selectByCategory(String category) {
    setState(() {
      for (var goal in _recommendedGoals) {
        if (goal.category == category) {
          goal.isSelected = true;
        }
      }
      _selectedGoals = _recommendedGoals.where((g) => g.isSelected).toList();
      context
          .read<RegistrationProvider>()
          .updateSelectedGoals(_selectedGoals.map((g) => g.id).toList());
    });
  }

  void _clearSelection() {
    setState(() {
      for (var goal in _recommendedGoals) {
        goal.isSelected = false;
      }
      _selectedGoals = [];
      context.read<RegistrationProvider>().updateSelectedGoals([]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('健康目标推荐'),
            elevation: 0,
            backgroundColor: Colors.blue[700],
            centerTitle: true,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header section
                      _buildHeaderSection(provider),

                      // Category filter chips
                      _buildCategoryFilter(),

                      // Goals list
                      _buildGoalsList(),

                      // Quick actions
                      _buildQuickActions(),
                    ],
                  ),
                ),
          bottomNavigationBar: _buildBottomNavigationBar(provider),
        );
      },
    );
  }

  Widget _buildHeaderSection(RegistrationProvider provider) {
    final data = provider.registrationData;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.blue[200]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${data.name}，很高兴认识你！',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '根据你的年龄、性别和健康状况，我们为你推荐了以下健康目标。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '已选择 ${_selectedGoals.length}/5 个目标',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = {'nutrition': '营养', 'exercise': '运动', 'health': '健康'};
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '按类别筛选',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: categories.entries.map((entry) {
              return FilterChip(
                label: Text(entry.value),
                onSelected: (_) => _selectByCategory(entry.key),
                backgroundColor: Colors.grey[200],
                labelStyle: Theme.of(context).textTheme.labelSmall,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    if (_recommendedGoals.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            '没有推荐的目标',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '推荐的健康目标',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ..._recommendedGoals.map((goal) => _buildGoalCard(goal)).toList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGoalCard(HealthGoalModel goal) {
    final priorityColor = HealthGoalModel.getPriorityColor(goal.priority);
    final priorityLabel = HealthGoalModel.getPriorityLabel(goal.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _toggleGoalSelection(goal),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              Checkbox(
                value: goal.isSelected,
                onChanged: (_) => _toggleGoalSelection(goal),
                activeColor: Color(priorityColor),
              ),
              const SizedBox(width: 12),
              // Goal content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.icon ?? '🎯',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              if (goal.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  goal.description!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(priorityColor).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '优先级: $priorityLabel',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Color(priorityColor),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            '快速操作',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearSelection,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('清空选择'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      for (var goal in _recommendedGoals) {
                        goal.isSelected = true;
                      }
                      _selectedGoals = _recommendedGoals.toList();
                      context.read<RegistrationProvider>().updateSelectedGoals(
                          _selectedGoals.map((g) => g.id).toList());
                    });
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('全部选择'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(RegistrationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: provider.previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('上一步'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _selectedGoals.isNotEmpty ? provider.nextStep : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('下一步'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
