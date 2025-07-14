import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'dart:io' show Platform;

import 'package:zenify/camera_page.dart';
import 'package:zenify/home.dart';
import 'package:zenify/report_page.dart';
import 'package:zenify/profile_page.dart';
import 'package:zenify/login.dart';
import 'package:zenify/services/api_service.dart';
import 'package:zenify/services/user_session.dart';
import 'package:zenify/utils/iconfont.dart';

void _setWindowSize() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zenify App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'iconfont',
      ),
      home: UserSession.userId != null ? MainPage() : Login(),
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
      // 应用退出
      ApiService.close();
    }
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 2; // 默认选中首页（第3个Tab）

  // 5个页面的占位组件（实际替换为您的页面）
  final List<Widget> _pages = [
    ReportPage(), //我的报告
    CameraPage(), //拍照
    HomePage(), //首页
    // PlaceholderWidget(title: "食物仓库", color: Colors.orange[100]!),
    ProfilePage(), //个人中心
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 关键点1：设置extendBody为true让内容延伸到导航栏后面
      extendBody: true,
      body: Stack(
        children: [
          // 关键点2：页面内容占满全屏
          Positioned.fill(
            child: _pages[_currentIndex],
          ),
          // 关键点3：悬浮导航栏定位在底部
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildCustomBottomNavBar(),
          ),
        ],
      ),
      // 移除原有的bottomNavigationBar参数
    );
  }

  // 自定义底部导航栏
  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 56, // 高度
      margin: EdgeInsets.only(
        bottom: 20, // 距离底部20px
        left: 20, // 左右边距10px
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.9),
        borderRadius: BorderRadius.circular(28), // 圆角（直径的一半）
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icon(IconFont.daohangweixuanzhongTongji),
              Icon(IconFont.daohangxuanzhongTongji)),
          _buildNavItem(1, Icon(IconFont.daohangweixuanzhongPaizhao),
              Icon(IconFont.daohangxuanzhongPaizhao)),
          _buildNavItem(2, Icon(IconFont.shouye), Icon(IconFont.shouye2)),
          // _buildNavItem(3, Icons.kitchen, "食物仓库"),
          _buildNavItem(3, Icon(IconFont.daohangweixuanzhongWode),
              Icon(IconFont.daohangxuanzhongWode)),
        ],
      ),
    );
  }

  // 单个导航项
  Widget _buildNavItem(int index, Icon icon, Icon selectIcon) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isSelected ? selectIcon : icon,
        ],
      ),
    );
  }
}

// 占位页面（替换为您的实际页面）
class PlaceholderWidget extends StatelessWidget {
  final String title;
  final Color color;

  const PlaceholderWidget({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(child: Text(title, style: TextStyle(fontSize: 24))),
    );
  }
}
