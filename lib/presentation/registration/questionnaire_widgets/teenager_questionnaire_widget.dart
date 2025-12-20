import 'package:flutter/material.dart';

/// Teen Questionnaire Widget (age 13-18)
class TeenagerQuestionnaireWidget extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const TeenagerQuestionnaireWidget({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<TeenagerQuestionnaireWidget> createState() =>
      _TeenagerQuestionnaireWidgetState();
}

class _TeenagerQuestionnaireWidgetState
    extends State<TeenagerQuestionnaireWidget> {
  late Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData ?? {};
  }

  void _updateData(String key, dynamic value) {
    setState(() {
      _data[key] = value;
    });
    widget.onDataChanged(_data);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('学业与兴趣'),
            _buildSelectField(
              label: '1. 你对未来职业的规划是什么？',
              value: _data['careerPlan'],
              options: ['科技', '医疗', '教育', '艺术', '运动', '商业', '其他'],
              onChanged: (val) => _updateData('careerPlan', val),
            ),
            const SizedBox(height: 16),
            _buildMultiSelectField(
              label: '2. 你感兴趣的活动（可多选）',
              selectedValues: _data['interests'] ?? [],
              options: ['阅读', '编程', '体育', '音乐', '社交', '游戏', '艺术'],
              onChanged: (val) => _updateData('interests', val),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('生活方式'),
            _buildSelectField(
              label: '3. 你每天睡眠时间大约多少小时？',
              value: _data['sleepHours'],
              options: ['6小时以下', '6-7小时', '7-8小时', '8-9小时', '9小时以上'],
              onChanged: (val) => _updateData('sleepHours', val),
            ),
            const SizedBox(height: 16),
            _buildSelectField(
              label: '4. 你使用电子设备的频率？',
              value: _data['deviceUsage'],
              options: ['很少', '偶尔', '经常', '大部分时间', '几乎一直'],
              onChanged: (val) => _updateData('deviceUsage', val),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('健康与运动'),
            _buildSliderField(
              label: '5. 你每周运动多少小时？',
              value: _data['exerciseHoursPerWeek'] ?? 5.0,
              max: 20,
              onChanged: (val) => _updateData('exerciseHoursPerWeek', val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
      ),
    );
  }

  Widget _buildSelectField({
    required String label,
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: const Text('请选择'),
              items: options
                  .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                  .toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> selectedValues,
    required List<String> options,
    required Function(List<String>) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: options.map((opt) {
                final isSelected = selectedValues.contains(opt);
                return FilterChip(
                  label: Text(opt),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    final newValues = List<String>.from(selectedValues);
                    if (selected) {
                      newValues.add(opt);
                    } else {
                      newValues.remove(opt);
                    }
                    onChanged(newValues);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderField({
    required String label,
    required double value,
    double max = 10,
    required Function(double) onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Slider(
              value: value,
              min: 0,
              max: max,
              divisions: max.toInt(),
              label: value.toStringAsFixed(1),
              onChanged: onChanged,
            ),
            Text('${value.toStringAsFixed(1)} 小时/周',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
