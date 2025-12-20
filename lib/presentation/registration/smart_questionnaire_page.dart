import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenify/models/registration_state.dart';
import 'package:zenify/providers/registration_provider.dart';
import 'package:zenify/utils/questionnaire_utils.dart';
import 'questionnaire_widgets/child_questionnaire_widget.dart';
import 'questionnaire_widgets/teenager_questionnaire_widget.dart';
import 'questionnaire_widgets/adult_male_questionnaire_widget.dart';
import 'questionnaire_widgets/adult_female_questionnaire_widget.dart';
import 'questionnaire_widgets/middle_age_questionnaire_widget.dart';
import 'questionnaire_widgets/elderly_questionnaire_widget.dart';

class SmartQuestionnairePage extends StatefulWidget {
  const SmartQuestionnairePage({super.key});

  @override
  State<SmartQuestionnairePage> createState() => _SmartQuestionnairePageState();
}

class _SmartQuestionnairePageState extends State<SmartQuestionnairePage> {
  late QuestionnaireCategory _category;
  late String _categoryName;

  @override
  void initState() {
    super.initState();
    final provider = context.read<RegistrationProvider>();
    _determineCategory(provider);
  }

  void _determineCategory(RegistrationProvider provider) {
    if (provider.registrationData.birthDate != null &&
        provider.registrationData.gender != null) {
      _category = QuestionnaireUtils.determineCategory(
        provider.registrationData.birthDate!,
        provider.registrationData.gender,
      );
      _categoryName = QuestionnaireUtils.getCategoryName(_category);
    } else {
      _category = QuestionnaireCategory.adultMale;
      _categoryName = '成人';
    }
  }

  void _handleQuestionnaireDataChanged(Map<String, dynamic> data) {
    context.read<RegistrationProvider>().updateQuestionnaireData(data);
  }

  Widget _buildQuestionnaireWidget(QuestionnaireCategory category) {
    final provider = context.read<RegistrationProvider>();
    final initialData = provider.registrationData.questionnaireData ?? {};

    switch (category) {
      case QuestionnaireCategory.child:
        return ChildQuestionnaireWidget(
          initialData: initialData,
          onDataChanged: _handleQuestionnaireDataChanged,
        );
      case QuestionnaireCategory.teen:
        return TeenagerQuestionnaireWidget(
          initialData: initialData,
          onDataChanged: _handleQuestionnaireDataChanged,
        );
      case QuestionnaireCategory.adultMale:
        return AdultMaleQuestionnaireWidget(
          initialData: initialData,
          onDataChanged: _handleQuestionnaireDataChanged,
        );
      case QuestionnaireCategory.adultFemale:
        return AdultFemaleQuestionnaireWidget(
          initialData: initialData,
          onDataChanged: _handleQuestionnaireDataChanged,
        );
      case QuestionnaireCategory.middleAge:
        return MiddleAgeQuestionnaireWidget(
          initialData: initialData,
          onDataChanged: _handleQuestionnaireDataChanged,
        );
      case QuestionnaireCategory.elderly:
        return ElderlyQuestionnaireWidget(
          initialData: initialData,
          onDataChanged: _handleQuestionnaireDataChanged,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegistrationProvider>(
      builder: (context, provider, _) {
        // Re-determine category when birth date or gender changes
        if (provider.registrationData.birthDate != null &&
            provider.registrationData.gender != null) {
          final newCategory = QuestionnaireUtils.determineCategory(
            provider.registrationData.birthDate!,
            provider.registrationData.gender,
          );
          if (newCategory != _category) {
            _category = newCategory;
            _categoryName = QuestionnaireUtils.getCategoryName(_category);
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('智能问卷调查'),
            elevation: 0,
            backgroundColor: Colors.blue[700],
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Category Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border(
                    bottom: BorderSide(color: Colors.blue[200]!, width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '问卷类型',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _categoryName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '基于您的年龄${_calculateAge(provider.registrationData.birthDate)}岁和性别${_getGenderDisplay(provider.registrationData.gender)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              // Questionnaire Content
              Expanded(
                child: _buildQuestionnaireWidget(_category),
              ),
              // Navigation Buttons
              Container(
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
                        onPressed:
                            provider.registrationData.questionnaireData != null
                                ? provider.nextStep
                                : null,
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
              ),
            ],
          ),
        );
      },
    );
  }

  int _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    return QuestionnaireUtils.calculateAge(birthDate);
  }

  String _getGenderDisplay(String? gender) {
    switch (gender) {
      case 'male':
        return '男性';
      case 'female':
        return '女性';
      case 'other':
        return '其他';
      default:
        return '未知';
    }
  }
}
