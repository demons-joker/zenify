import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'package:zenify/ai_chat_page.dart';
import 'dart:io' show Platform;

import 'package:zenify/camera_page.dart';
import 'package:zenify/home.dart';
import 'package:zenify/report.dart';
import 'package:zenify/profile_page.dart';
import 'package:zenify/login.dart';
import 'package:zenify/services/user_session.dart';
import 'package:zenify/utils/iconfont.dart';
import 'package:flutter/services.dart';

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
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return MaterialApp(
      title: 'Zenify App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'iconfont',
        scaffoldBackgroundColor: Color(0xFFF6F6F6),
      ),
      // ignore: unnecessary_null_comparison
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
      // 仅打印日志，不关闭客户端
      print('返回首页---------------------');
    }
  }
}

class MainPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0; // 默认选中首页（第3个Tab）
  bool _showBottomNavBar = true; // 控制导航栏显示状态

  // 页面列表
  final List<Widget> _pages = [
    HomePage(), // 首页
    Container(), // 拍照按钮占位，实际不会显示
    AIChatPage(), // AI聊天页面
    Report(), // 我的报告
    ProfilePage(), // 个人中心
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: SafeArea(
          child: Stack(
            children: [
              // 页面内容
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                            bottom: kBottomNavigationBarHeight),
                        child: IntrinsicHeight(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: _pages[_currentIndex],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 自定义底部导航栏（根据状态显示/隐藏）
              if (_showBottomNavBar)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildCustomBottomNavBar(),
                ),
            ],
          ),
        ));
  }

  // 自定义底部导航栏
  Widget _buildCustomBottomNavBar() {
    return Container(
      height: 56,
      margin: EdgeInsets.only(bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.7),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 2,
            offset: Offset(1, 1),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 2,
            offset: Offset(-1, -1),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icon(IconFont.home2), Icon(IconFont.home)),
          _buildNavItem(1, Icon(IconFont.daohangweixuanzhongPaizhao),
              Icon(IconFont.daohangxuanzhongPaizhao)),
          _buildNavItem(2, Icon(IconFont.daohangweixuanzhongshouye),
              Icon(IconFont.daohangxuanzhongshouye)),
          _buildNavItem(3, Icon(IconFont.daohangweixuanzhongTongji),
              Icon(IconFont.daohangxuanzhongTongji)),
          _buildNavItem(4, Icon(IconFont.daohangweixuanzhongWode),
              Icon(IconFont.daohangxuanzhongWode)),
        ],
      ),
    );
  }

  // 单个导航项
  Widget _buildNavItem(int index, Icon icon, Icon selectIcon) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          // 拍照按钮点击处理
          _openCameraPage();
        } else if (index == 2) {
          // 拍照按钮点击处理
          _openAiChartPage();
        } else {
          // 其他导航项点击处理
          setState(() {
            _currentIndex = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isSelected ? selectIcon : icon,
        ],
      ),
    );
  }

  // 打开拍照页面
  void _openCameraPage() {
    setState(() {
      _showBottomNavBar = false; // 隐藏导航栏
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPage(),
      ),
    ).then((_) {
      // 拍照页面关闭后恢复导航栏
      if (mounted) {
        setState(() {
          _showBottomNavBar = true;
        });
      }
    });
  }

  // 打开拍照页面
  void _openAiChartPage() {
    setState(() {
      _showBottomNavBar = false; // 隐藏导航栏
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIChatPage(),
      ),
    ).then((_) {
      // 拍照页面关闭后恢复导航栏
      if (mounted) {
        setState(() {
          _showBottomNavBar = true;
        });
      }
    });
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
