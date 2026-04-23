import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/app_logger.dart';
import '../../core/app_export.dart';
import '../../services/mqtt_service.dart';
import '../../services/user_session.dart';
import '../../services/api.dart';
import '../../services/user_data_cache.dart';
import '../menu/menu_page.dart';
import 'home_history_coordinator.dart';
import '../../utils/toast_helper.dart';
import '../../utils/error_message_helper.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key, this.initialTab});

  final String? initialTab;

  // ignore: library_private_types_in_public_api
  static final GlobalKey<_IndexPageState> globalKey =
      GlobalKey<_IndexPageState>();

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['EAT', 'ATE'];
  int _selectedDay = DateTime.now().weekday; // 0-6 for Monday-Sunday

  // MY PLAN 数据
  final List<Map<String, dynamic>> _dietPlans = [
    // {
    //   'name': 'Paleo diet',
    //   'user': 'Alice',
    //   'score': 'B+',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
    // {
    //   'name': 'Keto diet',
    //   'user': 'Bob',
    //   'score': 'A-',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
    // {
    //   'name': 'Vegan diet',
    //   'user': 'Carol',
    //   'score': 'C+',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
    // {
    //   'name': 'Mediterranean',
    //   'user': 'David',
    //   'score': 'A',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
    // {
    //   'name': 'Low carb',
    //   'user': 'Eve',
    //   'score': 'B',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
    // {
    //   'name': 'High protein',
    //   'user': 'Frank',
    //   'score': 'A+',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
  ];

  String _selectedMealType = 'BREAKFAST';
  final List<String> _mealTypes = ['BREAKFAST', 'LUNCH', 'DINNER'];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  // 当前用户食物数据
  List<dynamic> _currentUserFoods = [];
  bool _isLoadingFoods = false;

  // 收藏状态 - 按日期和餐食类型存储
  Map<String, bool> _collectedStatus = {};

  // 收藏的餐食列表
  List<Map<String, dynamic>> _collectedMeals = [];

  // 食物识别记录 - 按餐食类型分组
  Map<String, List<Map<String, dynamic>>> _ateFoods = {
    'BREAKFAST': [],
    'LUNCH': [],
    'DINNER': [],
    'OTHER': [],
  };

  // 是否正在加载数据
  bool _isLoadingHistory = false;

  // StreamSubscription for MQTT
  StreamSubscription<RecognitionStatus>? _mqttSubscription;
  StreamSubscription<MQTTConnectionStatus>? _mqttConnectionSubscription;
  MQTTConnectionStatus? _mqttConnectionStatus;
  final HomeHistoryCoordinator _historyCoordinator = HomeHistoryCoordinator();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // 根据初始参数设置 tab
    if (widget.initialTab != null) {
      final initialIndex = _tabs.indexOf(widget.initialTab!);
      if (initialIndex != -1) {
        _currentTabIndex = initialIndex;
      }
    }

    // 初始化MQTT连接
    _initMQTT();

    // 加载历史数据
    _loadHistoryData();

    // 加载当前用户食物数据
    _loadCurrentUserFoods();

    // 加载收藏餐食数据
    _loadCollectedMeals();

    // 加载收藏状态
    _loadCollectedStatus();
  }

  /// 加载历史识别数据
  Future<void> _loadHistoryData() async {
    if (_isLoadingHistory) return;

    if (!mounted) return;

    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final userId = await UserSession.userId;
      if (userId == null || !mounted) return;
      final ateFoods = await _historyCoordinator.loadAteFoods(
        userId: userId.toString(),
        selectedDay: _selectedDay,
      );
      _ateFoods = ateFoods;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      AppLogger.error('加载历史数据失败: $e');
      AppLogger.warning('堆栈跟踪: ${StackTrace.current}');
      if (mounted) {
        ToastHelper.error(context, ErrorMessageHelper.format(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  /// 加载当前用户食物数据
  Future<void> _loadCurrentUserFoods() async {
    if (_isLoadingFoods) return;
    if (!mounted) return;

    setState(() {
      _isLoadingFoods = true;
    });

    try {
      final userId = await UserSession.userId;
      if (userId == null || !mounted) return;

      AppLogger.info('加载当前用户食物数据: userId=$userId');

      // 调用API获取当前用户食物数据
      final result = await Api.getCurrentUserFoods({'user_id': userId});

      AppLogger.info('API响应食物数据条目: ${result is List ? result.length : 0}');

      if (mounted) {
        setState(() {
          _currentUserFoods = result is List ? result : [];
          _isLoadingFoods = false;
        });
        // 加载收藏状态
        _loadCollectedStatus();
      }
    } catch (e) {
      AppLogger.error('加载当前用户食物数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingFoods = false;
        });
      }
    }
  }

  /// 加载收藏的餐食数据
  Future<void> _loadCollectedMeals() async {
    try {
      final meals = await UserDataCache.getCollectedMeals();
      if (mounted) {
        setState(() {
          _collectedMeals = meals;
        });
      }
    } catch (e) {
      AppLogger.error('加载收藏餐食失败: $e');
    }
  }

  /// 切换收藏状态
  Future<void> _toggleCollect() async {
    final selectedDate = _getSelectedDate();
    final dateStr = selectedDate.toIso8601String().split('T')[0];
    final mealType = _selectedMealType;

    try {
      if (_collectedStatus[dateStr] ?? false) {
        // 取消收藏
        await UserDataCache.removeCollectedMeal(dateStr, mealType);
        if (mounted) {
          setState(() {
            _collectedStatus[dateStr] = false;
          });
        }
      } else {
        // 添加收藏 - 收藏当前餐食类型的所有食物
        final selectedMealData = _currentUserFoods.firstWhere(
          (item) =>
              item['meal_type']?.toString().toLowerCase() ==
              _selectedMealType.toLowerCase(),
          orElse: () => null,
        );

        if (selectedMealData != null) {
          final foods = selectedMealData['foods'] as List?;
          if (foods != null && foods.isNotEmpty) {
            // 为每个食物创建收藏
            for (var foodItem in foods) {
              final food = foodItem['food'] as Map?;
              if (food != null) {
                await UserDataCache.saveCollectedMeal({
                  'date': dateStr,
                  'meal_type': mealType,
                  'food_id': food['id'],
                  'name_en': food['name_en'],
                  'name': food['name'],
                  'image_url': food['image_url'],
                  'category': food['category'],
                  'quantity': foodItem['quantity'],
                  'unit': foodItem['unit'],
                });
              }
            }
          }
          if (mounted) {
            setState(() {
              _collectedStatus[dateStr] = true;
            });
          }
        }
      }

      // 刷新My Plan模块数据
      await _loadCollectedMeals();
    } catch (e) {
      AppLogger.error('切换收藏状态失败: $e');
    }
  }

  /// 获取选中日期
  DateTime _getSelectedDate() {
    final now = DateTime.now();
    final daysUntilSelectedDay = _selectedDay - now.weekday;
    return now.add(Duration(days: daysUntilSelectedDay));
  }

  /// 加载收藏状态
  Future<void> _loadCollectedStatus() async {
    final selectedDate = _getSelectedDate();
    final dateStr = selectedDate.toIso8601String().split('T')[0];
    final mealType = _selectedMealType;

    final isCollected = await UserDataCache.isMealCollected(dateStr, mealType);
    if (mounted) {
      setState(() {
        _collectedStatus[dateStr] = isCollected;
      });
    }
  }

  /// 初始化MQTT
  Future<void> _initMQTT() async {
    try {
      await MQTTService().connect();
      _mqttSubscription = MQTTService().statusStream.listen((status) {
        _handleRecognitionStatus(status);
      });
      _mqttConnectionSubscription =
          MQTTService().connectionStatusStream.listen((connectionStatus) {
        if (!mounted) return;
        setState(() {
          _mqttConnectionStatus = connectionStatus;
        });
      });
    } catch (e) {
      AppLogger.error('MQTT init error: $e');
      if (mounted) {
        ToastHelper.error(context, ErrorMessageHelper.format(e));
      }
    }
  }

  /// 处理识别状态变化
  void _handleRecognitionStatus(RecognitionStatus status) async {
    if (!mounted) return;

    if (status.status == RecognitionStatusType.analyzing) {
      // 识别开始 - 切换到 ATE tab 并重新加载历史数据
      switchToATETab();
      await _loadHistoryData();
    } else if (status.status == RecognitionStatusType.completed) {
      // 识别完成 - 重新加载历史数据
      await _loadHistoryData();
    }
  }

  /// 切换到 ATE tab
  void switchToATETab() {
    if (!mounted) return;
    setState(() {
      _currentTabIndex = 1; // ATE tab 的索引是 1
    });
    // 切换后重新加载数据，确保显示最新的识别记录
    _loadHistoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _mqttSubscription?.cancel();
    _mqttConnectionSubscription?.cancel();
    super.dispose();
  }

  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFC),
      body: Column(
        children: [
          // 顶部区域：左边tab切换、中间logo、右边菜单
          _buildTopHeader(),
          _buildMqttConnectionBanner(),

          // 周日期选择器 - 只在 ATE tab 显示
          if (_currentTabIndex == 1) _buildWeekSelector(),

          // 内容区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: IndexedStack(
                index: _currentTabIndex,
                children: _tabs.map((tab) {
                  if (tab == 'EAT') {
                    return SingleChildScrollView(
                      child: _buildDietTab(),
                    );
                  } else {
                    return SingleChildScrollView(
                      child: _buildAteTab(),
                    );
                  }
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMqttConnectionBanner() {
    final status = _mqttConnectionStatus;
    if (status == null || status.state == MQTTConnectionStateView.connected) {
      return const SizedBox.shrink();
    }

    Color bgColor;
    if (status.state == MQTTConnectionStateView.failed) {
      bgColor = const Color(0xFFFFE5E5);
    } else {
      bgColor = const Color(0xFFFFF6E5);
    }

    final textColor = status.state == MQTTConnectionStateView.failed
        ? const Color(0xFF8B0000)
        : const Color(0xFF8A5A00);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              status.message,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (status.state == MQTTConnectionStateView.failed ||
              status.state == MQTTConnectionStateView.disconnected)
            TextButton(
              onPressed: () => MQTTService().connect(isReconnect: true),
              child: Text(
                '立即重试',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 顶部区域
  Widget _buildTopHeader() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFCFCFC),
            Color(0x9EFFFFFF),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 左边：EAT/ATE tab 切换
          Positioned(
            left: 20.h,
            top: 0,
            bottom: 0,
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                return GestureDetector(
                  onTap: () => setState(() => _currentTabIndex = index),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
                    margin: EdgeInsets.symmetric(horizontal: 4.h),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _currentTabIndex == index
                              ? Colors.black
                              : Colors.transparent,
                          width: 2.h,
                        ),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                          color: _currentTabIndex == index
                              ? Colors.black
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.fSize),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 中间：头像 - 绝对居中
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // 头像功能
                },
                child: Container(
                  width: 40.h,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.h),
                    border: Border.all(color: Colors.white, width: 2.h),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: Offset(0, 2.h),
                        blurRadius: 4.h,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.h),
                    child: Image.asset(
                      'assets/images/figma/avatar_center.png',
                      width: 36.h,
                      height: 36.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        width: 36.h,
                        height: 36.h,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 18.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 右边：菜单按钮
          Positioned(
            right: 20.h,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                // 菜单功能
              },
              child: SizedBox(
                width: 32.h,
                height: 32.h,
                child: Icon(
                  Icons.menu,
                  color: Colors.black,
                  size: 20.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 周日期选择器
  Widget _buildWeekSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = index == _selectedDay;
          final isFuture = index > DateTime.now().weekday % 7;
          return GestureDetector(
            onTap: isFuture
                ? null
                : () async {
                    setState(() => _selectedDay = index);
                    await _loadHistoryData();
                  },
            child: Opacity(
              opacity: isFuture ? 0.3 : 1.0,
              child: Container(
                width: 30.h,
                height: 30.h,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12.fSize,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDietTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // COLLECT 收集统计区域
          _buildCollectSection(),

          SizedBox(height: 24.h),

          // RECOMMEND 推荐区域
          _buildRecommendSection(),

          SizedBox(height: 24.h),

          // MY PLAN 我的计划区域
          _buildMyPlanSection(),

          SizedBox(height: 80.h), // 底部导航栏空间
        ],
      ),
    );
  }

  // ATE tab内容
  Widget _buildAteTab() {
    if (_isLoadingHistory) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistoryData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 早餐组 - 使用动态数据
            _buildMealSection('BREAKFAST', _ateFoods['BREAKFAST'] ?? []),

            // SizedBox(height: 24.h),

            // 中餐组 - 使用动态数据
            _buildMealSection('LUNCH', _ateFoods['LUNCH'] ?? []),

            // SizedBox(height: 24.h),

            // 晚餐组 - 使用动态数据
            _buildMealSection('DINNER', _ateFoods['DINNER'] ?? []),

            // SizedBox(height: 24.h),

            // 加餐组 - 使用动态数据
            _buildMealSection('OTHER', _ateFoods['OTHER'] ?? []),

            SizedBox(height: 80.h), // 底部导航栏空间
          ],
        ),
      ),
    );
  }

  // 餐食分组组件
  Widget _buildMealSection(String title, List<Map<String, dynamic>> foods) {
    if (foods.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF0B0B0B),
            fontSize: 24.fSize,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 10.h),

        // 食物卡片列表
        Column(
          children: foods.asMap().entries.map((entry) {
            final index = entry.key;
            final food = entry.value;
            return Padding(
              padding:
                  EdgeInsets.only(bottom: index < foods.length - 1 ? 16.h : 0),
              child: _buildFoodCard(
                imageUrl: food['imageUrl'],
                title: food['title'],
                isLiked: food['isLiked'] ?? false,
                isAnalyzing: food['isAnalyzing'] ?? false,
                data: food['data'],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 食物卡片组件
  Widget _buildFoodCard({
    String? imageUrl,
    required String title,
    required bool isLiked,
    bool isAnalyzing = false,
    Map<String, dynamic>? data,
  }) {
    // 计算卡路里
    String caloriesText = '';
    if (data != null && !isAnalyzing) {
      final foods = data['foods'] as List? ?? [];
      double totalCalories = 0;
      for (var food in foods) {
        final quantity = (food['quantity'] ?? 300) as double;
        final foodInfo = food['food'] as Map? ?? {};
        final caloriesPer100g = (foodInfo['calories_per_100g'] ?? 0) as double;
        totalCalories += (quantity / 100) * caloriesPer100g;
      }
      caloriesText = '${totalCalories.toStringAsFixed(0)} kcal';
    }

    return GestureDetector(
      onTap: () {
        if (!isAnalyzing) {
          AppRoutes.navigateToMealAnalysisReport(
            context,
            image: imageUrl ?? '',
            title: title,
            tag: 'Balanced',
            foods: data?['foods'] ?? [],
            recordData: data,
          );
        }
      },
      child: Container(
        height: 114.h, // 114px高度
        decoration: BoxDecoration(
          color: Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(12.h),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: Offset(0, 2.h),
              blurRadius: 8.h,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.h),
          child: Row(
            children: [
              // 左边正方形图片或加载动画
              Container(
                width: 90.h,
                height: 90.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.h),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.h),
                  child: isAnalyzing
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 30.h,
                                height: 30.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF747474),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Analyzing',
                                style: TextStyle(
                                  color: Color(0xFF747474),
                                  fontSize: 12.fSize,
                                ),
                              ),
                            ],
                          ),
                        )
                      : imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.restaurant,
                                  color: Colors.grey[600],
                                  size: 32.h,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.restaurant,
                              color: Colors.grey[600],
                              size: 32.h,
                            ),
                ),
              ),

              SizedBox(width: 10.h), // 距离右边10px

              // 右边剩余区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 第一行：收藏按钮、标签、卡路里、编辑按钮
                    Row(
                      children: [
                        // 收藏爱心按钮
                        SizedBox(
                          width: 32.h,
                          height: 32.h,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                // 这里可以切换收藏状态
                              });
                            },
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked
                                  ? Color.fromARGB(255, 214, 37, 37)
                                  : Color(0xFF747474),
                              size: 20.h,
                            ),
                          ),
                        ),

                        SizedBox(width: 6.h),

                        // Balanced diet 标签 - 使用 Flexible 避免溢出
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.h, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Color(0xFFE1EC7C),
                              borderRadius: BorderRadius.circular(90),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'Balanced',
                                style: TextStyle(
                                  color: Color(0xFF747474),
                                  fontSize: 16.fSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Spacer(),

                        // 卡路里显示
                        if (caloriesText.isNotEmpty) ...[
                          SizedBox(width: 6.h),
                          Flexible(
                            child: Text(
                              caloriesText,
                              style: TextStyle(
                                color: Color(0xFF747474),
                                fontSize: 11.fSize,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // 第二行：文案内容
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Color(0xFF646464),
                          fontSize: 16.fSize,
                          fontWeight: FontWeight.w500,
                          height: 22.0 / 16.0,
                          letterSpacing: 0.121,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // COLLECT 收集统计区域
  Widget _buildCollectSection() {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 20.h),
      padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部行：COLLECT标题和Weekly update提示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COLLECT',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.fSize,
                  fontFamily: 'PressStart2P',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45.h),
                  border: Border.all(
                    color: Color(0xFF4C4C4C),
                    width: 1.h,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Weekly Update',
                    style: TextStyle(
                      color: Color(0xFF4C4C4C),
                      fontSize: 14.fSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // 食物收集统计卡片
          SizedBox(
            child: Column(
              children: [
                // 三种食物统计
                Row(
                  children: [
                    // 蔬菜
                    Expanded(
                      child: _buildFoodCollectCard(
                        icon: '🥬',
                        name: '蔬菜',
                        current: 6,
                        target: 9,
                        color: Color(0xFF52D1C6),
                        bgColor: Color(0xFFE8F8F7),
                      ),
                    ),
                    SizedBox(width: 12.h),
                    // 主食
                    Expanded(
                      child: _buildFoodCollectCard(
                        icon: '🌾',
                        name: '主食',
                        current: 5,
                        target: 8,
                        color: Color(0xFF779600),
                        bgColor: Color(0xFFF0F7E8),
                      ),
                    ),
                    SizedBox(width: 12.h),
                    // 肉食
                    Expanded(
                      child: _buildFoodCollectCard(
                        icon: '🥩',
                        name: '肉食',
                        current: 4,
                        target: 8,
                        color: Color(0xFFFF6B6B),
                        bgColor: Color(0xFFFFF0F0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Tips 文字
          Container(
            padding: EdgeInsets.all(10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45.h), // 90px的一半
              color: Color(0x33000000), // rgba(0, 0, 0, 0.20)
            ),
            child: Center(
              child: Text(
                'Tips: The more diverse types of food, more comprehensive nutrition.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF707070),
                  fontSize: 17.fSize,
                  fontWeight: FontWeight.w400,
                  height: 22.0 / 17.0, // line-height 22px / font-size 17px
                  letterSpacing: -0.08,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 食物收集卡片 - 黑色像素风格
  Widget _buildFoodCollectCard({
    required String icon,
    required String name,
    required int current,
    required int target,
    required Color color,
    required Color bgColor,
  }) {
    String imagePath;

    // 根据名称设置显示名称和图片路径
    switch (name) {
      case '蔬菜':
        imagePath = 'assets/images/211cai.png';
        break;
      case '主食':
        imagePath = 'assets/images/211mianbao.png';
        break;
      case '肉食':
        imagePath = 'assets/images/211rou.png';
        break;
      default:
        imagePath = 'assets/images/211cai.png';
    }

    return Container(
      width: 113,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A8C8C8C), // rgba(140, 140, 140, 0.10)
            offset: Offset(6, 6),
            blurRadius: 15,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 整个卡片的背景图片
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade600,
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          // 底部半透明背景，用于显示分数
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 35, // 底部分数区域高度
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
                color: Colors.black.withValues(alpha: 0.7), // 半透明黑色背景
              ),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '$current ',
                        style: TextStyle(color: Color(0xFFC8FD00)),
                      ),
                      TextSpan(text: '/ $target'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // RECOMMEND 推荐区域
  Widget _buildRecommendSection() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECOMMEND',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.fSize,
              fontFamily: 'PressStart2P',
              fontWeight: FontWeight.normal,
            ),
          ),
          SizedBox(height: 16.h),

          // 餐食类型切换
          _buildMealTypeSelector(),
          SizedBox(height: 16.h),

          // 黑色大卡片
          _buildRecommendCard(),
        ],
      ),
    );
  }

  // 餐食类型选择器
  Widget _buildMealTypeSelector() {
    return SizedBox(
      height: 45.h,
      child: Row(
        children: _mealTypes.map((mealType) {
          final isSelected = mealType == _selectedMealType;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMealType = mealType;
              });
              _loadCollectedStatus(); // 切换餐食类型时刷新收藏状态
            },
            child: Container(
              margin: EdgeInsets.all(4.h),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(90),
                border: isSelected
                    ? Border.all(color: Color(0xFF000000), width: 1)
                    : Border.all(color: Colors.transparent, width: 1),
              ),
              child: Center(
                child: Text(
                  mealType,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Color(0xFFA9A9A9),
                    fontSize: 14.fSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 推荐卡片
  Widget _buildRecommendCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 获取可用宽度，确保是正方形
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width - 40; // 减去左右padding

        final cardSize = maxWidth;

        return Container(
          width: cardSize,
          height: cardSize,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20.h),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 4.h),
                blurRadius: 12.h,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 上部分内容（占 cardSize - 90.h 高度）- 新布局：三行列表
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 90.h,
                child: _buildFoodList(),
              ),

              // 下部分内容（90.h高度）
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 90.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左侧 Collect 按钮
                      GestureDetector(
                        onTap: _toggleCollect,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 40.h,
                              height: 40.h,
                              child: Icon(
                                (_collectedStatus[_getSelectedDate()
                                            .toIso8601String()
                                            .split('T')[0]] ??
                                        false)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: (_collectedStatus[_getSelectedDate()
                                            .toIso8601String()
                                            .split('T')[0]] ??
                                        false)
                                    ? Color(0xFFFF0000)
                                    : Color(0xFF908070),
                                size: 28.h,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Collect',
                              style: TextStyle(
                                color: (_collectedStatus[_getSelectedDate()
                                            .toIso8601String()
                                            .split('T')[0]] ??
                                        false)
                                    ? Color(0xFFFF0000)
                                    : Color(0xFF908070),
                                fontSize: 14.fSize,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // 中间显示餐食热量和食材英文名
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.h),
                          child: _buildMealInfo(),
                        ),
                      ),
                      // 右侧 Change 按钮
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     SizedBox(
                      //       width: 40.h,
                      //       height: 40.h,
                      //       child: Image.asset(
                      //         'assets/images/change.png',
                      //         width: 40.h,
                      //         height: 40.h,
                      //         fit: BoxFit.contain,
                      //         errorBuilder: (context, error, stackTrace) =>
                      //             Container(
                      //           width: 40.h,
                      //           height: 40.h,
                      //           color: Colors.grey.shade600,
                      //           child: Icon(
                      //             Icons.refresh,
                      //             color: Colors.white,
                      //             size: 20.h,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(height: 4.h),
                      //     Text(
                      //       'Change',
                      //       style: TextStyle(
                      //         color: Color(0xFF908070),
                      //         fontSize: 14.fSize,
                      //         fontWeight: FontWeight.w400,
                      //       ),
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),

              // 分数【85】显示在左上角14:14位置
              // Positioned(
              //   right: 14.h,
              //   top: 14.h,
              //   child: Container(
              //     width: 48.h,
              //     height: 48.h,
              //     decoration: BoxDecoration(
              //       color: Color(0xFFC8FD00),
              //       shape: BoxShape.circle,
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withValues(alpha: 0.12),
              //           blurRadius: 6.h,
              //           offset: Offset(0, 2.h),
              //         ),
              //       ],
              //     ),
              //     child: Center(
              //       child: Text(
              //         'A',
              //         style: TextStyle(
              //           color: Colors.black,
              //           fontSize: 20.fSize,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              // 虚线分割线
              Positioned(
                left: 20.h,
                right: 20.h,
                top: cardSize - 90.h,
                child: CustomPaint(
                  size: Size(cardSize - 40.h, 1),
                  painter: DashedLinePainter(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建餐食信息（热量和食材英文名）
  Widget _buildMealInfo() {
    if (_isLoadingFoods) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFFC8FD00)),
      );
    }

    // 获取当前选择的餐食类型对应的食物数据
    final selectedMealData = _currentUserFoods.firstWhere(
      (item) =>
          item['meal_type']?.toString().toLowerCase() ==
          _selectedMealType.toLowerCase(),
      orElse: () => null,
    );

    if (selectedMealData == null) {
      return Text(
        'No data',
        style: TextStyle(
          color: Color(0xFF908070),
          fontSize: 14.fSize,
        ),
        textAlign: TextAlign.center,
      );
    }

    final calories = selectedMealData['calories'] ?? 0;
    final foods = selectedMealData['foods'] as List? ?? [];
    final foodNames = foods.map((f) {
      final foodInfo = f['food'] as Map?;
      return foodInfo?['name_en'] as String? ?? 'Unknown';
    }).join(', ');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$calories kcal',
          style: TextStyle(
            color: Color(0xFF908070),
            fontSize: 16.fSize,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          foodNames,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.fSize,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 构建食材列表 - 三行布局
  Widget _buildFoodList() {
    // 获取当前选择的餐食类型对应的食物数据
    final selectedMealData = _currentUserFoods.isNotEmpty
        ? _currentUserFoods.firstWhere(
            (item) =>
                item['meal_type']?.toString().toLowerCase() ==
                _selectedMealType.toLowerCase(),
            orElse: () => null,
          )
        : null;

    // 收集所有食物信息，按类别分组
    Map<String, Map<String, dynamic>> categorizedFoods = {
      'vegetable': {'names': <String>[], 'id': null},
      'carbohydrate': {'names': <String>[], 'id': null},
      'protein': {'names': <String>[], 'id': null},
    };

    if (selectedMealData != null) {
      final foods = selectedMealData['foods'] as List? ?? [];
      for (var foodItem in foods) {
        final foodInfo = foodItem['food'] as Map?;
        if (foodInfo != null) {
          final category = foodInfo['category'] as String?;
          final nameEn = foodInfo['name_en'] as String?;
          if (category != null && nameEn != null) {
            final categoryLower = category.toLowerCase();
            if (categorizedFoods.containsKey(categoryLower)) {
              // 如果还没有设置 id，设置第一个食物的 id
              if (categorizedFoods[categoryLower]!['id'] == null) {
                categorizedFoods[categoryLower]!['id'] = foodItem['id'];
              }
              categorizedFoods[categoryLower]!['names'].add(nameEn);
            }
          }
        }
      }
    }

    // 定义三行的固定配置
    final foodRows = [
      {
        'category': 'vegetable',
        'image': 'assets/images/211cai.png',
        'name': categorizedFoods['vegetable']!['names'].isNotEmpty
            ? categorizedFoods['vegetable']!['names'].join(', ')
            : 'No vegetable',
        'id': categorizedFoods['vegetable']!['id'],
      },
      {
        'category': 'carbohydrate',
        'image': 'assets/images/211mianbao.png',
        'name': categorizedFoods['carbohydrate']!['names'].isNotEmpty
            ? categorizedFoods['carbohydrate']!['names'].join(', ')
            : 'No carbohydrate',
        'id': categorizedFoods['carbohydrate']!['id'],
      },
      {
        'category': 'protein',
        'image': 'assets/images/211rou.png',
        'name': categorizedFoods['protein']!['names'].isNotEmpty
            ? categorizedFoods['protein']!['names'].join(', ')
            : 'No protein',
        'id': categorizedFoods['protein']!['id'],
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 30.h),
      child: Column(
        children: foodRows.asMap().entries.map((entry) {
          final index = entry.key;
          final rowData = entry.value;
          final category = rowData['category'] as String;
          final imagePath = rowData['image'] as String;
          final foodName = rowData['name'] as String;
          final foodId = rowData['id'] as int?;

          return Expanded(
            child: index < foodRows.length - 1
                ? Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildFoodRow(
                      imagePath: imagePath,
                      foodName: foodName,
                      category: category,
                      foodId: foodId,
                    ),
                  )
                : _buildFoodRow(
                    imagePath: imagePath,
                    foodName: foodName,
                    category: category,
                    foodId: foodId,
                  ),
          );
        }).toList(),
      ),
    );
  }

  // 构建单行食材
  Widget _buildFoodRow({
    required String imagePath,
    required String foodName,
    required String category,
    int? foodId,
  }) {
    return GestureDetector(
      onTap: () async {
        // 点击整行跳转到 MenuPage
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuPage(
              category: category,
              recipeFoodId: foodId ?? 0,
            ),
          ),
        );
        if (result == true) {
          _loadCurrentUserFoods();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Row(
          children: [
            // 左侧图片
            Container(
              width: 60.h,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.h),
                  bottomLeft: Radius.circular(12.h),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.h),
                  bottomLeft: Radius.circular(12.h),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Color(0xFF454A30),
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 24.h,
                    ),
                  ),
                ),
              ),
            ),
            // 中间食材名称
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.h),
                child: Text(
                  foodName,
                  style: TextStyle(
                    color: Color(0xFFDEC1A4),
                    fontSize: 16.fSize,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // 右侧切换按钮
            Padding(
              padding: EdgeInsets.only(right: 12.h),
              child: Icon(
                Icons.refresh_rounded,
                color: Color(0xFF908070),
                size: 20.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 保留原有的 _buildFoodTypeLabels 方法（如果其他地方调用）
  // 构建食材类型标签和引导线（兼容旧代码）
  Widget _buildFoodTypeLabels(double cardSize) {
    // 获取当前选择的餐食类型对应的食物数据
    final selectedMealData = _currentUserFoods.firstWhere(
      (item) =>
          item['meal_type']?.toString().toLowerCase() ==
          _selectedMealType.toLowerCase(),
      orElse: () => null,
    );

    // 收集所有食物信息（最多4个），按类别分组
    Map<String, List<String>> categorizedFoods = {
      'vegetable': [],
      'carbohydrate': [],
      'protein': [],
      'fruit': [],
      'fat': [],
    };

    if (selectedMealData != null) {
      final foods = selectedMealData['foods'] as List? ?? [];
      for (var foodItem in foods) {
        final foodInfo = foodItem['food'] as Map?;
        if (foodInfo != null) {
          final category = foodInfo['category'] as String?;
          final nameEn = foodInfo['name_en'] as String?;
          if (category != null && nameEn != null) {
            final categoryLower = category.toLowerCase();
            if (categorizedFoods.containsKey(categoryLower)) {
              categorizedFoods[categoryLower]!.add(nameEn);
            }
          }
        }
      }
    }

    final containerWidth = cardSize; // 使用卡片总宽度
    final containerHeight = cardSize - 90.h; // 上半部分高度
    final iconSize = 24.h; // 图标大小

    // 构建要显示的食材类型标签列表 - 使用实际的菜品数据
    final foodTypes = <Map<String, dynamic>>[];

    // 位置1: 左上角 - vegetable
    int? vegetableId;
    if (categorizedFoods['vegetable']!.isNotEmpty) {
      // 找到第一个 vegetable 食物的 plan_id
      if (selectedMealData != null) {
        final foods = selectedMealData['foods'] as List? ?? [];
        for (var foodItem in foods) {
          final foodInfo = foodItem['food'] as Map?;
          if (foodInfo != null &&
              (foodInfo['category'] as String?) == 'vegetable') {
            vegetableId = foodItem['id'] as int?;
            break;
          }
        }
      }
      foodTypes.add({
        'name': categorizedFoods['vegetable']!.join(', '),
        'textPosition': Offset(18.h, containerHeight * 0.3 - 40),
        'isVegetables': true, // 标记这是左上角位置
        'id': vegetableId,
        'category': 'vegetable', // 添加食物的category属性
      });
    }

    // 位置2: 左下角 - carbohydrate
    int? carbohydrateId;
    if (categorizedFoods['carbohydrate']!.isNotEmpty) {
      // 找到第一个 carbohydrate 食物的 plan_id
      if (selectedMealData != null) {
        final foods = selectedMealData['foods'] as List? ?? [];
        for (var foodItem in foods) {
          final foodInfo = foodItem['food'] as Map?;
          if (foodInfo != null &&
              (foodInfo['category'] as String?) == 'carbohydrate') {
            carbohydrateId = foodItem['id'] as int?;
            break;
          }
        }
      }
      foodTypes.add({
        'name': categorizedFoods['carbohydrate']!.join(', '),
        'textPosition': Offset(18.h, containerHeight * 0.7 + 50),
        'isVegetables': false,
        'isHighProtein': false,
        'id': carbohydrateId,
        'category': 'carbohydrate', // 添加食物的category属性
      });
    }

    // 位置3: 右下角 - protein
    int? proteinId;
    if (categorizedFoods['protein']!.isNotEmpty) {
      // 找到第一个 protein 食物的 plan_id
      if (selectedMealData != null) {
        final foods = selectedMealData['foods'] as List? ?? [];
        for (var foodItem in foods) {
          final foodInfo = foodItem['food'] as Map?;
          if (foodInfo != null &&
              (foodInfo['category'] as String?) == 'protein') {
            proteinId = foodItem['id'] as int?;
            break;
          }
        }
      }
      foodTypes.add({
        'name': categorizedFoods['protein']!.join(', '),
        'textPosition':
            Offset(containerWidth - 180.h, containerHeight * 0.7 + 50),
        'isVegetables': false,
        'isHighProtein': true, // 标记这是右下角位置
        'id': proteinId,
        'category': 'protein', // 添加食物的category属性
      });
    }

    // 位置4: 右上角 - fruit或fat（如果有第4个菜）
    String? fourthFoodName;
    int? fourthId;
    String? fourthCategory;
    if (categorizedFoods['fruit']!.isNotEmpty) {
      fourthFoodName = categorizedFoods['fruit']!.join(', ');
      fourthCategory = 'fruit';
      // 找到第一个 fruit 食物的 plan_id
      if (selectedMealData != null) {
        final foods = selectedMealData['foods'] as List? ?? [];
        for (var foodItem in foods) {
          final foodInfo = foodItem['food'] as Map?;
          if (foodInfo != null &&
              (foodInfo['category'] as String?) == 'fruit') {
            fourthId = foodItem['id'] as int?;
            break;
          }
        }
      }
    } else if (categorizedFoods['fat']!.isNotEmpty) {
      fourthFoodName = categorizedFoods['fat']!.join(', ');
      fourthCategory = 'fat';
      // 找到第一个 fat 食物的 plan_id
      if (selectedMealData != null) {
        final foods = selectedMealData['foods'] as List? ?? [];
        for (var foodItem in foods) {
          final foodInfo = foodItem['food'] as Map?;
          if (foodInfo != null && (foodInfo['category'] as String?) == 'fat') {
            fourthId = foodItem['id'] as int?;
            break;
          }
        }
      }
    }
    // 如果第四个位置已经有其他类别，继续查找
    if (fourthFoodName == null) {
      for (var key in categorizedFoods.keys) {
        if (key != 'vegetable' &&
            key != 'carbohydrate' &&
            key != 'protein' &&
            categorizedFoods[key]!.isNotEmpty) {
          fourthFoodName = categorizedFoods[key]!.join(', ');
          fourthCategory = key;
          if (selectedMealData != null) {
            final foods = selectedMealData['foods'] as List? ?? [];
            for (var foodItem in foods) {
              final foodInfo = foodItem['food'] as Map?;
              if (foodInfo != null &&
                  (foodInfo['category'] as String?) == key) {
                fourthId = foodItem['id'] as int?;
                break;
              }
            }
          }
          break;
        }
      }
    }
    if (fourthFoodName != null) {
      foodTypes.add({
        'name': fourthFoodName,
        'textPosition':
            Offset(containerWidth - 180.h, containerHeight * 0.3 - 50),
        'isVegetables': false,
        'isHighProtein': false,
        'isFourth': true, // 标记这是第四个菜（右上角）
        'id': fourthId,
        'category': fourthCategory, // 添加食物的category属性
      });
    }

    return Stack(
      children: foodTypes.map((foodType) {
        final textPosition = foodType['textPosition'] as Offset;
        final isVegetables = foodType['isVegetables'] as bool;
        final isHighProtein = foodType['isHighProtein'] as bool? ?? false;
        final isFourth = foodType['isFourth'] as bool? ?? false;
        final id = foodType['id'] as int?;
        final foodCategory = foodType['category'];

        return Stack(
          children: [
            // 食材类型文字
            Positioned(
              left: (isHighProtein || isFourth)
                  ? null
                  : textPosition.dx, // 右下角和右上角右对齐，其他左对齐
              right: (isHighProtein || isFourth)
                  ? 18.h
                  : (containerWidth / 2 - 18.h), // 左侧文字限制在半宽度
              top: textPosition.dy,
              child: Text(
                foodType['name'] as String,
                style: TextStyle(
                  color: Color(0xFFDEC1A4),
                  fontSize: 18.fSize,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: (isHighProtein || isFourth)
                    ? TextAlign.right
                    : TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Change图标按钮
            Positioned(
              left: (isHighProtein || isFourth)
                  ? null
                  : textPosition.dx, // 右侧右对齐，左侧左对齐
              right: (isHighProtein || isFourth) ? 18.h : null,
              top: isVegetables
                  ? textPosition.dy - iconSize // 左上角图标在文字下方
                  : textPosition.dy - iconSize - 4.h, // 其他位置图标在文字上方
              child: GestureDetector(
                onTap: () async {
                  // 跳转到 MenuPage 子页面，传递对应食物的 plan_id 和 category
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuPage(
                        category: foodCategory,
                        recipeFoodId: id ?? 0,
                      ),
                    ),
                  );
                  // 如果返回结果为 true，表示需要刷新数据
                  if (result == true) {
                    _loadCurrentUserFoods(); // 刷新用户数据
                  }
                },
                child: SizedBox(
                  width: 24.h,
                  height: 24.h,
                  child: Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF908070),
                    size: 20.h,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // MY PLAN 我的计划区域
  Widget _buildMyPlanSection() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MY PLAN',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'PressStart2P',
              fontSize: 24.fSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // 2x3 网格包装在边框容器中
          Container(
            padding: EdgeInsets.all(20.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(33.h),
              border: Border.all(
                color: Color(0xFFFFFFFF),
                width: 2.h,
              ),
              gradient: LinearGradient(
                begin: Alignment(0.83, -0.55), // 131deg
                colors: [
                  Color(0xFFFFF9F6), // 16.08%
                  Color(0xFFF2F5F6), // 83.14%
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x26000000), // rgba(0, 0, 0, 0.15)
                  offset: Offset(2, 2),
                  blurRadius: 15,
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Column(
              children: [
                // 搜索行
                if (_isSearchVisible)
                  Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon:
                            Icon(Icons.search, color: Color(0xFF666666)),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSearchVisible = false;
                              _searchController.clear();
                            });
                          },
                          child: Icon(Icons.close, color: Color(0xFF666666)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.h),
                          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.h),
                          borderSide: BorderSide(color: Color(0xFF4C4C4C)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.h,
                          vertical: 12.h,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 搜索放大镜按钮
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSearchVisible = true;
                            });
                          },
                          child: Container(
                            width: 40.h,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.h),
                              border: Border.all(
                                color: Color(0xFFE0E0E0),
                                width: 1.h,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  offset: Offset(0, 2.h),
                                  blurRadius: 4.h,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.search,
                              color: Color(0xFF666666),
                              size: 20.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // 网格内容
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.h,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _getFilteredPlans().length,
                  itemBuilder: (context, index) {
                    final filteredPlan = _getFilteredPlans()[index];
                    return _buildPlanCard(filteredPlan);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 计划卡片
  Widget _buildPlanCard(Map<String, dynamic> plan) {
    // 判断是否为收藏的食物（有name_en字段）
    final isCollectedFood = plan['name_en'] != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 2.h),
            blurRadius: 8.h,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.h),
                  topRight: Radius.circular(16.h),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.h),
                  topRight: Radius.circular(16.h),
                ),
                child: isCollectedFood
                    ? Image.network(
                        plan['image_url'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Color(0xFF454A30),
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 40.h,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        plan['image'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Color(0xFF454A30),
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 40.h,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          // 文字信息区域
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCollectedFood
                        ? (plan['name_en']?.toString() ?? '')
                        : (plan['name']?.toString() ?? ''),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.fSize,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // Text(
                  //   'by ${plan['user']}',
                  //   style: TextStyle(
                  //     color: Color(0xFF666666),
                  //     fontSize: 10.fSize,
                  //   ),
                  // ),
                  // Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isCollectedFood)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.h, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _getGradeColor(plan['score'] ?? '')
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6.h),
                          ),
                          child: Text(
                            plan['score'] ?? '',
                            style: TextStyle(
                              color: _getGradeColor(plan['score'] ?? ''),
                              fontSize: 10.fSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Icon(
                        Icons.favorite_border,
                        color: Color(0xFF666666),
                        size: 14.h,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 获取筛选后的计划列表
  List<Map<String, dynamic>> _getFilteredPlans() {
    // 如果有收藏的餐食，优先显示收藏的餐食
    if (_collectedMeals.isNotEmpty) {
      // 搜索过滤
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        return _collectedMeals.where((meal) {
          return (meal['name_en']?.toString().toLowerCase() ?? '')
              .contains(searchTerm);
        }).toList();
      }
      return _collectedMeals;
    }

    // 如果没有收藏的餐食，显示默认的diet plans
    if (_searchController.text.isEmpty) {
      return _dietPlans.asMap().entries.map((entry) {
        final plan = Map<String, dynamic>.from(entry.value);
        plan['originalIndex'] = entry.key;
        return plan;
      }).toList();
    }

    final searchTerm = _searchController.text.toLowerCase();
    return _dietPlans.asMap().entries.where((entry) {
      return entry.value['name'].toString().toLowerCase().contains(searchTerm);
    }).map((entry) {
      final plan = Map<String, dynamic>.from(entry.value);
      plan['originalIndex'] = entry.key;
      return plan;
    }).toList();
  }

  // 获取等级颜色
  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
      case 'A-':
        return Color(0xFF52D1C6);
      case 'B+':
      case 'B':
      case 'B-':
        return Color(0xFF779600);
      case 'C+':
      case 'C':
      case 'C-':
        return Color(0xFFFFA500);
      default:
        return Color(0xFF666666);
    }
  }
}

// 虚线绘制器
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF666666)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dashWidth = 5.0;
    final dashSpace = 5.0;
    double startX = 0;
    final endX = size.width;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth < endX ? startX + dashWidth : endX,
            size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
