/// Advanced health information model
class AdvancedHealthInfo {
  // Chronic diseases
  final List<String> chronicDiseases; // e.g., ['高血压', '糖尿病']

  // Food allergies
  final List<String> foodAllergies; // e.g., ['花生', '海鲜']

  // Current medications
  final String? currentMedications; // Multi-line text

  // Health report files
  final List<String> reportFiles; // Local file paths

  AdvancedHealthInfo({
    this.chronicDiseases = const [],
    this.foodAllergies = const [],
    this.currentMedications,
    this.reportFiles = const [],
  });

  /// Copy with support for partial updates
  AdvancedHealthInfo copyWith({
    List<String>? chronicDiseases,
    List<String>? foodAllergies,
    String? currentMedications,
    List<String>? reportFiles,
  }) {
    return AdvancedHealthInfo(
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      currentMedications: currentMedications ?? this.currentMedications,
      reportFiles: reportFiles ?? this.reportFiles,
    );
  }

  /// Check if any advanced info is provided
  bool get hasAnyInfo =>
      chronicDiseases.isNotEmpty ||
      foodAllergies.isNotEmpty ||
      (currentMedications?.isNotEmpty ?? false) ||
      reportFiles.isNotEmpty;

  @override
  String toString() =>
      'AdvancedHealthInfo(diseases: ${chronicDiseases.length}, allergies: ${foodAllergies.length}, meds: ${currentMedications?.isNotEmpty ?? false}, files: ${reportFiles.length})';
}
