class MealRecord {
  final int id;
  final String imageUrl;
  final String startTime;
  final num durationMinutes;
  final num totalCalories;
  final String mealType;
  final String notes;
  final List<Food> foods;
  final NutritiveProportion nutritiveProportion;
  final NutritionAnalysis nutritionAnalysis;
  final HealthTips healthTips;

  MealRecord({
    required this.id,
    required this.imageUrl,
    required this.startTime,
    required this.durationMinutes,
    required this.totalCalories,
    required this.mealType,
    required this.notes,
    required this.foods,
    required this.nutritiveProportion,
    required this.nutritionAnalysis,
    required this.healthTips,
  });

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      id: json['id'],
      imageUrl: json['image_url'],
      startTime: json['start_time'],
      durationMinutes: json['duration_minutes'],
      totalCalories: json['total_calories'],
      mealType: json['meal_type'],
      notes: json['notes'],
      foods: List<Food>.from(json['foods'].map((x) => Food.fromJson(x))),
      nutritiveProportion:
          NutritiveProportion.fromJson(json['nutritive_proportion']),
      nutritionAnalysis: NutritionAnalysis.fromJson(json['nutrition_analysis']),
      healthTips: HealthTips.fromJson(json['health_tips']),
    );
  }
}

class Food {
  final num quantity;
  final String unit;
  final num calories;
  final int zoneId;
  final num supplyProportion;
  final FoodDetails food;

  Food({
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.zoneId,
    required this.supplyProportion,
    required this.food,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      quantity: json['quantity'],
      unit: json['unit'],
      calories: json['calories'],
      zoneId: json['zone_id'],
      supplyProportion: json['supply_proportion'],
      food: FoodDetails.fromJson(json['food']),
    );
  }
}

class FoodDetails {
  final String name;
  final String imageUrl;
  final String description;
  final String preparationMethod;
  final String category;
  final String subcategory;
  final num caloriesPer100g;
  final NutritionPer100g nutritionPer100g;
  final int id;

  FoodDetails({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.preparationMethod,
    required this.category,
    required this.subcategory,
    required this.caloriesPer100g,
    required this.nutritionPer100g,
    required this.id,
  });

  factory FoodDetails.fromJson(Map<String, dynamic> json) {
    return FoodDetails(
      name: json['name'],
      imageUrl: json['image_url'],
      description: json['description'],
      preparationMethod: json['preparation_method'],
      category: json['category'],
      subcategory: json['subcategory'],
      caloriesPer100g: json['calories_per_100g'],
      nutritionPer100g: NutritionPer100g.fromJson(json['nutrition_per_100g']),
      id: json['id'],
    );
  }
}

class NutritionPer100g {
  final num protein;
  final num fat;
  final num carbohydrate;
  final num calories;
  final num fiber;
  final List<Vitamin> vitamins;

  NutritionPer100g({
    required this.protein,
    required this.fat,
    required this.carbohydrate,
    required this.calories,
    required this.fiber,
    required this.vitamins,
  });

  factory NutritionPer100g.fromJson(Map<String, dynamic> json) {
    return NutritionPer100g(
      protein: json['protein'],
      fat: json['fat'],
      carbohydrate: json['carbohydrate'],
      calories: json['calories'],
      fiber: json['fiber'],
      vitamins:
          List<Vitamin>.from(json['vitamins'].map((x) => Vitamin.fromJson(x))),
    );
  }
}

class Vitamin {
  final String name;
  final num content;

  Vitamin({
    required this.name,
    required this.content,
  });

  factory Vitamin.fromJson(Map<String, dynamic> json) {
    return Vitamin(
      name: json['name'],
      content: json['content'] ?? json['amount'] ?? 0,
    );
  }
}

class NutritiveProportion {
  final num carbohydrate;
  final num protein;
  final num fat;
  final num fiber;
  final List<Vitamin> vitamins;

  NutritiveProportion({
    required this.carbohydrate,
    required this.protein,
    required this.fat,
    required this.fiber,
    required this.vitamins,
  });

  factory NutritiveProportion.fromJson(Map<String, dynamic> json) {
    return NutritiveProportion(
      carbohydrate: json['carbohydrate'],
      protein: json['protein'],
      fat: json['fat'],
      fiber: json['fiber'],
      vitamins:
          List<Vitamin>.from(json['vitamins'].map((x) => Vitamin.fromJson(x))),
    );
  }
}

class NutritionAnalysis {
  final bool balancedMeal;
  final num mealScore;
  final List<FoodDetails> highQualityProtein;
  final List<FoodDetails> highFiber;
  final List<FoodDetails> lowGi;
  final List<FoodDetails> immunityBoosting;
  final List<FoodDetails> antioxidant;
  final List<FoodDetails> calciumRich;
  final List<FoodDetails> acnePromoting;
  final List<FoodDetails> sleepAffecting;

  NutritionAnalysis({
    required this.balancedMeal,
    required this.mealScore,
    required this.highQualityProtein,
    required this.highFiber,
    required this.lowGi,
    required this.immunityBoosting,
    required this.antioxidant,
    required this.calciumRich,
    required this.acnePromoting,
    required this.sleepAffecting,
  });

  factory NutritionAnalysis.fromJson(Map<String, dynamic> json) {
    return NutritionAnalysis(
      balancedMeal: json['balanced_meal'],
      mealScore: json['meal_score'],
      highQualityProtein: List<FoodDetails>.from(
          json['high_quality_protein'].map((x) => FoodDetails.fromJson(x))),
      highFiber: List<FoodDetails>.from(
          json['high_fiber'].map((x) => FoodDetails.fromJson(x))),
      lowGi: List<FoodDetails>.from(
          json['low_gi'].map((x) => FoodDetails.fromJson(x))),
      immunityBoosting: List<FoodDetails>.from(
          json['immunity_boosting'].map((x) => FoodDetails.fromJson(x))),
      antioxidant: List<FoodDetails>.from(
          json['antioxidant'].map((x) => FoodDetails.fromJson(x))),
      calciumRich: List<FoodDetails>.from(
          json['calcium_rich'].map((x) => FoodDetails.fromJson(x))),
      acnePromoting: List<FoodDetails>.from(
          json['acne_promoting'].map((x) => FoodDetails.fromJson(x))),
      sleepAffecting: List<FoodDetails>.from(
          json['sleep_affecting'].map((x) => FoodDetails.fromJson(x))),
    );
  }
}

class HealthTips {
  final String postMealExercise;
  final String dietarySuggestions;
  final String digestionNote;
  final String cookingMethodAdvice;

  HealthTips({
    required this.postMealExercise,
    required this.dietarySuggestions,
    required this.digestionNote,
    required this.cookingMethodAdvice,
  });

  factory HealthTips.fromJson(Map<String, dynamic> json) {
    return HealthTips(
      postMealExercise: json['post_meal_exercise'],
      dietarySuggestions: json['dietary_suggestions'],
      digestionNote: json['digestion_note'],
      cookingMethodAdvice: json['cooking_method_advice'],
    );
  }
}
