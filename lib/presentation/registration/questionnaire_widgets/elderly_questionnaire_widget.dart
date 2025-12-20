import 'package:flutter/material.dart';

/// Elderly Questionnaire Widget (age > 65)
class ElderlyQuestionnaireWidget extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const ElderlyQuestionnaireWidget({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<ElderlyQuestionnaireWidget> createState() =>
      _ElderlyQuestionnaireWidgetState();
}

class _ElderlyQuestionnaireWidgetState
    extends State<ElderlyQuestionnaireWidget> {
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
            _buildSectionTitle('慢性病与健康状况'),
            _buildMultiSelectField(
              label: '1. 你目前患有的主要疾病（可多选）',
              selectedValues: _data['mainDiseases'] ?? [],
              options: ['高血压', '糖尿病', '心脏病', '骨质疏松', '关节炎', '肺部疾病'],
              onChanged: (val) => _updateData('mainDiseases', val),
            ),
            const SizedBox(height: 16),
            _buildSelectField(
              label: '2. 你目前服用多少种药物？',
              value: _data['medicationCount'],
              options: ['无', '1-3种', '4-6种', '7-10种', '10种以上'],
              onChanged: (val) => _updateData('medicationCount', val),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('日常活动能力'),
            _buildSelectField(
              label: '3. 你的日常行动能力如何？',
              value: _data['mobilityLevel'],
              options: ['完全独立', '基本独立', '需要一些帮助', '需要大量帮助', '完全依赖'],
              onChanged: (val) => _updateData('mobilityLevel', val),
            ),
            const SizedBox(height: 16),
            _buildSelectField(
              label: '4. 你的记忆力和认知功能？',
              value: _data['cognitiveFunction'],
              options: ['很好', '良好', '一般', '有所下降', '明显下降'],
              onChanged: (val) => _updateData('cognitiveFunction', val),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('生活方式与社交'),
            _buildSliderField(
              label: '5. 你每周的社交活动或锻炼时间（小时）',
              value: _data['socialActivityHours'] ?? 3.0,
              max: 20,
              onChanged: (val) => _updateData('socialActivityHours', val),
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
