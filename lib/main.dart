import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:zenify/presentation/app_navigation_screen/app_navigation_screen.dart';
import 'package:zenify/presentation/main_page.dart';

import 'package:zenify/services/user_session.dart';
import 'package:flutter/services.dart';

import 'core/app_export.dart';

void _setWindowSize() {
  // On web Platform.* access is unsupported; guard with kIsWeb.
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    setWindowTitle('Zenify App');
    setWindowMinSize(const Size(375, 667));
    setWindowMaxSize(const Size(375, 667));
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: 375,
        height: 667,
      ));
    });
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _setWindowSize();
  // Ensure `SizeUtils` is initialized before any widgets using `.h`/`.fSize`
  // extensions run by making `Sizer` the root widget.
  runApp(const Sizer(builder: _rootBuilder));
}

Widget _rootBuilder(
    BuildContext context, Orientation orientation, DeviceType deviceType) {
  return MyApp();
}

class MyApp extends StatelessWidget {
  // 异步检查用户会话状态
  static Future<bool> _checkUserSession(bool forceRegistration) async {
    if (forceRegistration) {
      return true; // 强制注册流程
    }

    try {
      final userId = await UserSession.userId;
      return userId == null; // 如果没有userId，需要注册
    } catch (e) {
      print('Error checking user session: $e');
      return true; // 出错时默认进入注册流程
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    // Force registration flow when compiling with:
    // flutter run --dart-define=FORCE_REGISTRATION=true
    // Default is false for production.
    const bool kForceRegistration =
        bool.fromEnvironment('FORCE_REGISTRATION', defaultValue: false);

    return MaterialApp(
      title: 'Zenify App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'iconfont',
        scaffoldBackgroundColor: Color(0xFFF6F6F6),
      ),
      // Use FutureBuilder to handle async user session check
      home: FutureBuilder<bool>(
        future: _checkUserSession(kForceRegistration),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Color(0xFFF6F6F6),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // final needsRegistration = false;
          final needsRegistration = snapshot.data ?? true;
          // If user doesn't need registration, navigate to the updated home (IndexPage)
          return needsRegistration ? AppNavigationScreen() : MainPage();
        },
      ),
      // For quick preview: start the app directly on the Report Detail page.
      // Change back to AppRoutes.initialRoute when you're done previewing.
      // static const String reportPage = '/report';
      // static const String profilePage = '/profile';
      // static const String reportDetail = '/report_detail';

      // // Legacy pages (with required parameters - use navigation helper methods)
      // static const String menuPage = '/menu';
      // static const String dishDetail = '/dish_detail';
      // static const String recipeList = '/recipe_list';

      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.routes,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        _AppLifecycleObserver(),
      ],
    );
  }
}

class _AppLifecycleObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/') {
      // 应用进入前台
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute?.settings.name == '/') {
      // 仅打印日志，不关闭客户端
      print('返回首页---------------------');
    }
  }
}
