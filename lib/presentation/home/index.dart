import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:zenify/components/food_item_card.dart';
import 'package:zenify/utils/iconfont.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double value;

  _RingPainter({
    required this.color,
    required this.strokeWidth,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 绘制静态背景
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      backgroundPaint,
    );

    // 绘制动态进度条
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -pi / 2;
    final sweepAngle = -pi * 2 * value;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['EAT', 'ATE'];
  int _selectedDay = DateTime.now().weekday; // 0-6 for Monday-Sunday
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _ringAnimationController;
  late Animation<double> _ringAnimation;
  String _selectedMealType = 'BREAKFAST';
  final List<String> _mealTypes = ['BREAKFAST', 'LUNCH', 'DINNER', 'OTHER'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 600).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _animationController.forward();

    _ringAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _ringAnimation = Tween<double>(begin: 0.0, end: 10.0 / 40)
        .animate(_ringAnimationController)
      ..addListener(() {
        setState(() {});
      });
    _ringAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _ringAnimationController.dispose();
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

          // // 周日期选择器
          // _buildWeekSelector(),

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
                    return const Center(child: Text('开发中'));
                  }
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRing({
    required String iconPath,
    required int value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 圆环背景
              CustomPaint(
                size: const Size(24, 24),
                painter: _RingPainter(
                  color: const Color(0xFF343822),
                  strokeWidth: 3,
                  value: 1.0,
                ),
              ),
              // 圆环进度条
              CustomPaint(
                size: const Size(24, 24),
                painter: _RingPainter(
                  color: const Color(0xFFD7EC9C),
                  strokeWidth: 3,
                  value: _ringAnimation.value,
                ),
              ),
              // 图标
              Image.asset(
                iconPath,
                width: 16,
                height: 16,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFA4A4A4),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // 顶部区域
  Widget _buildTopHeader() {
    return Container(
      height: 98.h,
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
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 左边：EAT/ATE tab 切换
            Row(
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
            // 中间：头像
            GestureDetector(
              onTap: () {
                // 头像功能
              },
              child: Container(
                width: 40.h,
                height: 40.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.h),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: Offset(0, 1.h),
                      blurRadius: 1.h,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.h),
                  child: Image.asset(
                    'assets/images/figma/avatar_center.png',
                    width: 40.h,
                    height: 40.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // 右边：菜单按钮
            GestureDetector(
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
          ],
        ),
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
          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
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

  // COLLECT 收集统计区域
  Widget _buildCollectSection() {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 20.h),
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.h),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            offset: Offset(0, 4.h),
            blurRadius: 16.h,
          ),
        ],
      ),
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
                  fontSize: 28.fSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Weekly Update',
                style: TextStyle(
                  color: Color(0xFF779600),
                  fontSize: 14.fSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // 食物收集统计卡片
          Container(
            padding: EdgeInsets.all(20.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8FFF8),
                  Color(0xFFF0F7F0),
                ],
              ),
              borderRadius: BorderRadius.circular(20.h),
              border: Border.all(
                color: Color(0xFFE8F5E8),
                width: 1.h,
              ),
            ),
            child: Column(
              children: [
                // 标题行
                Row(
                  children: [
                    Icon(
                      Icons.eco,
                      color: Color(0xFF779600),
                      size: 20.h,
                    ),
                    SizedBox(width: 8.h),
                    Text(
                      '本周食物种类收集',
                      style: TextStyle(
                        color: Color(0xFF2D3416),
                        fontSize: 16.fSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

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
                
                SizedBox(height: 20.h),
                
                // 进度总结
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Color(0xFF779600).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.h),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '总进度',
                        style: TextStyle(
                          color: Color(0xFF2D3416),
                          fontSize: 14.fSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.h),
                      Text(
                        '15/25',
                        style: TextStyle(
                          color: Color(0xFF779600),
                          fontSize: 16.fSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.h),
                      Text(
                        '(60%)',
                        style: TextStyle(
                          color: Color(0xFF779600),
                          fontSize: 12.fSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Tips 文字
          Container(
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12.h),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Color(0xFFFFA726),
                  size: 20.h,
                ),
                SizedBox(width: 12.h),
                Expanded(
                  child: Text(
                    '建议：多样化饮食可以获得更全面的营养，尽量每周达到推荐的食物种类数量。',
                    style: TextStyle(
                      color: Color(0xFF5D4037),
                      fontSize: 13.fSize,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 食物收集卡片 - 像素风格
  Widget _buildFoodCollectCard({
    required String icon,
    required String name,
    required int current,
    required int target,
    required Color color,
    required Color bgColor,
  }) {
    final progress = current / target;
    
    return Container(
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: color,
          width: 3.h,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: Offset(4.h, 4.h),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: Offset(-2.h, -2.h),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // 像素风格图标容器
          Container(
            width: 40.h,
            height: 40.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              border: Border.all(color: color, width: 2.h),
            ),
            child: Center(
              child: Text(
                icon,
                style: TextStyle(fontSize: 24.h),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          
          // 像素风格食物名称
          Text(
            name.toUpperCase(),
            style: TextStyle(
              color: Colors.black87,
              fontSize: 10.fSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 8.h),
          
          // 像素风格进度条
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              border: Border.all(color: Colors.black87, width: 1.h),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.black, width: 0.5.h),
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          
          // 像素风格数字
          Text(
            '$current/$target',
            style: TextStyle(
              color: Colors.black,
              fontSize: 10.fSize,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          
          SizedBox(height: 4.h),
          
          // 像素风格百分比
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 2.h),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black, width: 1.h),
            ),
            child: Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8.fSize,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }



  // RECOMMEND 推荐区域
  Widget _buildRecommendSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECOMMEND',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.fSize,
              fontWeight: FontWeight.bold,
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
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(22.h),
      ),
      child: Row(
        children: _mealTypes.map((mealType) {
          final isSelected = mealType == _selectedMealType;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMealType = mealType),
              child: Container(
                margin: EdgeInsets.all(4.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(18.h),
                ),
                child: Center(
                  child: Text(
                    mealType,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Color(0xFF666666),
                      fontSize: 12.fSize,
                      fontWeight: FontWeight.w500,
                    ),
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
    return Container(
      width: double.infinity,
      height: 380.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20.h),
        boxShadow: [
          BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 4.h),
              blurRadius: 12.h),
        ],
      ),
      padding: EdgeInsets.all(20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 中央分格餐盘（圆形）和评分 badge
          SizedBox(height: 8.h),
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 180.h,
                  height: 180.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12.h,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/figma/plate_jimeng.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: -8.h,
                  top: -8.h,
                  child: Container(
                    width: 48.h,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Color(0xFFC8FD00),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 6.h,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '85',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.fSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          // 食物类别
          _buildFoodCategory('High-Protein Foods', 'assets/images/figma/collect_meat.png'),
          SizedBox(height: 12.h),
          _buildFoodCategory('Vegetables', 'assets/images/figma/collect_veg.png'),
          SizedBox(height: 12.h),
          _buildFoodCategory('High-Carb Foods', 'assets/images/figma/collect_starch.png'),

          Spacer(),

          // 评分和操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '85',
                style: TextStyle(
                  color: Color(0xFFC8FD00),
                  fontSize: 48.fSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 44.h,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF779600),
                      borderRadius: BorderRadius.circular(22.h),
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 24.h,
                    ),
                  ),
                  SizedBox(width: 12.h),
                  Container(
                    width: 44.h,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF454A30),
                      borderRadius: BorderRadius.circular(22.h),
                    ),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24.h,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 食物类别
  Widget _buildFoodCategory(String title, String iconPath) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
      decoration: BoxDecoration(
        color: Color(0xFF454A30),
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                iconPath,
                width: 24.h,
                height: 24.h,
              ),
              SizedBox(width: 12.h),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.fSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
            decoration: BoxDecoration(
              color: Color(0xFF779600),
              borderRadius: BorderRadius.circular(16.h),
            ),
            child: Text(
              '更换',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.fSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MY PLAN 我的计划区域
  Widget _buildMyPlanSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MY PLAN',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.fSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // 2x3 网格
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.h,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.75,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildPlanCard(index);
            },
          ),
        ],
      ),
    );
  }

  // 计划卡片
  Widget _buildPlanCard(int index) {
    final plans = [
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

    final plan = plans[index];

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
            flex: 3,
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
                    : CustomImageView(
                        imagePath: plan['image']!,
                        fit: BoxFit.cover,
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
                  SizedBox(height: 2.h),
                  Text(
                    'by ${plan['user']}',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 10.fSize,
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.h, vertical: 2.h),
                        decoration: BoxDecoration(
                          color:
                              _getGradeColor(plan['score']!).withOpacity(0.2),
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
