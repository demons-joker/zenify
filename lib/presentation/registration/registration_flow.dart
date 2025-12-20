import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zenify/providers/registration_provider.dart';
import 'basic_info_page.dart';
import 'smart_questionnaire_page.dart';
import 'goals_page.dart';
import 'advanced_info_page.dart';

/// Registration flow entry point
/// Wraps registration pages with RegistrationProvider
class RegistrationFlow extends StatelessWidget {
  const RegistrationFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegistrationProvider>(
      create: (_) => RegistrationProvider(),
      child: Consumer<RegistrationProvider>(
        builder: (context, provider, _) {
          // Route to appropriate step based on currentStep
          switch (provider.currentStep) {
            case 1:
              return const BasicInfoPage();
            case 2:
              return const SmartQuestionnairePage();
            case 3:
              return const GoalsPage();
            case 4:
              return const AdvancedInfoPage();
            default:
              return const BasicInfoPage();
          }
        },
      ),
    );
  }
}
