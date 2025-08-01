// GENERATED CODE - DO NOT MODIFY BY HAND

// 食材类型
enum IngredientType {
  fresh,
  packaged,
}

// 食材分类
enum IngredientCategory {
  vegetable,
  carbohydrate,
  protein,
  other,
}

// 餐点类型
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  brunch,
  afternoonTea,
  midnightSnack,
  extraMeal,
}

// 计划状态
enum PlanStatus {
  active,
  completed,
  paused,
}

// 食物分类
enum FoodCategory {
  vegetable,
  fruit,
  protein,
  carbohydrate,
  fat,
  other,
}

// 蔬菜子分类
enum VegetableSubCategory {
  leafy,
  root,
  bean,
  cruciferous,
  other,
}

// 水果子分类
enum FruitSubCategory {
  citrus,
  berry,
  stone,
  melon,
  other,
}

// 蛋白质子分类
enum ProteinSubCategory {
  chicken,
  beef,
  pork,
  fish,
  egg,
  tofu,
  other,
}

// 碳水子分类
enum CarbohydrateSubCategory {
  rice,
  noodle,
  bread,
  potato,
  other,
}

// 脂肪子分类
enum FatSubCategory {
  oil,
  nut,
  seed,
  other,
}

// 其他食物子分类
enum OtherFoodSubCategory {
  seasoning,
  sauce,
  other,
}

// 用户会话阶段
enum UserSessionPhaseEnum {
  startPreparing,
  startEating,
  endEating,
}

// 用户会话类型
enum UserSessionType {
  randomMeal,
  plannedMeal,
}

// 用户会话状态
enum UserSessionStatus {
  active,
  inactive,
}

// 扩展方法：为所有枚举添加中文描述
extension IngredientTypeExtension on IngredientType {
  String get displayName {
    switch (this) {
      case IngredientType.fresh:
        return '新鲜食材';
      case IngredientType.packaged:
        return '包装食材';
    }
  }
}

extension IngredientCategoryExtension on IngredientCategory {
  String get displayName {
    switch (this) {
      case IngredientCategory.vegetable:
        return '蔬菜';
      case IngredientCategory.carbohydrate:
        return '碳水';
      case IngredientCategory.protein:
        return '蛋白质';
      case IngredientCategory.other:
        return '其他';
    }
  }
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return '早餐';
      case MealType.lunch:
        return '中餐';
      case MealType.dinner:
        return '晚餐';
      case MealType.snack:
        return '零食';
      case MealType.brunch:
        return '早午餐';
      case MealType.afternoonTea:
        return '下午茶';
      case MealType.midnightSnack:
        return '宵夜';
      case MealType.extraMeal:
        return '加餐';
    }
  }
}

extension PlanStatusExtension on PlanStatus {
  String get displayName {
    switch (this) {
      case PlanStatus.active:
        return '进行中';
      case PlanStatus.completed:
        return '已完成';
      case PlanStatus.paused:
        return '暂停';
    }
  }
}

extension FoodCategoryExtension on FoodCategory {
  String get displayName {
    switch (this) {
      case FoodCategory.vegetable:
        return '蔬菜';
      case FoodCategory.fruit:
        return '水果';
      case FoodCategory.protein:
        return '蛋白质';
      case FoodCategory.carbohydrate:
        return '碳水';
      case FoodCategory.fat:
        return '脂肪';
      case FoodCategory.other:
        return '其他';
    }
  }
}

extension VegetableSubCategoryExtension on VegetableSubCategory {
  String get displayName {
    switch (this) {
      case VegetableSubCategory.leafy:
        return '叶菜类';
      case VegetableSubCategory.root:
        return '根茎类';
      case VegetableSubCategory.bean:
        return '豆类';
      case VegetableSubCategory.cruciferous:
        return '十字花科';
      case VegetableSubCategory.other:
        return '其他';
    }
  }
}

extension FruitSubCategoryExtension on FruitSubCategory {
  String get displayName {
    switch (this) {
      case FruitSubCategory.citrus:
        return '柑橘类';
      case FruitSubCategory.berry:
        return '浆果类';
      case FruitSubCategory.stone:
        return '核果类';
      case FruitSubCategory.melon:
        return '瓜类';
      case FruitSubCategory.other:
        return '其他';
    }
  }
}

extension ProteinSubCategoryExtension on ProteinSubCategory {
  String get displayName {
    switch (this) {
      case ProteinSubCategory.chicken:
        return '鸡肉';
      case ProteinSubCategory.beef:
        return '牛肉';
      case ProteinSubCategory.pork:
        return '猪肉';
      case ProteinSubCategory.fish:
        return '鱼';
      case ProteinSubCategory.egg:
        return '蛋';
      case ProteinSubCategory.tofu:
        return '豆腐';
      case ProteinSubCategory.other:
        return '其他';
    }
  }
}

extension CarbohydrateSubCategoryExtension on CarbohydrateSubCategory {
  String get displayName {
    switch (this) {
      case CarbohydrateSubCategory.rice:
        return '米饭';
      case CarbohydrateSubCategory.noodle:
        return '面条';
      case CarbohydrateSubCategory.bread:
        return '面包';
      case CarbohydrateSubCategory.potato:
        return '杂粮';
      case CarbohydrateSubCategory.other:
        return '其他';
    }
  }
}

extension FatSubCategoryExtension on FatSubCategory {
  String get displayName {
    switch (this) {
      case FatSubCategory.oil:
        return '油';
      case FatSubCategory.nut:
        return '坚果';
      case FatSubCategory.seed:
        return '种子';
      case FatSubCategory.other:
        return '其他';
    }
  }
}

extension OtherFoodSubCategoryExtension on OtherFoodSubCategory {
  String get displayName {
    switch (this) {
      case OtherFoodSubCategory.seasoning:
        return '调味品';
      case OtherFoodSubCategory.sauce:
        return '酱料';
      case OtherFoodSubCategory.other:
        return '其他';
    }
  }
}

extension UserSessionPhaseEnumExtension on UserSessionPhaseEnum {
  String get displayName {
    switch (this) {
      case UserSessionPhaseEnum.startPreparing:
        return '开始准备';
      case UserSessionPhaseEnum.startEating:
        return '开始用餐';
      case UserSessionPhaseEnum.endEating:
        return '结束用餐';
    }
  }
}

extension UserSessionTypeExtension on UserSessionType {
  String get displayName {
    switch (this) {
      case UserSessionType.randomMeal:
        return '随机餐点';
      case UserSessionType.plannedMeal:
        return '计划餐点';
    }
  }
}

extension UserSessionStatusExtension on UserSessionStatus {
  String get displayName {
    switch (this) {
      case UserSessionStatus.active:
        return '活跃';
      case UserSessionStatus.inactive:
        return '非活跃';
    }
  }
}
