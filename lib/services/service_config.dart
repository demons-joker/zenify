enum HttpMethod { get, post, put, delete, patch }

class ApiEndpoint {
  final String path;
  final HttpMethod method;

  const ApiEndpoint(this.path, this.method);
}

class ApiConfig {
  // static const String baseUrl = "https://www.maididi.com";
  // static const String baseUrl = "http://127.0.0.1:8000";
  static const String baseUrl = "http://118.195.149.172:8000";

  static const String apiVersion = "/api/v1";
  static const String mqttVersion = "/api/mqtt";
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  // 登录接口
  static const login = ApiEndpoint(
    '$apiVersion/users/login',
    HttpMethod.post,
  );

  // 注册接口
  static const register = ApiEndpoint(
    '$apiVersion/users/register',
    HttpMethod.post,
  );
  // 获取用户信息
  static const userInfo = ApiEndpoint(
    '$apiVersion/users/{user_id}',
    HttpMethod.get,
  );

  // 注册接口
  static const createUserIngredient = ApiEndpoint(
    '$apiVersion/users/{userId}/ingredients',
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
    '$apiVersion/recipes/{recipe_id}/foods',
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
    '$apiVersion/users/{user_id}/recipe-plans/{plan_id}/meals',
    HttpMethod.get,
  );

  static const addPlanMealFood = ApiEndpoint(
    '$apiVersion/users/{user_id}/recipe-plans/{plan_id}/meals',
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
    '$apiVersion/users/{user_id}/generate-custom-recipe',
    HttpMethod.post,
  );
  //新增接口--------------start-------------
  //获取当前用户食谱数据
  static const getCurrentUserRecipes = ApiEndpoint(
    '$apiVersion/users/{user_id}/recipe-plans/current',
    HttpMethod.get,
  );
  //绑定用户食谱数据
  static const updateCurrentUserRecipes = ApiEndpoint(
    '$apiVersion/users/{user_id}/recipe-plans/update',
    HttpMethod.put,
  );
  //获取当前用户食物数据
  static const getCurrentUserFoods = ApiEndpoint(
    '$apiVersion/users/{user_id}/recipe-plans/current/foods',
    HttpMethod.get,
  );
  //获取当天的饮食记录
  static const getUserTodayMealRecords = ApiEndpoint(
    '$apiVersion/users/{user_id}/plates/{plate_id}/meal-records/today',
    HttpMethod.get,
  );
  //获取饮食记录详情
  static const getMealRecordsDetail = ApiEndpoint(
    '$apiVersion/users/{user_id}/plates/{plate_id}/meal-records/{meal_record_id}',
    HttpMethod.get,
  );
  //替换计划中的食物项
  static const replacePlanFood = ApiEndpoint(
    '$apiVersion/plan/foods/replace/{plan_food_id}',
    HttpMethod.put,
  );

  //获取图像识别结果（会耗费很多时间）
  static const getRecognize = ApiEndpoint(
    '$mqttVersion/users/{user_id}/plates/{plate_id}/recognize',
    HttpMethod.post,
  );
  //获取图像识别结果（会耗费很多时间）
  static const aiChart = '$apiVersion/chat';
  //整餐切换
  static const replaceFoods = ApiEndpoint(
    '$apiVersion/users/{user_id}/replace/foods',
    HttpMethod.put,
  );

  // 用户资料相关接口
  // 创建或更新用户资料
  static const createOrUpdateUserProfile = ApiEndpoint(
    '$apiVersion/users/{user_id}/profile',
    HttpMethod.post,
  );

  // 获取用户资料
  static const getUserProfile = ApiEndpoint(
    '$apiVersion/users/{user_id}/profile',
    HttpMethod.get,
  );

  // 更新用户资料
  static const updateUserProfile = ApiEndpoint(
    '$apiVersion/users/{user_id}/profile',
    HttpMethod.put,
  );
}
