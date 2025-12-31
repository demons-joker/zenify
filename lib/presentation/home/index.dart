import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/app_export.dart';
import '../../services/mqtt_service.dart';
import '../../services/user_session.dart';
import '../../services/api.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key, this.initialTab});

  final String? initialTab;

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
    {
      'name': 'Paleo diet',
      'user': 'Alice',
      'score': 'B+',
      'image': 'assets/images/figma/plate_jimeng.png'
    },
    {
      'name': 'Keto diet',
      'user': 'Bob',
      'score': 'A-',
      'image': 'assets/images/figma/plan_dish1.png'
    },
    {
      'name': 'Vegan diet',
      'user': 'Carol',
      'score': 'C+',
      'image': 'assets/images/figma/plate_jimeng.png'
    },
    {
      'name': 'Mediterranean',
      'user': 'David',
      'score': 'A',
      'image': 'assets/images/figma/plan_dish1.png'
    },
    {
      'name': 'Low carb',
      'user': 'Eve',
      'score': 'B',
      'image': 'assets/images/figma/plate_jimeng.png'
    },
    {
      'name': 'High protein',
      'user': 'Frank',
      'score': 'A+',
      'image': 'assets/images/figma/plan_dish1.png'
    },
  ];

  String _selectedMealType = 'BREAKFAST';
  final List<String> _mealTypes = ['BREAKFAST', 'LUNCH', 'DINNER', 'OTHER'];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

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

      // 计算目标日期 - 修复日期计算逻辑
      final now = DateTime.now();
      // DateTime.weekday: 1=周一, 2=周二, ..., 7=周日
      // _selectedDay: 0=周日, 1=周一, ..., 6=周六
      // 需要将 _selectedDay 转换为 weekday 格式
      final selectedWeekday =
          _selectedDay == 0 ? 7 : _selectedDay; // 0->7(周日), 1-6保持不变
      final daysToSubtract = now.weekday - selectedWeekday;
      final targetDate = now.subtract(Duration(days: daysToSubtract));
      final dateStr =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

      print('加载历史数据: userId=$userId, date=$dateStr');
      print('当前日期: ${now.toString()}, 目标日期: ${targetDate.toString()}');
      print(
          '当前weekday: ${now.weekday}, 选择weekday: $selectedWeekday, 减去天数: $daysToSubtract');

      // 调用API获取识别记录
      final result =
          await Api.getRecognitions({'date': dateStr, 'user_id': userId});

      print('API响应记录数: ${result.length}');

      // 清空当前数据
      _ateFoods = {
        'BREAKFAST': [],
        'LUNCH': [],
        'DINNER': [],
        'OTHER': [],
      };

      // 根据记录时间分类
      for (var record in result) {
        print('处理记录: ${record['created_at']}, status: ${record['status']}');
        final mealType = _getMealTypeByTimeOfDay(record['created_at']);
        print('分类为: $mealType');
        _ateFoods[mealType]?.add(_convertToFoodCard(record));
      }

      // 打印最终分类结果
      print('分类结果:');
      _ateFoods.forEach((key, value) {
        print('  $key: ${value.length}条');
      });

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('加载历史数据失败: $e');
      print('堆栈跟踪: ${StackTrace.current}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  /// 将识别记录转换为食物卡片数据
  Map<String, dynamic> _convertToFoodCard(Map<String, dynamic> record) {
    final status = record['status'] ?? 'unknown';
    final isAnalyzing = status == 'accepted' || status == 'processing';

    // 提取食物名称 - 使用英文名称
    final foods = record['foods'] as List? ?? [];
    final foodNames = foods
        .map((f) => f['food']?['name_en'] ?? f['food']?['name'] ?? 'Unknown')
        .join(', ');

    // 根据状态设置标题
    String title;
    if (isAnalyzing) {
      title = 'Analyzing...';
    } else if (foodNames.isNotEmpty) {
      title = foodNames;
    } else {
      title = 'Recognition Result';
    }

    return {
      'id': record['id'],
      'imageUrl': record['image_url'],
      'title': title,
      'isLiked': false,
      'isAnalyzing': isAnalyzing,
      'status': status,
      'sessionId': record['session_id']?.toString(),
      'timestamp': record['created_at'],
      'data': record,
    };
  }

  /// 根据时间字符串判断餐食类型
  String _getMealTypeByTimeOfDay(dynamic timeStr) {
    try {
      DateTime time;
      if (timeStr is String) {
        time = DateTime.parse(timeStr);
        print('解析时间: $timeStr -> $time, 小时: ${time.hour}');
      } else if (timeStr is DateTime) {
        time = timeStr;
        print('使用DateTime: $time, 小时: ${time.hour}');
      } else {
        print('无效时间格式: $timeStr');
        return 'OTHER';
      }

      final hour = time.hour;
      String mealType;
      if (hour >= 5 && hour < 11) {
        mealType = 'BREAKFAST';
      } else if (hour >= 11 && hour < 14) {
        mealType = 'LUNCH';
      } else if (hour >= 17 && hour < 21) {
        mealType = 'DINNER';
      } else {
        mealType = 'OTHER';
      }

      print('时间 ${time.hour}时 分类为: $mealType');
      return mealType;
    } catch (e) {
      print('解析时间失败: $e, 输入: $timeStr');
      return 'OTHER';
    }
  }

  /// 初始化MQTT
  Future<void> _initMQTT() async {
    try {
      await MQTTService().connect();
      _mqttSubscription = MQTTService().statusStream.listen((status) {
        _handleRecognitionStatus(status);
      });
    } catch (e) {
      print('MQTT init error: $e');
    }
  }

  /// 处理识别状态变化
  void _handleRecognitionStatus(RecognitionStatus status) async {
    if (!mounted) return;

    if (status.status == RecognitionStatusType.analyzing) {
      // 识别开始 - 切换到 ATE tab 并重新加载历史数据
      switchToATETab();
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
                      'assets/images/profile_avatar.png',
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
                    ['日', '一', '二', '三', '四', '五', '六'][index],
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

    return Container(
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
                              'Balanced diet',
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

                      // 卡路里显示 - 使用 Flexible 避免溢出
                      if (caloriesText.isNotEmpty)
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

                      if (caloriesText.isNotEmpty) SizedBox(width: 6.h),

                      // 编辑按钮
                      SizedBox(
                        width: 32.h,
                        height: 32.h,
                        child: GestureDetector(
                          onTap: () {
                            // 编辑功能
                          },
                          child: Icon(
                            Icons.edit,
                            color: Color(0xFF747474),
                            size: 20.h,
                          ),
                        ),
                      ),
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
                        height:
                            22.0 / 16.0, // line-height 22px / font-size 16px
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
        imagePath = 'assets/images/cai_unlock.png';
        break;
      case '主食':
        imagePath = 'assets/images/fan_unlock.png';
        break;
      case '肉食':
        imagePath = 'assets/images/rou_unlock.png';
        break;
      default:
        imagePath = 'assets/images/cai_unlock.png';
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
            onTap: () => setState(() => _selectedMealType = mealType),
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
              // 上部分内容（占90.h高度）
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: cardSize - 90.h,
                child: Stack(
                  children: [
                    // 中央分格餐盘（圆形）
                    Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final plateDiameter = math.min(
                                  constraints.maxWidth * 0.6,
                                  constraints.maxHeight * 0.8) -
                              20; // 缩小5像素

                          return SizedBox(
                            width: plateDiameter,
                            height: plateDiameter,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: plateDiameter,
                                  height: plateDiameter,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.12),
                                        blurRadius: 12.h,
                                        offset: Offset(0, 6.h),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/plate.png',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: Color(0xFF454A30),
                                        child: Icon(
                                          Icons.restaurant,
                                          color: Colors.white,
                                          size: 40.h,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // 食材类型标签和引导线（在整个上半部分区域）
                    _buildFoodTypeLabels(cardSize),
                  ],
                ),
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 40.h,
                            height: 40.h,
                            child: Image.asset(
                              'assets/images/collect.png',
                              width: 40.h,
                              height: 40.h,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 40.h,
                                height: 40.h,
                                color: Colors.grey.shade600,
                                child: Icon(
                                  Icons.collections,
                                  color: Colors.white,
                                  size: 20.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Collect',
                            style: TextStyle(
                              color: Color(0xFF908070),
                              fontSize: 14.fSize,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      // 右侧 Change 按钮
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 40.h,
                            height: 40.h,
                            child: Image.asset(
                              'assets/images/change.png',
                              width: 40.h,
                              height: 40.h,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 40.h,
                                height: 40.h,
                                color: Colors.grey.shade600,
                                child: Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 20.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Change',
                            style: TextStyle(
                              color: Color(0xFF908070),
                              fontSize: 14.fSize,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 分数【85】显示在左上角14:14位置
              Positioned(
                right: 14.h,
                top: 14.h,
                child: Container(
                  width: 48.h,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFC8FD00),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6.h,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.fSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

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

  // 构建食材类型标签和引导线
  Widget _buildFoodTypeLabels(double cardSize) {
    final containerWidth = cardSize; // 使用卡片总宽度
    final containerHeight = cardSize - 90.h; // 上半部分高度
    final foodTypes = [
      {
        'name': 'Vegetables',
        'textPosition': Offset(18.h, containerHeight * 0.3 - 50), // 向上移动5px
      },
      {
        'name': 'High-Carb Foods',
        'textPosition': Offset(18.h, containerHeight * 0.7 + 50), // 向下移动5px
      },
      {
        'name': 'High-Protein Foods',
        'textPosition': Offset(
            containerWidth - 180.h, containerHeight * 0.7 + 50), // 向下移动5px
      },
    ];

    return Stack(
      children: foodTypes.map((foodType) {
        final textPosition = foodType['textPosition'] as Offset;

        // 根据食材类型决定对齐方式和位置
        final isVegetables = foodType['name'] == 'Vegetables';
        final isHighProtein = foodType['name'] == 'High-Protein Foods';
        final textHeight = 18.fSize; // 文字高度
        final iconSize = 24.h; // 图标大小

        return Stack(
          children: [
            // 食材类型文字
            Positioned(
              left: isHighProtein
                  ? null
                  : textPosition.dx, // High-Protein Foods右对齐，其他左对齐
              right: isHighProtein ? 18.h : null, // High-Protein Foods距离右边框18px
              top: textPosition.dy,
              child: Text(
                foodType['name'] as String,
                style: TextStyle(
                  color: Color(0xFFDEC1A4),
                  fontSize: 18.fSize,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: isHighProtein ? TextAlign.right : TextAlign.left,
              ),
            ),
            // Change图标按钮
            Positioned(
              left: isHighProtein
                  ? null
                  : textPosition.dx, // High-Protein Foods右对齐，其他左对齐
              right: isHighProtein ? 18.h : null, // High-Protein Foods距离右边框18px
              top: isVegetables
                  ? textPosition.dy + textHeight + 4.h // Vegetables图标在文字下方
                  : textPosition.dy - iconSize - 4.h, // 其他图标在文字上方
              child: GestureDetector(
                onTap: () {
                  // 更换食材类型功能
                },
                child: SizedBox(
                  width: 24.h,
                  height: 24.h,
                  child: Image.asset(
                    'assets/images/icon-change.png',
                    width: 24.h,
                    height: 24.h,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 24.h,
                      height: 24.h,
                      color: Colors.grey.shade600,
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 12.h,
                      ),
                    ),
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
                child: plan['image']!.contains('.svg') ||
                        plan['image']!.contains('.png')
                    ? Image.asset(
                        plan['image']!,
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
                        plan['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Color(0xFF454A30),
                          child: Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 40.h,
                          ),
                        ),
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
                    plan['name']!,
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
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.h, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _getGradeColor(plan['score']!)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6.h),
                        ),
                        child: Text(
                          plan['score']!,
                          style: TextStyle(
                            color: _getGradeColor(plan['score']!),
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
