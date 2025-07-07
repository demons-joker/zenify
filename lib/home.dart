import 'dart:math';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. 标题行
          _buildTitleRow(),
          // 2. 星期Tabs
          _buildWeekTabs(),
          // 3. "今天吃什么？"文案
          _buildTodayText(),
          // 4. 食谱按钮
          _buildRecipeButton(),
          // 5. 晚餐Card
          _buildDinnerCard(),
          // 6. 分割线
          _buildDividerWithClock(),
          // 7. 进度条Card
          _buildProgressCard(),
          // 8. 餐食Card
          _buildMealsCard(),
        ],
      ),
    );
  }

  // 1. 标题行
  Widget _buildTitleRow() {
    return Container(
      height: 30,
      width: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Text(
        '饮食',
        style: TextStyle(
            color: Color(0xFF343434),
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  // 2. 星期Tabs
  Widget _buildWeekTabs() {
    final weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    int selectedDay = DateTime.now().weekday % 7; // 使用状态变量

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: 37,
          margin: EdgeInsets.symmetric(horizontal: 20), // 左右边距20px
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 左右平分
            children: List.generate(weekDays.length, (index) {
              final isSelected = index == selectedDay;
              return GestureDetector(
                onTap: () => setState(() => selectedDay = index), // 点击切换
                child: Container(
                  width: 30, // 固定宽度确保均匀分布
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            weekDays[index],
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Color(0xFF4D4D4D),
                              fontSize: 14,
                              fontWeight: FontWeight.bold, // 字体加粗
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // 3. "今天吃什么？"文案
  Widget _buildTodayText() {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '今天吃什么？',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
      ),
    );
  }

  // 4. 食谱按钮
  Widget _buildRecipeButton() {
    return Align(
      alignment: Alignment.centerLeft, // 组件靠左对齐
      child: Padding(
        padding: EdgeInsets.only(left: 10), // 左侧 10px 边距
        child: Container(
          width: 171,
          height: 37,
          margin: EdgeInsets.only(bottom: 10), // 右 20px 边距
          decoration: BoxDecoration(
            color: Color(0xFFEA7B3C),
            borderRadius: BorderRadius.circular(18.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, // 内部元素靠左
            children: [
              Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Icon(Icons.restaurant, color: Colors.black, size: 20),
              ),
              Text(
                '168轻食食谱',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.arrow_forward, color: Colors.black, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 5. 晚餐Card
  Widget _buildDinnerCard() {
    return Padding(
      // 添加外层Padding
      padding: EdgeInsets.symmetric(horizontal: 10), // 左右各10px
      child: Stack(
        children: [
          // 主Card
          Container(
            width: double.infinity,
            height: 210,
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
              color: Color(0xFFEAEAEA),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // 阴影颜色和透明度
                  offset: Offset(2, 2), // 右下方向2px偏移
                  blurRadius: 2, // 模糊半径2px
                  spreadRadius: 1, // 不扩展阴影
                ),
              ],
            ),
            child: Column(
              children: [
                // 图片区域
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(child: _buildFoodItem('沙拉')),
                      SizedBox(width: 5), // 起始间距
                      Expanded(child: _buildFoodItem('牛排')),
                      SizedBox(width: 5), // 起始间距
                      Expanded(child: _buildFoodItem('汤')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 标题标签
          Positioned(
            top: 0,
            left: 0, // 从150调整为140，保持居中效果
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFEAEAEA),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // 阴影颜色和透明度
                    offset: Offset(0, -5),
                    blurRadius: 2, // 模糊半径2px
                    spreadRadius: -2, // 不扩展阴影
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Text(
                  '晚餐',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 食物项组件
  Widget _buildFoodItem(String name) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 148,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 这里应该是食物图片，用占位色代替
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // 底部文字区域
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Align(
                    // 新增Align组件控制对齐方式
                    alignment: Alignment.centerLeft, // 靠左对齐
                    child: Padding(
                      // 添加内边距
                      padding: EdgeInsets.only(left: 10), // 左侧留12px间距
                      child: Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          height: 1.2, // 行高调整，确保垂直居中
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 0, // 从150调整为140，保持居中效果
                child: Container(
                  width: 46,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(23),
                      bottomRight: Radius.circular(23),
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.autorenew,
                        size: 20, color: Colors.grey[700]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. 分割线
  Widget _buildDividerWithClock() {
    return Padding(
      padding: EdgeInsets.only(top: 30, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 100),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_empty, size: 18),
                SizedBox(width: 5),
                Text(
                  '6h后禁食',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
          ),
        ],
      ),
    );
  }

  // 7. 进度条Card
  Widget _buildProgressCard() {
    final progress = 0.5; // 50%进度

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //摄入量
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildDataItem(Icons.restaurant, '摄入量', '600'),
          ]),
          // 进度条
          Stack(
            alignment: Alignment.center,
            children: [
              // 背景圆环
              Container(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _ProgressPainter(
                    progress: 1.0,
                    color: Colors.grey,
                    strokeWidth: 5,
                  ),
                ),
              ),
              // 进度圆环
              Container(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _ProgressPainter(
                    progress: progress,
                    color: Color(0xFFEA7B3C),
                    strokeWidth: 5,
                  ),
                ),
              ),
              // 进度指示器
              _buildProgressIndicator(progress),
              // 中心文字
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '还可以吃',
                    style: TextStyle(
                      color: Color(0xFFEA7B3C),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '600',
                    style: TextStyle(
                      color: Color(0xFFEA7B3C),
                      fontSize: 23,
                      height: 30 / 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      color: Color(0xFFEA7B3C),
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 代谢量
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildDataItem(Icons.local_fire_department, '代谢量', '1200'),
          ]),
        ],
      ),
    );
  }

  // 8. 餐食Card
  Widget _buildMealsCard() {
    // 获取当前时间
    final now = DateTime.now();
    final currentTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    // 根据时间判断当前餐段
    String getMealType() {
      if (now.hour >= 5 && now.hour < 10) return '早餐';
      if (now.hour >= 11 && now.hour < 14) return '午餐';
      if (now.hour >= 17 && now.hour < 21) return '晚餐';
      return '加餐';
    }

    // 模拟餐食数据
    final meals = [
      {'name': '鸡胸肉', 'type': '蛋白质', 'calories': '200'},
      {'name': '蔬菜沙拉', 'type': '纤维素', 'calories': '150'},
      {'name': '全麦面包', 'type': '碳水化合物', 'calories': '180'},
    ];
    return Stack(children: [
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 40, right: 20, bottom: 20, left: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第一行：标题 + 时间
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                '${getMealType()} $currentTime',
                style: TextStyle(
                  color: Color(0xFFDEDEDE),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // 餐食列表
            ...meals
                .map((meal) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 餐食图片
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          // 餐食名称和类型
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal['name']!,
                                    style: TextStyle(
                                      color: Color(0xFFDEDEDE),
                                      fontSize: 18,
                                      height: 20 / 18,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    meal['type']!,
                                    style: TextStyle(
                                      color: Color(0xFF7C7C7C),
                                      fontSize: 16,
                                      height: 20 / 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 卡路里
                          Text(
                            '${meal['calories']}千卡',
                            style: TextStyle(
                              color: Color(0xFF7C7C7C),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
      Positioned(
          top: 30,
          right: 120,
          child: Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                '25min',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
      Positioned(
          top: 30,
          right: 20,
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                '400kcal',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
    ]);
  }

  // 进度指示器
  Widget _buildProgressIndicator(double progress) {
    final angle = 2 * 3.1416 * progress - 3.1416 / 2; // 转换为弧度，从顶部开始
    final x = 87.5 + 80 * cos(angle); // 圆心x=87.5, 半径=80
    final y = 87.5 + 80 * sin(angle);

    return Positioned(
      left: x - 2.5,
      top: y - 2.5,
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: Color(0xFFEA7B3C),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // 数据项组件
  Widget _buildDataItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 30),
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12)),
        SizedBox(height: 2),
        Text(value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// 自定义进度条绘制
class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1416 / 2, // 从顶部开始
      2 * 3.1416 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
