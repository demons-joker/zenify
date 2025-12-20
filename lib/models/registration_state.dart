import 'package:zenify/models/advanced_health_info.dart';

/// Questionnaire category based on age and gender
enum QuestionnaireCategory {
  child,
  teen,
  adultMale,
  adultFemale,
  middleAge,
  elderly,
}

/// User registration information model
class UserRegistrationData {
  // Step 1: Basic Info
  String? name;
  String? gender; // male, female, other
  DateTime? birthDate;

  // Step 2: Smart Questionnaire
  Map<String, dynamic>? questionnaireData; // Dynamic questionnaire responses

  // Step 3: Health Goals
  List<String>? selectedGoalIds; // IDs of selected health goals

  // Step 4: Advanced Info (Optional)
  AdvancedHealthInfo? advancedInfo; // Advanced health information

  // Step 5: Account info
  String? email;
  String? password;
  String? confirmPassword;

  UserRegistrationData({
    this.name,
    this.gender,
    this.birthDate,
    this.questionnaireData,
    this.selectedGoalIds,
    this.advancedInfo,
    this.email,
    this.password,
    this.confirmPassword,
  });

  /// Copy with support for partial updates
  UserRegistrationData copyWith({
    String? name,
    String? gender,
    DateTime? birthDate,
    Map<String, dynamic>? questionnaireData,
    List<String>? selectedGoalIds,
    AdvancedHealthInfo? advancedInfo,
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    return UserRegistrationData(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      questionnaireData: questionnaireData ?? this.questionnaireData,
      selectedGoalIds: selectedGoalIds ?? this.selectedGoalIds,
      advancedInfo: advancedInfo ?? this.advancedInfo,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }

  /// Check if Step 1 is complete
  bool get isStep1Complete =>
      name != null && name!.isNotEmpty && gender != null && birthDate != null;

  /// Check if Step 2 is complete
  bool get isStep2Complete =>
      questionnaireData != null && questionnaireData!.isNotEmpty;

  /// Check if Step 3 is complete
  bool get isStep3Complete =>
      selectedGoalIds != null && selectedGoalIds!.isNotEmpty;

  /// Check if Step 4 is complete (optional, always true)
  bool get isStep4Complete => true;

  /// Check if all required steps are complete (Step 1-4)
  bool get isComplete => isStep1Complete && isStep2Complete && isStep3Complete;

  /// Check if Step 5 (account) is complete
  bool get isStep5Complete =>
      email != null &&
      email!.isNotEmpty &&
      password != null &&
      password!.isNotEmpty;

  @override
  String toString() {
    return 'UserRegistrationData(name: $name, gender: $gender, birthDate: $birthDate, email: $email, questionnaire: ${questionnaireData?.keys.length ?? 0} fields, goals: ${selectedGoalIds?.length ?? 0})';
  }
}
