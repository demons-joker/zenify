import 'package:flutter/material.dart';
import 'package:zenify/core/app_logger.dart';
import 'package:zenify/presentation/home/index.dart';
// import 'package:zenify/presentation/report/report_detail.dart';
import 'package:zenify/presentation/report/report_code.dart';
import 'package:zenify/presentation/profile/profile_page.dart';
import 'package:zenify/services/user_session.dart';
import 'package:zenify/utils/iconfont.dart';
import 'package:zenify/routes/app_routes.dart';

class _NavItemConfig {
  final int index;
  final Icon icon;
  final Icon selectedIcon;

  const _NavItemConfig({
    required this.index,
    required this.icon,
    required this.selectedIcon,
  });
}

class MainPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  static const int _tabHome = 0;
  static const int _tabReport = 1;
  static const int _tabAi = 2;
  static const int _tabCamera = 3;
  static const int _tabProfile = 4;

  int _currentIndex = _tabHome; // 默认选中首页（index 0）
  bool _showBottomNavBar = true; // 控制导航栏显示状态
  bool _supportsWeightReport = true;
  bool _supportsCameraUpload = true;
  bool _isRefreshingCapability = false;
  bool _isNavigating = false;
  String? _lastCapabilityHint;

  final List<_NavItemConfig> _navItems = [
    _NavItemConfig(
      index: _tabHome,
      icon: Icon(IconFont.home2),
      selectedIcon: Icon(IconFont.home),
    ),
    _NavItemConfig(
      index: _tabReport,
      icon: Icon(IconFont.daohangweixuanzhongTongji),
      selectedIcon: Icon(IconFont.daohangxuanzhongTongji),
    ),
    _NavItemConfig(
      index: _tabAi,
      icon: Icon(IconFont.daohangweixuanzhongshouye),
      selectedIcon: Icon(IconFont.daohangxuanzhongshouye),
    ),
    _NavItemConfig(
      index: _tabCamera,
      icon: Icon(IconFont.daohangweixuanzhongPaizhao),
      selectedIcon: Icon(IconFont.daohangxuanzhongPaizhao),
    ),
    _NavItemConfig(
      index: _tabProfile,
      icon: Icon(IconFont.daohangweixuanzhongWode),
      selectedIcon: Icon(IconFont.daohangxuanzhongWode),
    ),
  ];

  /// 使用 [IndexedStack] 保持 [IndexPage] 始终在子树中，切换报告/我的时不销毁首页状态（MQTT、Tab 等）。
  Widget _buildMainBody(BoxConstraints constraints) {
    final onHome = _currentIndex == _tabHome;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: constraints.maxHeight,
      ),
      child: IndexedStack(
        index: onHome ? 0 : 1,
        sizing: StackFit.expand,
        children: [
          // 非首页时暂停首页侧 ticker/动画，减少后台耗电（子树仍保留状态）。
          TickerMode(
            enabled: onHome,
            child: IndexPage(
              key: IndexPage.globalKey,
              hostTabActive: onHome,
            ),
          ),
          // 勿再包 SingleChildScrollView：对子级给出无限 maxHeight，叠上内层 ScrollView/Scaffold
          // 易导致 0 尺寸 RenderBox，在 macOS 上触发 mouse_tracker 与 hit test 断言。
          Padding(
            padding: const EdgeInsets.only(
              bottom: kBottomNavigationBarHeight,
            ),
            child: _buildSecondaryBody(),
          ),
        ],
      ),
    );
  }

  /// 非首页 Tab 的主体：仅报告、个人中心会切换 `_currentIndex`；AI/相机为 overlay，不经过此处。
  /// [IndexedStack] 保留两页状态，避免报告 ↔ 我的 来回时重复构建与滚动丢失。
  Widget _buildSecondaryBody() {
    switch (_currentIndex) {
      case _tabReport:
      case _tabProfile:
        return IndexedStack(
          index: _currentIndex == _tabReport ? 0 : 1,
          sizing: StackFit.expand,
          children: const [
            ReportCodePage(key: PageStorageKey('main_nav_report')),
            ProfilePage(key: PageStorageKey('main_nav_profile')),
          ],
        );
      default:
        // 在首页时本层仍被 IndexedStack 保留在树中，需占满区域，避免 0 尺寸参与命中/鼠标跟踪。
        return SizedBox.expand();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshDeviceCapability();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDeviceCapability();
    }
  }

  Future<void> _refreshDeviceCapability() async {
    if (_isRefreshingCapability) return;
    _isRefreshingCapability = true;
    try {
      final supportsWeight = await UserSession.activeDeviceSupportsWeight;
      final supportsCamera = await UserSession.activeDeviceSupportsImageUpload;
      if (!mounted) return;
      final changed = _supportsWeightReport != supportsWeight ||
          _supportsCameraUpload != supportsCamera;
      if (changed) {
        setState(() {
          _supportsWeightReport = supportsWeight;
          _supportsCameraUpload = supportsCamera;
        });
      }
    } finally {
      _isRefreshingCapability = false;
    }
  }

  void _showCapabilityHint(String message) {
    if (!mounted) return;
    // Avoid showing same hint repeatedly on rapid taps.
    if (_lastCapabilityHint == message) return;
    _lastCapabilityHint = message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_lastCapabilityHint == message) {
        _lastCapabilityHint = null;
      }
    });
  }

  Widget _buildCapabilityDot() {
    return Container(
      margin: const EdgeInsets.only(top: 2),
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  bool _isCapabilityBlocked(int index) {
    return (index == _tabReport && !_supportsWeightReport) ||
        (index == _tabCamera && !_supportsCameraUpload);
  }

  bool _shouldShowCapabilityDot(int index) => _isCapabilityBlocked(index);

  String? _capabilityBlockedMessage(int index) {
    if (index == _tabReport && !_supportsWeightReport) {
      return '当前设备不支持报告页，请切换到餐盘设备';
    }
    if (index == _tabCamera && !_supportsCameraUpload) {
      return '当前设备不支持拍照上传，请切换到支持该能力的设备';
    }
    return null;
  }

  String _navSemanticLabel(int index) {
    switch (index) {
      case _tabHome:
        return '首页';
      case _tabReport:
        return _supportsWeightReport ? '报告' : '报告，当前设备不可用';
      case _tabAi:
        return 'AI 助手';
      case _tabCamera:
        return _supportsCameraUpload ? '拍照' : '拍照，当前设备不可用';
      case _tabProfile:
        return '我的';
      default:
        return '导航';
    }
  }

  Future<void> _handleNavTap(int index) async {
    if (_isNavigating) return;
    final needsCapabilityCheck = index == _tabReport || index == _tabCamera;
    if (needsCapabilityCheck) {
      await _refreshDeviceCapability();
      final blockedMessage = _capabilityBlockedMessage(index);
      if (blockedMessage != null) {
        _showCapabilityHint(blockedMessage);
        return;
      }
    } else {
      // Keep capability state warm, but don't block normal tab switches.
      _refreshDeviceCapability();
    }
    if (index == _tabCamera) {
      _openCameraPage();
      return;
    }
    if (index == _tabAi) {
      _openAiChatPage();
      return;
    }
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
                  builder: (context, constraints) => _buildMainBody(constraints),
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
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 2,
            offset: Offset(1, 1),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: Offset(-1, -1),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _navItems
            .map((item) => _buildNavItem(
                  item.index,
                  item.icon,
                  item.selectedIcon,
                ))
            .toList(),
      ),
    );
  }

  // 单个导航项
  Widget _buildNavItem(int index, Icon icon, Icon selectIcon) {
    bool isSelected = _currentIndex == index;
    final capabilityBlocked = _isCapabilityBlocked(index);
    return Semantics(
      button: true,
      selected: isSelected,
      label: _navSemanticLabel(index),
      child: GestureDetector(
        onTap: () => _handleNavTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: capabilityBlocked ? 0.45 : 1,
              child: isSelected ? selectIcon : icon,
            ),
            if (_shouldShowCapabilityDot(index)) _buildCapabilityDot(),
          ],
        ),
      ),
    );
  }

  Future<void> _runOverlayRoute(Future<dynamic> Function() pushRoute) async {
    _isNavigating = true;
    try {
      if (!mounted) return;
      setState(() {
        _showBottomNavBar = false;
      });
      await pushRoute();
    } catch (e, st) {
      AppLogger.error('Overlay route failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('页面打开失败，请重试')),
        );
      }
    } finally {
      _isNavigating = false;
      if (mounted) {
        setState(() {
          _showBottomNavBar = true;
        });
        _refreshDeviceCapability();
      }
    }
  }

  // 打开拍照页面
  void _openCameraPage() {
    _runOverlayRoute(() async {
      final result = await AppRoutes.navigateToCameraPage(context);
      if (!mounted) return;
      if (result is Map && result['switchToATE'] == true) {
        IndexPage.globalKey.currentState
            ?.handleCameraUploadResult(Map<String, dynamic>.from(result));
      }
    });
  }

  // 打开 AI 对话页
  void _openAiChatPage() {
    _runOverlayRoute(() => AppRoutes.navigateToAiChat(context));
  }
}
