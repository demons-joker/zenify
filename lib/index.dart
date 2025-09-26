import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:zenify/components/food_item_card.dart';
import 'package:zenify/utils/iconfont.dart';

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
  // 圆环绘制类
  late TabController _tabController;
  final List<String> _tabs = ['饮食', '规划'];
  int _selectedDay = DateTime.now().weekday; // 0-6 for Monday-Sunday
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _ringAnimationController;
  late Animation<double> _ringAnimation;

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
    super.dispose();
  }

  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 自定义 tabs 切换
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: _tabs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tab = entry.value;
                    return GestureDetector(
                      onTap: () => setState(() => _currentTabIndex = index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _currentTabIndex == index
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                              color: _currentTabIndex == index
                                  ? Colors.black
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 18),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(238, 238, 238, 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(IconFont.yisheruzhi, size: 24),
                      const SizedBox(width: 2),
                      const Text(
                        '0',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 周算日期组件
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final isSelected = index == _selectedDay;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = index),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        ['日', '一', '二', '三', '四', '五', '六'][index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // 内容区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: IndexedStack(
                index: _currentTabIndex,
                children: _tabs.map((tab) {
                  if (tab == '饮食') {
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

  Widget _buildDietTab() {
    return Column(
      children: [
        // 卡片轮播组件
        CarouselSlider(
          items: [
            // 合并第二行和第三行为一个 item
            Column(
              children: [
                // 第二行：两张卡片
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 5.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 130,
                        height: 128,
                        child: Card(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/store.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${DateTime.now().month}月${DateTime.now().day}号',
                                            style: const TextStyle(
                                              color: Color(0xFFA4A4A4),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          RichText(
                                            text: const TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '92',
                                                  style: TextStyle(
                                                    color: Color(0xFFC8FD00),
                                                    fontSize: 40,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: '分',
                                                  style: TextStyle(
                                                    color: Color(0xFFC8FD00),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            '无需大调整',
                                            style: TextStyle(
                                              color: Color(0xFFA4A4A4),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Image.asset(
                                        'assets/images/dui.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 128,
                          child: Card(
                            color: Colors.black,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/line.png'),
                                          fit: BoxFit.fitWidth,
                                          alignment: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0,
                                            right: 10.0,
                                            top: 5,
                                            bottom: 5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '预测20天内完成',
                                              style: TextStyle(
                                                color: Color(0xFFA4A4A4),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            const Text(
                                              '超越',
                                              style: TextStyle(
                                                color: Color(0xFFA4A4A4),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.baseline,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              children: [
                                                RichText(
                                                  text: const TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: '80%',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFFA4A4A4),
                                                          fontSize: 28,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: '(用户)',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xFFA4A4A4),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF454A30),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            9),
                                                  ),
                                                  child: const Text(
                                                    '体重',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Image.asset(
                                    'assets/images/ss.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 第三行：一整行卡片
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5.0, vertical: 5.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    color: Colors.black,
                    child: SizedBox(
                      height: 135,
                      width: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '还可吃',
                                        style: TextStyle(
                                          color: Color(0xFFD7EC9C),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        '600cal',
                                        style: TextStyle(
                                          color: Color(0xFFFEFEFE),
                                          fontSize: 28,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  SizedBox(
                                    height: 50,
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 18,
                                          left: 0,
                                          right: 0,
                                          child: Stack(
                                            children: [
                                              Container(
                                                height: 6,
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF454A30),
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                              ),
                                              Container(
                                                height: 6,
                                                width: _animation.value <= 1200
                                                    ? (_animation.value /
                                                        1200 *
                                                        100)
                                                    : double.infinity,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFC8FD00),
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          bottom: 0,
                                          child: Text(
                                            '0',
                                            style: TextStyle(
                                              color: Color(0xFFA4A4A4),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 100,
                                          bottom: 0,
                                          child: Text(
                                            '1200',
                                            style: TextStyle(
                                              color: Color(0xFFA4A4A4),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            left: 105,
                                            bottom: 30,
                                            child: Container(
                                              width: 20,
                                              height: 20,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/nice.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )),
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Text(
                                            '∞',
                                            style: TextStyle(
                                              color: Color(0xFFA4A4A4),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          VerticalDivider(
                            color: Color(0xFF454A30),
                            width: 1,
                            indent: 12,
                            endIndent: 12,
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 蛋白质
                                  _buildNutrientRing(
                                    iconPath: 'assets/images/db.png',
                                    value: 10,
                                    label: '蛋白10g',
                                  ),
                                  const SizedBox(height: 12),
                                  // 碳水
                                  _buildNutrientRing(
                                    iconPath: 'assets/images/ts.png',
                                    value: 10,
                                    label: '碳水10g',
                                  ),
                                  const SizedBox(height: 12),
                                  // 脂肪
                                  _buildNutrientRing(
                                    iconPath: 'assets/images/zf.png',
                                    value: 10,
                                    label: '脂肪10g',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          options: CarouselOptions(
            height: 320, // 调整高度以容纳两行卡片
            enableInfiniteScroll: true,
            autoPlay: false, // 取消自动轮播
            viewportFraction: 1.0,
          ),
        ),
        // 新增功能模块
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.topCenter,
            children: [
              Positioned(
                top: -35,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Container(
                      width: 89,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF232323),
                        borderRadius: BorderRadius.circular(27),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B6969).withOpacity(0.25),
                            blurRadius: 4.186,
                            offset: const Offset(1.495, 1.495),
                          ),
                        ],
                      ),
                      child: Center(
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: '8',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 29,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: '/',
                                style: TextStyle(
                                  color: Color(0xFFBEBEBE),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: '10',
                                style: TextStyle(
                                  color: Color(0xFFBEBEBE),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  // 第一行：8/10
                  // 第二行：图标和文字
                  Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    margin: const EdgeInsets.only(top: 45, bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: const Color(0xFFF1F1F1),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/c1.png',
                                width: 24, height: 24),
                            const SizedBox(width: 4),
                            const Text(
                              '10g',
                              style: TextStyle(
                                color: Color(0xFF9A9A9A),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset('assets/images/c2.png',
                                width: 24, height: 24),
                            const SizedBox(width: 4),
                            const Text(
                              '10g',
                              style: TextStyle(
                                color: Color(0xFF9A9A9A),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset('assets/images/c3.png',
                                width: 24, height: 24),
                            const SizedBox(width: 4),
                            const Text(
                              '10g',
                              style: TextStyle(
                                color: Color(0xFF9A9A9A),
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '600kcal',
                          style: TextStyle(
                            color: Color(0xFF8FB500),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 第三行：图片、文字和按钮
                  Container(
                    margin: const EdgeInsets.only(bottom: 80),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              FoodItemCard(
                                name: '娃娃菜',
                                calories: '100kcal',
                                weight: '200g',
                              ),
                              const SizedBox(height: 8),
                              FoodItemCard(
                                name: '娃娃菜',
                                calories: '100kcal',
                                weight: '200g',
                              ),
                              FoodItemCard(
                                name: '娃娃菜',
                                calories: '100kcal',
                                weight: '200g',
                              ),
                              FoodItemCard(
                                name: '西兰花',
                                calories: '50kcal',
                                weight: '150g',
                              ),
                              // 可以继续添加更多FoodItemCard
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
