import 'package:zenify/models/registration_state.dart';

/// Utility class for questionnaire logic
class QuestionnaireUtils {
  /// Calculate age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Determine questionnaire category based on age and gender
  static QuestionnaireCategory determineCategory(
      DateTime birthDate, String? gender) {
    final age = calculateAge(birthDate);

    if (age <= 12) {
      return QuestionnaireCategory.child;
    } else if (age <= 18) {
      return QuestionnaireCategory.teen;
    } else if (age <= 45) {
      return gender == 'female'
          ? QuestionnaireCategory.adultFemale
          : QuestionnaireCategory.adultMale;
    } else if (age <= 65) {
      return QuestionnaireCategory.middleAge;
    } else {
      return QuestionnaireCategory.elderly;
    }
  }

  /// Get category display name
  static String getCategoryName(QuestionnaireCategory category) {
    switch (category) {
      case QuestionnaireCategory.child:
        return '儿童';
      case QuestionnaireCategory.teen:
        return '青少年';
      case QuestionnaireCategory.adultMale:
        return '成年男性';
      case QuestionnaireCategory.adultFemale:
        return '成年女性';
      case QuestionnaireCategory.middleAge:
        return '中年人';
      case QuestionnaireCategory.elderly:
        return '老年人';
    }
  }
}
