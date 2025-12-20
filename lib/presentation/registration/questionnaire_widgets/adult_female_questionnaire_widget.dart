import 'package:flutter/material.dart';

/// Adult Female Questionnaire Widget (age 19-45, female)
class AdultFemaleQuestionnaireWidget extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onDataChanged;

  const AdultFemaleQuestionnaireWidget({
    super.key,
    this.initialData,
    required this.onDataChanged,
  });

  @override
  State<AdultFemaleQuestionnaireWidget> createState() =>
      _AdultFemaleQuestionnaireWidgetState();
}

class _AdultFemaleQuestionnaireWidgetState
    extends State<AdultFemaleQuestionnaireWidget> {
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
            _buildSectionTitle('工作与生活平衡'),
            _buildSelectField(
              label: '1. 你每周工作多少小时？',
              value: _data['workHoursPerWeek'],
              options: ['低于40小时', '40-50小时', '50-60小时', '60-70小时', '70小时以上'],
              onChanged: (val) => _updateData('workHoursPerWeek', val),
            ),
            const SizedBox(height: 16),
            _buildSelectField(
              label: '2. 你的工作压力程度？',
              value: _data['workStressLevel'],
              options: ['很低', '较低', '中等', '较高', '非常高'],
              onChanged: (val) => _updateData('workStressLevel', val),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('女性健康'),
            _buildSelectField(
              label: '3. 你的月经周期规律吗？',
              value: _data['menstrualRegularity'],
              options: ['非常规律', '基本规律', '不规律', '不适用'],
              onChanged: (val) => _updateData('menstrualRegularity', val),
            ),
            const SizedBox(height: 16),
            _buildSelectField(
              label: '4. 你定期进行妇科检查吗？',
              value: _data['gynecologicalCheckup'],
              options: ['从不', '很少', '一年一次', '每半年一次', '每季度一次'],
              onChanged: (val) => _updateData('gynecologicalCheckup', val),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('运动与美容'),
            _buildSliderField(
              label: '5. 你每周的运动时间（小时）',
              value: _data['exerciseHours'] ?? 5.0,
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
