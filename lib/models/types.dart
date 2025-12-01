// lib/models/types.dart

class UserData {
  final String? gender; // 'male', 'female', 'other'
  final int weight;
  final int height;
  final int age;
  final String? goal;
  final String? preference;
  final List<String> foodHabits; // Ordered list of habits
  final List<String> allergies;
  final String? activityLevel;

  UserData({
    this.gender,
    required this.weight,
    required this.height,
    required this.age,
    this.goal,
    this.preference,
    this.foodHabits = const [],
    this.allergies = const [],
    this.activityLevel,
  });

  UserData copyWith({
    String? gender,
    int? weight,
    int? height,
    int? age,
    String? goal,
    String? preference,
    List<String>? foodHabits,
    List<String>? allergies,
    String? activityLevel,
  }) {
    return UserData(
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      preference: preference ?? this.preference,
      foodHabits: foodHabits ?? this.foodHabits,
      allergies: allergies ?? this.allergies,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }
}

enum OnboardingStep {
  welcome,
  introChat,
  basics,
  goal,
  preference,
  foodHabits,
  allergies,
  activity,
  completion,
}

class FoodOption {
  final String id;
  final String label;
  final String emoji;

  FoodOption({
    required this.id,
    required this.label,
    required this.emoji,
  });
}

class ActivityOption {
  final String id;
  final String label;
  final String emoji;

  ActivityOption({
    required this.id,
    required this.label,
    required this.emoji,
  });
}

final List<FoodOption> foodOptions = [
  FoodOption(id: 'fish', label: 'Fish & Seafood', emoji: '🐟'),
  FoodOption(id: 'eggs', label: 'Eggs', emoji: '🥚'),
  FoodOption(id: 'meat', label: 'Meat', emoji: '🍗'),
  FoodOption(id: 'dairy', label: 'Dairy Products', emoji: '🥛'),
  FoodOption(id: 'fruits', label: 'Fruits', emoji: '🍎'),
  FoodOption(id: 'veggies', label: 'Vegetables', emoji: '🥦'),
  FoodOption(id: 'grains', label: 'Grains / Staples', emoji: '🍚'),
];

final List<String> goalOptions = [
  'Weight Loss',
  'Weight Gain',
  'Chronic Mgmt',
  'Energy & Focus',
  'Muscle Build',
  'Healthy Lifestyle'
];

final List<String> allergyOptions = [
  'Gluten allergy',
  'Nut allergy (peanuts, walnuts, etc)',
  'Dairy allergy (milk, cheese, etc)',
  'Seafood allergy',
  'Egg allergy'
];

final List<ActivityOption> activityOptions = [
  ActivityOption(
      id: 'sedentary', label: 'Sedentary / Mostly sitting', emoji: '🧘‍♀️'),
  ActivityOption(id: 'commuting', label: 'Daily commuting', emoji: '🚶'),
  ActivityOption(
      id: 'occasional', label: 'Occasional exercise', emoji: '🏃‍♀️'),
  ActivityOption(id: 'light', label: 'Regular light exercise', emoji: '🤸'),
  ActivityOption(id: 'heavy', label: 'Regular high-intensity', emoji: '🚴'),
];
