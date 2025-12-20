import 'package:flutter/material.dart';
import 'package:zenify/models/registration_state.dart';
import 'package:zenify/models/advanced_health_info.dart';

/// ChangeNotifier provider for user registration flow
class RegistrationProvider extends ChangeNotifier {
  UserRegistrationData _registrationData = UserRegistrationData();
  int _currentStep = 1; // Track current step (1-4)

  UserRegistrationData get registrationData => _registrationData;
  int get currentStep => _currentStep;

  /// Update name
  void updateName(String name) {
    _registrationData = _registrationData.copyWith(name: name);
    notifyListeners();
  }

  /// Update gender
  void updateGender(String gender) {
    _registrationData = _registrationData.copyWith(gender: gender);
    notifyListeners();
  }

  /// Update birth date
  void updateBirthDate(DateTime date) {
    _registrationData = _registrationData.copyWith(birthDate: date);
    notifyListeners();
  }

  /// Update email
  void updateEmail(String email) {
    _registrationData = _registrationData.copyWith(email: email);
    notifyListeners();
  }

  /// Update password
  void updatePassword(String password) {
    _registrationData = _registrationData.copyWith(password: password);
    notifyListeners();
  }

  /// Update questionnaire data
  void updateQuestionnaireData(Map<String, dynamic> data) {
    _registrationData = _registrationData.copyWith(questionnaireData: data);
    notifyListeners();
  }

  /// Update selected health goals
  void updateSelectedGoals(List<String> goalIds) {
    _registrationData = _registrationData.copyWith(selectedGoalIds: goalIds);
    notifyListeners();
  }

  /// Update advanced health information
  void updateAdvancedInfo(AdvancedHealthInfo advancedInfo) {
    _registrationData = _registrationData.copyWith(advancedInfo: advancedInfo);
    notifyListeners();
  }

  /// Move to next step
  void nextStep() {
    if (_currentStep < 4) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Move to previous step
  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Reset to step 1
  void reset() {
    _currentStep = 1;
    _registrationData = UserRegistrationData();
    notifyListeners();
  }

  /// Complete registration
  Future<bool> completeRegistration() async {
    // TODO: Implement API call to register user
    // This should call the API with _registrationData
    return true;
  }
}
