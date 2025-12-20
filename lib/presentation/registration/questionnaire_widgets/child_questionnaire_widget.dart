import 'package:flutter/material.dart';

/// Child Questionnaire Widget (age <= 12)
class ChildQuestionnaireWidget extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const ChildQuestionnaireWidget({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<ChildQuestionnaireWidget> createState() =>
      _ChildQuestionnaireWidgetState();
}

class _ChildQuestionnaireWidgetState extends State<ChildQuestionnaireWidget> {
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
            _buildSectionTitle('学校生活'),
            _buildSelectField(
              label: '1. 你最喜欢的学科是什么？',
              value: _data['favoriteSubject'],
              options: ['语文', '数学', '英语', '体育', '美术'],
              onChanged: (val) => _updateData('favoriteSubject', val),
            ),
            const SizedBox(height: 16),
            _buildMultiSelectField(
              label: '2. 你喜欢的课外活动（可多选）',
              selectedValues: _data['extracurricularActivities'] ?? [],
              options: ['美术', '音乐', '舞蹈', '体育', '计算机'],
              onChanged: (val) => _updateData('extracurricularActivities', val),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('饮食习惯'),
            _buildSelectField(
              label: '3. 你每天吃早餐吗？',
              value: _data['eatBreakfast'],
              options: ['总是', '经常', '有时', '很少', '从不'],
              onChanged: (val) => _updateData('eatBreakfast', val),
            ),
            const SizedBox(height: 16),
            _buildSelectField(
              label: '4. 你最喜欢的水果是什么？',
              value: _data['favoriteFruit'],
              options: ['苹果', '香蕉', '橙子', '葡萄', '草莓'],
              onChanged: (val) => _updateData('favoriteFruit', val),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('运动与休闲'),
            _buildSliderField(
              label: '5. 你每周运动多少天？',
              value: _data['exerciseDaysPerWeek'] ?? 3.0,
              onChanged: (val) => _updateData('exerciseDaysPerWeek', val),
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
              max: 7,
              divisions: 7,
              label: value.toStringAsFixed(0),
              onChanged: onChanged,
            ),
            Text('${value.toInt()} 天/周',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
