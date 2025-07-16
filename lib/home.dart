import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zenify/services/api.dart';
import 'package:zenify/utils/iconfont.dart';
import 'menu_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> allRecipes = [];
  dynamic currentRecipe;
  List<dynamic> currentFoods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      setState(() => isLoading = true);
      final response = await Api.getRecipes(RecipesRequest(
        skip: 0,
        limit: 1000,
        isPreset: false,
      ));
      setState(() {
        allRecipes = response;
        if (allRecipes.isNotEmpty) {
          currentRecipe = allRecipes[0];
          _updateFoodsFromRecipe(currentRecipe);
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('获取食谱失败: $e');
    }
  }

  void _updateFoodsFromRecipe(dynamic recipe) {
    if (recipe != null && recipe['recipe_foods'] != null) {
      setState(() {
        currentFoods = recipe['recipe_foods']
            .where((rf) => rf['food'] != null) // Filter out null foods
            .map((rf) => rf['food'])
            .toList();
      });
    }
  }

  void _switchRandomRecipe() {
    if (allRecipes.isNotEmpty) {
      final random = Random();
      final newRecipe = allRecipes[random.nextInt(allRecipes.length)];
      setState(() => currentRecipe = newRecipe);
      _updateFoodsFromRecipe(newRecipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTitleRow(),
          _buildWeekTabs(),
          _buildTodayText(),
          _buildRecipeButton(),
          _buildCurrentMealsCard(context),
          _buildDividerWithClock(),
          _buildProgressCard(),
          _buildMealsCard(),
        ],
      ),
    );
  }

  // 1. 标题行 (保持不变)
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

  // 2. 星期Tabs (保持不变)
  Widget _buildWeekTabs() {
    final weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    int selectedDay = DateTime.now().weekday % 7;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: 37,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(weekDays.length, (index) {
              final isSelected = index == selectedDay;
              return GestureDetector(
                onTap: () => setState(() => selectedDay = index),
                child: Container(
                  width: 30,
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
                              fontWeight: FontWeight.bold,
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

  // 3. "今天吃什么？"文案 (保持不变)
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

  // 4. 食谱按钮 (优化后)
  Widget _buildRecipeButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 10),
        child: GestureDetector(
          onTap: _switchRandomRecipe,
          child: Container(
            width: 171,
            height: 37,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Color(0xFFEA7B3C),
              borderRadius: BorderRadius.circular(18.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(Icons.restaurant, color: Colors.black, size: 20),
                ),
                Expanded(
                  child: Text(
                    currentRecipe != null
                        ? currentRecipe['name'] ?? '随机食谱'
                        : '暂无数据',
                    style: TextStyle(
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.autorenew, color: Colors.black, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. 当前餐食Card (优化后)
  Widget _buildCurrentMealsCard(BuildContext context) {
    if (currentFoods.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text('暂无食物数据'),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          // 主Card
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 0),
            decoration: BoxDecoration(
              color: Color(0xFFEAEAEA),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(2, 2),
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: _buildFoodItemsRow(context, currentFoods),
          ),
          // 标题标签
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFEAEAEA),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(0, -5),
                    blurRadius: 2,
                    spreadRadius: -2,
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
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                IconFont.genghuan,
                size: 45,
                color: Color.fromARGB(255, 243, 109, 14),
              ),
              onPressed: _switchRandomRecipe,
            ),
          ),
        ],
      ),
    );
  }

  // 构建食物项行 (优化后)
  Widget _buildFoodItemsRow(BuildContext context, List<dynamic> foods) {
    // 限制最多显示4个食物
    final displayFoods = foods.length > 4 ? foods.sublist(0, 4) : foods;

    if (displayFoods.length <= 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: displayFoods
            .map((food) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: _buildFoodItem(context, food),
                  ),
                ))
            .toList(),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: displayFoods
                .sublist(0, 3)
                .map((food) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: _buildFoodItem(context, food),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 10),
          _buildFoodItem(context, displayFoods[3]),
        ],
      );
    }
  }

  // 食物项组件 (优化后)
  Widget _buildFoodItem(BuildContext context, dynamic food) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 188,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 食物图片
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 148,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: food['image_url'] != null
                        ? DecorationImage(
                            image: NetworkImage(food['image_url']),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              // 底部文字区域
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
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
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        food['name'] ?? '未知食物',
                        style: TextStyle(
                          color: Colors.white,
                          height: 1.2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // 刷新按钮
              Positioned(
                bottom: 0,
                left: 0,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuPage(
                            category: food['name'] ?? '食物',
                            recipeFoods: currentFoods,
                          ),
                        ),
                      );
                    },
                    splashColor: Colors.orange.withOpacity(0.6),
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
                        child: Icon(
                          Icons.autorenew,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. 分割线 (保持不变)
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
                Icon(IconFont.duanshidaojishi, size: 18),
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

  // 7. 进度条Card (保持不变)
  Widget _buildProgressCard() {
    final progress = 0.5;
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
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildDataItem(Icon(IconFont.yisheruzhi), '摄入量', '600'),
          ]),
          Stack(
            alignment: Alignment.center,
            children: [
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
              _buildProgressIndicator(progress),
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
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildDataItem(Icon(IconFont.a004jichudaixie), '代谢量', '1200'),
          ]),
        ],
      ),
    );
  }

  // 8. 餐食Card (保持不变)
  Widget _buildMealsCard() {
    final now = DateTime.now();
    final currentTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    String getMealType() {
      if (now.hour >= 5 && now.hour < 10) return '早餐';
      if (now.hour >= 11 && now.hour < 14) return '午餐';
      if (now.hour >= 17 && now.hour < 21) return '晚餐';
      return '加餐';
    }

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
            ...meals
                .map((meal) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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

  // 进度指示器 (保持不变)
  Widget _buildProgressIndicator(double progress) {
    final angle = 2 * 3.1416 * progress - 3.1416 / 2;
    final x = 87.5 + 80 * cos(angle);
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

  // 数据项组件 (保持不变)
  Widget _buildDataItem(Icon icon, String label, String value) {
    return Column(
      children: [
        icon,
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12)),
        SizedBox(height: 2),
        Text(value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// 自定义进度条绘制 (保持不变)
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
      -3.1416 / 2,
      2 * 3.1416 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
