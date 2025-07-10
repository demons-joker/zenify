enum HttpMethod { get, post, put, delete, patch }

class ApiEndpoint {
  final String path;
  final HttpMethod method;

  const ApiEndpoint(this.path, this.method);
}

class ApiConfig {
  //static const String baseUrl = "http://118.195.149.172:8000";
  static const String baseUrl = "http://127.0.0.1:8000";
  static const String apiVersion = "/api/v1";
  static const int connectTimeout = 5000;
  static const int receiveTimeout = 5000;
  // 登录接口
  static const login = ApiEndpoint(
    '$apiVersion/login',
    HttpMethod.post,
  );

  // 注册接口
  static const register = ApiEndpoint(
    '$apiVersion/register',
    HttpMethod.post,
  );
  // 获取用户信息
  static const userInfo = ApiEndpoint(
    '$apiVersion/users/{user_id}',
    HttpMethod.get,
  );

  // 注册接口
  static const createUserIngredient = ApiEndpoint(
    '$apiVersion/users/{userId}/ingredients/',
    HttpMethod.post,
  );
  // 获取用户食材
  static const getUserIngredient = ApiEndpoint(
    '$apiVersion/users/{userId}/ingredients',
    HttpMethod.get,
  );
  // 更新用户食材
  static const updateUserIngredient = ApiEndpoint(
    '$apiVersion/users/{userId}/ingredients/{ingredientId}',
    HttpMethod.put,
  );
  // 删除用户食材
  static const deleteUserIngredient = ApiEndpoint(
    '$apiVersion/users/{userId}/ingredients/{ingredientId}',
    HttpMethod.delete,
  );

  // 获取食材列表
  static const createFoods = ApiEndpoint(
    '$apiVersion/foods',
    HttpMethod.post,
  );

  // 获取食材列表
  static const getFoods = ApiEndpoint(
    '$apiVersion/foods',
    HttpMethod.get,
  );

  // 获取食材详情
  static const getFood = ApiEndpoint(
    '$apiVersion/foods/{food_id}',
    HttpMethod.get,
  );

  // 更新食材
  static const getCategories =
      ApiEndpoint('$apiVersion/foods/categories', HttpMethod.get);
  // 获取食材分类
  static const getSubcategories =
      ApiEndpoint('$apiVersion/foods/subcategories', HttpMethod.get);
  // 获取食材子分类
  static const createRecipes = ApiEndpoint(
    '$apiVersion/recipes',
    HttpMethod.post,
  );
  // 获取食谱列表
  static const getRecipes = ApiEndpoint(
    '$apiVersion/recipes',
    HttpMethod.get,
  );
  // 获取食谱详情
  static const getRecipe = ApiEndpoint(
    '$apiVersion/recipes/{recipe_id}',
    HttpMethod.get,
  );
  // 更新食谱
  static const addFoodToRecipe = ApiEndpoint(
    '$apiVersion/recipes/{recipe_id}/foods/',
    HttpMethod.post,
  );

  //获取食谱计划
  static const getRecipeMealPlan = ApiEndpoint(
    '$apiVersion/recipes/{recipe_id}/meal-plan',
    HttpMethod.get,
  );
  // 创建食谱计划
  static const createRecipePlan = ApiEndpoint(
    '$apiVersion/users/{user_id}/recipe-plans',
    HttpMethod.post,
  );
  // 获取用户食谱计划
  static const getUserRecipePlans = ApiEndpoint(
    '$apiVersion/users/{user_id}/recipe-plans',
    HttpMethod.get,
  );
  // 获取用户食谱计划详情
  static const getUserRecipePlan = ApiEndpoint(
    '$apiVersion/users/{user_id}/recipe-plans/{plan_id}',
    HttpMethod.get,
  );
  // 更新食谱计划状态
  static const updateRecipePlan = ApiEndpoint(
    '$apiVersion/users/{user_id}/recipe-plans/{plan_id}/status',
    HttpMethod.put,
  );
  static const getPlanMealFoods = ApiEndpoint(
    '$apiVersion/users/{user_id}/recipe-plans/{plan_id}/meals/',
    HttpMethod.get,
  );

  static const addPlanMealFood = ApiEndpoint(
    '$apiVersion/users/{user_id}/recipe-plans/{plan_id}/meals/',
    HttpMethod.post,
  );

  static const userRecipePlanMeal = ApiEndpoint(
    '$apiVersion/users/{userId}/recipe-plans/{planId}/meals/{mealFoodId}',
    HttpMethod.get,
  );

  static const updateRecipePlanMeal = ApiEndpoint(
    '$apiVersion/users/{userId}/recipe-plans/{planId}/meals/{mealFoodId}',
    HttpMethod.put,
  );
  static const generateCustomRecipe = ApiEndpoint(
    '$apiVersion/users/{user_id}/generate-custom-recipe/',
    HttpMethod.post,
  );
}
