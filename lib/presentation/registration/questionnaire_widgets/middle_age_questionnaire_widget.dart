import 'package:flutter/material.dart';

/// Middle Age Questionnaire Widget (age 46-65)
class MiddleAgeQuestionnaireWidget extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const MiddleAgeQuestionnaireWidget({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<MiddleAgeQuestionnaireWidget> createState() =>
      _MiddleAgeQuestionnaireWidgetState();
}

class _MiddleAgeQuestionnaireWidgetState
    extends State<MiddleAgeQuestionnaireWidget> {
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
            _buildSectionTitle('慢性病管理'),
            _buildMultiSelectField(
              label: '1. 你是否有以下慢性病（可多选）',
              selectedValues: _data['chronicDiseases'] ?? [],
              options: ['高血压', '糖尿病', '高血脂', '心脏病', '无'],
              onChanged: (val) => _updateData('chronicDiseases', val),
            ),
            const SizedBox(height: 16),
            _buildSelectField(
              label: '2. 你的体重管理情况？',
              value: _data['weightManagement'],
              options: ['体重过低', '体重正常', '超重', '肥胖'],
              onChanged: (val) => _updateData('weightManagement', val),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('健康检查'),
            _buildSelectField(
              label: '3. 你多久做一次全面体检？',
              value: _data['healthCheckFrequency'],
              options: ['从不', '很少', '一年一次', '每半年一次', '每季度一次'],
              onChanged: (val) => _updateData('healthCheckFrequency', val),
            ),
            const SizedBox(height: 16),
            _buildSelectField(
              label: '4. 你目前服用哪些常规药物？',
              value: _data['regularMedication'],
              options: ['无', '1-2种', '3-5种', '超过5种'],
              onChanged: (val) => _updateData('regularMedication', val),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('生活方式'),
            _buildSliderField(
              label: '5. 你每周的运动时间（小时）',
              value: _data['exerciseHours'] ?? 3.0,
              max: 20,
              onChanged: (val) => _updateData('exerciseHours', val),
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
