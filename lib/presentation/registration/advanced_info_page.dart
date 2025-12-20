import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenify/models/advanced_health_info.dart';
import 'package:zenify/providers/registration_provider.dart';
import 'package:zenify/presentation/components/tag_input_widget.dart';
import 'package:zenify/presentation/components/file_upload_widget.dart';

class AdvancedInfoPage extends StatefulWidget {
  const AdvancedInfoPage({super.key});

  @override
  State<AdvancedInfoPage> createState() => _AdvancedInfoPageState();
}

class _AdvancedInfoPageState extends State<AdvancedInfoPage> {
  late TextEditingController _medicationController;
  late List<String> _selectedDiseases;
  late List<String> _selectedAllergies;
  late List<String> _uploadedFiles;

  // Common chronic diseases
  final List<String> _availableDiseases = [
    '高血压',
    '糖尿病',
    '高血脂',
    '心脏病',
    '肺部疾病',
    '骨质疏松',
    '甲状腺疾病',
    '肝脏疾病',
    '肾脏疾病',
    '其他',
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<RegistrationProvider>();
    final advancedInfo = provider.registrationData.advancedInfo;

    _selectedDiseases = List.from(advancedInfo?.chronicDiseases ?? []);
    _selectedAllergies = List.from(advancedInfo?.foodAllergies ?? []);
    _medicationController =
        TextEditingController(text: advancedInfo?.currentMedications ?? '');
    _uploadedFiles = List.from(advancedInfo?.reportFiles ?? []);
  }

  @override
  void dispose() {
    _medicationController.dispose();
    super.dispose();
  }

  void _updateAdvancedInfo() {
    final advancedInfo = AdvancedHealthInfo(
      chronicDiseases: _selectedDiseases,
      foodAllergies: _selectedAllergies,
      currentMedications: _medicationController.text,
      reportFiles: _uploadedFiles,
    );

    context.read<RegistrationProvider>().updateAdvancedInfo(advancedInfo);
  }

  void _toggleDisease(String disease) {
    setState(() {
      if (_selectedDiseases.contains(disease)) {
        _selectedDiseases.remove(disease);
      } else {
        _selectedDiseases.add(disease);
      }
    });
    _updateAdvancedInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('高级信息(可选)'),
            elevation: 0,
            backgroundColor: Colors.blue[700],
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () => provider.nextStep(),
                child: const Text(
                  '跳过',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  _buildInfoBanner(),
                  const SizedBox(height: 24),

                  // Section 1: Chronic Diseases
                  _buildChronicDiseasesSection(),
                  const SizedBox(height: 24),

                  // Section 2: Food Allergies
                  _buildFoodAllergiesSection(),
                  const SizedBox(height: 24),

                  // Section 3: Medications
                  _buildMedicationsSection(),
                  const SizedBox(height: 24),

                  // Section 4: File Upload
                  _buildFileUploadSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(provider),
        );
      },
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '此步骤为可选项',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '您可以补充更多个人健康信息，帮助我们提供更准确的健康建议。如不想填写，可直接跳过。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChronicDiseasesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '慢性病情况',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '请选择您目前患有的慢性病（可多选）',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableDiseases.map((disease) {
            final isSelected = _selectedDiseases.contains(disease);
            return FilterChip(
              label: Text(disease),
              selected: isSelected,
              onSelected: (_) => _toggleDisease(disease),
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.blue[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue[700] : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        if (_selectedDiseases.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '已选择: ${_selectedDiseases.join(', ')}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.blue[700],
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFoodAllergiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '食物过敏',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TagInputWidget(
          initialTags: _selectedAllergies,
          onTagsChanged: (tags) {
            setState(() {
              _selectedAllergies = tags;
            });
            _updateAdvancedInfo();
          },
          label: '',
          hintText: '输入过敏食物（如：花生、海鲜）',
          maxTags: 10,
        ),
      ],
    );
  }

  Widget _buildMedicationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '当前用药情况',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '请列出您目前服用的药物及用法',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextFormField(
              controller: _medicationController,
              maxLines: 5,
              minLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: '例如：\n阿司匹林 100mg 每天一次\n维生素D 1000IU 每天一次',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              onChanged: (_) => _updateAdvancedInfo(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '体检报告',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '上传最近的体检报告或相关医疗文件（最多5张）',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 12),
        FileUploadWidget(
          initialFiles: _uploadedFiles,
          onFilesSelected: (files) {
            setState(() {
              _uploadedFiles = files;
            });
            _updateAdvancedInfo();
          },
          maxFiles: 5,
          label: '',
        ),
      ],
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
              onPressed: () {
                _updateAdvancedInfo();
                provider.nextStep();
              },
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
