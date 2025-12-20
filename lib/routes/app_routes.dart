import 'package:flutter/material.dart';
// Presentation screens
import '../presentation/user_profile_setup_screen/user_profile_setup_screen.dart';
import '../presentation/goal_selection_screen/goal_selection_screen.dart';
import '../presentation/third_question_screen/third_question_screen.dart';
import '../presentation/preference_selection_screen/preference_selection_screen.dart';
import '../presentation/food_source_selection_screen/food_source_selection_screen.dart';
import '../presentation/food_dislike_screen/food_dislike_screen.dart';
import '../presentation/eating_style_screen/eating_style_screen.dart';
import '../presentation/eating_routine_screen/eating_routine_screen.dart';
import '../presentation/allergy_screen/allergy_screen.dart';
import '../presentation/activity_level_screen/activity_level_screen.dart';
import '../presentation/registration_complete_screen/registration_complete_screen.dart';
import '../presentation/app_navigation_screen/app_navigation_screen.dart';
// Auth pages
import '../presentation/auth/login.dart';
import '../presentation/registration/registration_flow.dart';
import '../presentation/main_page.dart';
// Home pages
import '../presentation/home/home.dart';
import '../presentation/home/index.dart';
// Camera page
import '../presentation/camera/camera_page.dart';
// AI Chat page
import '../presentation/ai_chat/ai_chat_page.dart';
// Report pages
import '../presentation/report/report.dart';
import '../presentation/report/report_page.dart';
// Profile page
import '../presentation/profile/profile_page.dart';
// Menu page
import '../presentation/menu/menu_page.dart';
// Dish detail page
import '../presentation/dish_detail/dish_detail_page.dart';
// Recipe page
import '../presentation/recipe/recipe_list.dart';

class AppRoutes {
  // Presentation screens
  static const String userProfileSetupScreen = '/user_profile_setup_screen';
  static const String goalSelectionScreen = '/goal_selection_screen';
  static const String thirdQuestionScreen = '/third_question_screen';
  static const String preferenceSelectionScreen = '/preference_selection_screen';
  static const String foodSourceSelectionScreen = '/food_source_selection_screen';
  static const String foodDislikeScreen = '/food_dislike_screen';
  static const String eatingStyleScreen = '/eating_style_screen';
  static const String eatingRoutineScreen = '/eating_routine_screen';
  static const String allergyScreen = '/allergy_screen';
  static const String activityLevelScreen = '/activity_level_screen';
  static const String registrationCompleteScreen = '/registration_complete_screen';
  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  // Auth pages
  static const String login = '/login';
  static const String registration = '/registration';

  // Legacy pages (no parameters required)
  static const String mainPage = '/main';
  static const String home = '/home';
  static const String indexPage = '/index';
  static const String cameraPage = '/camera';
  static const String aiChatPage = '/ai_chat';
  static const String reportPage = '/report';
  static const String profilePage = '/profile';

  // Legacy pages (with required parameters - use navigation helper methods)
  static const String menuPage = '/menu';
  static const String dishDetail = '/dish_detail';
  static const String recipeList = '/recipe_list';

  static Map<String, WidgetBuilder> get routes => {
        // Presentation screens
        appNavigationScreen: (context) => AppNavigationScreen(),
        userProfileSetupScreen: (context) => UserProfileSetupScreen(),
        goalSelectionScreen: (context) => GoalSelectionScreen(),
        thirdQuestionScreen: (context) => ThirdQuestionScreen(),
        preferenceSelectionScreen: (context) => PreferenceSelectionScreen(),
        foodSourceSelectionScreen: (context) => FoodSourceSelectionScreen(),
        foodDislikeScreen: (context) => FoodDislikeScreen(),
        eatingStyleScreen: (context) => EatingStyleScreen(),
        eatingRoutineScreen: (context) => EatingRoutineScreen(),
        allergyScreen: (context) => AllergyScreen(),
        activityLevelScreen: (context) => ActivityLevelScreen(),
        registrationCompleteScreen: (context) => RegistrationCompleteScreen(),
        // Auth pages
        login: (context) => Login(),
        registration: (context) => RegistrationFlow(),
        // Legacy pages
        mainPage: (context) => MainPage(),
        home: (context) => HomePage(),
        indexPage: (context) => IndexPage(),
        cameraPage: (context) => CameraPage(),
        aiChatPage: (context) => AIChatPage(),
        reportPage: (context) => Report(),
        profilePage: (context) => ProfilePage(),
      };

  /// Navigate to CameraPage
  /// Usage: AppRoutes.navigateToCameraPage(context).then((_) => {/*onReturn*/})
  static Future navigateToCameraPage(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => CameraPage()),
    );
  }

  /// Navigate to AIChatPage
  /// Usage: AppRoutes.navigateToAiChat(context).then((_) => {/*onReturn*/})
  static Future navigateToAiChat(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AIChatPage()),
    );
  }

  /// Navigate to MenuPage with required parameters
  /// Usage: AppRoutes.navigateToMenuPage(context, category, recipeFoodId, recipeFoods).then((_) => {/*onReturn*/})
  static Future navigateToMenuPage(
    BuildContext context, {
    required String category,
    required int recipeFoodId,
    required List<dynamic> recipeFoods,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MenuPage(
          category: category,
          recipeFoodId: recipeFoodId,
          recipeFoods: recipeFoods,
        ),
      ),
    );
  }

  /// Navigate to DishDetailPage with required parameters
  /// Usage: AppRoutes.navigateToDishDetail(context, dish)
  static void navigateToDishDetail(
    BuildContext context, {
    required dynamic dish,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DishDetailPage(dish: dish),
      ),
    );
  }

  /// Navigate to RecipeListPage with required parameters
  /// Usage: AppRoutes.navigateToRecipeList(context, initialRecipe, onRecipeSelected).then((_) => {/*onReturn*/})
  static Future navigateToRecipeList(
    BuildContext context, {
    required dynamic initialRecipe,
    required Function(dynamic) onRecipeSelected,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeListPage(
          initialRecipe: initialRecipe,
          onRecipeSelected: onRecipeSelected,
        ),
      ),
    );
  }

  /// Navigate to Login page and replace current route
  /// Usage: AppRoutes.navigateToLoginAndReplace(context)
  static void navigateToLoginAndReplace(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  /// Navigate to MainPage and replace current route
  /// Usage: AppRoutes.navigateToMainPageAndReplace(context)
  static void navigateToMainPageAndReplace(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }

  /// Navigate to ReportPage with optional mealRecordId parameter
  /// Usage: AppRoutes.navigateToReportPage(context, mealRecordId: id)
  static void navigateToReportPage(BuildContext context,
      {dynamic mealRecordId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportPage(mealRecordId: mealRecordId),
      ),
    );
  }

  /// Navigate to Registration flow
  /// Usage: AppRoutes.navigateToRegistration(context)
  static void navigateToRegistration(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => RegistrationFlow(),
      ),
    );
  }
}
