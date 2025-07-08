import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'dart:io' show Platform;

import 'package:zenify/camera_page.dart';
import 'package:zenify/home.dart';

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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainPage(),
      debugShowCheckedModeBanner: false,
    );
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
    PlaceholderWidget(title: "饮食报告", color: Colors.red[100]!),
    CameraPage(),
    HomePage(),
    // PlaceholderWidget(title: "食物仓库", color: Colors.orange[100]!),
    PlaceholderWidget(title: "个人中心", color: Colors.purple[100]!),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  // 自定义底部导航栏
  Widget _buildCustomBottomNavBar() {
    return Container(
      width: 370, // 宽度
      height: 56, // 高度
      margin: EdgeInsets.only(
        bottom: 20, // 距离底部20px
        left: 10, // 左右边距10px
        right: 10,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFdcdcdc), // 背景色#dcdcdc
        borderRadius: BorderRadius.circular(28), // 圆角（直径的一半）
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.assessment, "饮食报告"),
          _buildNavItem(1, Icons.camera_alt, "拍照"),
          _buildNavItem(2, Icons.home, "首页"),
          // _buildNavItem(3, Icons.kitchen, "食物仓库"),
          _buildNavItem(3, Icons.person, "个人中心"),
        ],
      ),
    );
  }

  // 单个导航项
  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.grey[700]),
          Text(label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey[700],
                fontSize: 12,
              )),
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
