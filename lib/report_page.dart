import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zenify/components/common_card.dart';
import 'package:zenify/services/user_session.dart';
import 'package:zenify/utils/iconfont.dart';
import 'package:zenify/services/api.dart';
import 'package:zenify/models/meal_record.dart';

class GlucoseData {
  final String time;
  final double value;

  GlucoseData({required this.time, required this.value});
}

class _LeftArrowPainter extends CustomPainter {
  final Color color;

  _LeftArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 箭头头部（三角形）
    final arrowHead = Path();
    arrowHead.moveTo(14, -6);
    arrowHead.lineTo(0, 0);
    arrowHead.lineTo(14, 6);
    arrowHead.close();

    // 箭杆（矩形）
    final arrowBody = Path();
    arrowBody.addRect(Rect.fromLTRB(14, 1, size.width, -1));

    // 合并路径
    final path = Path.combine(PathOperation.union, arrowHead, arrowBody);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  MealRecord? mealRecordsData;
  num totalScore = 0;
  dynamic totalCal = '';
  List<NutrientData> nData = [
    NutrientData(name: "蛋白质", value: 30, color: Colors.blue),
    NutrientData(name: "脂肪", value: 20, color: Colors.red),
    NutrientData(name: "碳水化合物", value: 40, color: Colors.green),
    NutrientData(name: "膳食纤维", value: 10, color: Colors.orange),
  ];
  List chartColors = [Colors.blue, Colors.green, Colors.yellow, Colors.orange];
  List<dynamic> foods = [];
  // 血糖数据
  List<GlucoseData> get glucoseData => [
        GlucoseData(time: '00:00', value: 4.2),
        GlucoseData(time: '03:00', value: 5.1),
        GlucoseData(time: '06:00', value: 6.7),
        GlucoseData(time: '09:00', value: 7.8),
        GlucoseData(time: '12:00', value: 5.4),
        GlucoseData(time: '15:00', value: 4.9),
        GlucoseData(time: '18:00', value: 5.6),
        GlucoseData(time: '21:00', value: 6.2),
      ];

  @override
  void initState() {
    super.initState();
    _fetchMealRecords();
  }

  Future<void> _fetchMealRecords() async {
    try {
      final data = await Api.getMealRecordsDetail({
        'user_id': await UserSession.userId,
        'plate_id': 1,
        'meal_record_id': 1
      });
      print('mealRecordsData: $data');
      setState(() {
        if (data != null) {
          mealRecordsData = MealRecord.fromJson(data);
          print('mealRecordsData1: $data');
          foods = mealRecordsData!.foods;
          //营养成分数据
          nData = [
            NutrientData(
                name: '蛋白质',
                value: double.parse(mealRecordsData!.nutritiveProportion.protein
                    .toStringAsFixed(2)),
                color: chartColors[0]),
            NutrientData(
                name: '脂肪',
                value: double.parse(mealRecordsData!.nutritiveProportion.fat
                    .toStringAsFixed(2)),
                color: chartColors[1]),
            NutrientData(
                name: '碳水化合物',
                value: double.parse(mealRecordsData!
                    .nutritiveProportion.carbohydrate
                    .toStringAsFixed(2)),
                color: chartColors[2]),
            NutrientData(
                name: '膳食纤维',
                value: double.parse(mealRecordsData!.nutritiveProportion.fiber
                    .toStringAsFixed(2)),
                color: chartColors[3]),
          ];
          totalScore = mealRecordsData!.nutritionAnalysis.mealScore * 10;
          totalCal = '${(mealRecordsData!.totalCalories).toInt()}kcal';
        }
      });
    } catch (e) {
      debugPrint('获取餐食记录失败: $e');
    }
  }

  Color get titleColor => const Color(0XFF292929);
  Color get text2Color => const Color(0XFF595959);

  @override
  Widget build(BuildContext context) {
    // 示例数据

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          alignment: Alignment.centerRight,
          child: const Text(
            '详细参数',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //     '详细信息',
              //     style: TextStyle(
              //       fontSize: 18,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ],
              //   ),
              // ),

              // Tabs行
              _buildTabs(),

              const SizedBox(height: 30),
              // 文案内容
              _buildKcalCard(),
              const SizedBox(height: 30),
              // // 卡路里统计块
              // _buildCalorieBlock(),

              // const SizedBox(height: 20),

              // 营养成分分析块
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 0,
                    sectionsSpace: 2, // 扇区间距（可选）
                    startDegreeOffset: -90, // 从12点钟方向开始
                    sections: nData.map<PieChartSectionData>((item) {
                      print(
                          'nDataitem: ${item.name} ${item.value} ${item.color}');
                      final total =
                          nData.fold(0.0, (sum, item) => sum + item.value);
                      final percentage = double.parse(
                          (item.value / total * 100).toStringAsFixed(2));
                      print('percentage: $percentage');
                      return PieChartSectionData(
                        color: item.color,
                        value: percentage,
                        showTitle: false,
                        radius: 90,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        // 外部标签（带延伸线）
                        badgeWidget: _buildLegendItem(item),
                        badgePositionPercentageOffset: 1.2, // 标签位置（1.0 = 边缘）
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    IconFont.biaoqing1,
                    size: 100,
                    color: Color(0XFF292929),
                  ),
                  Container(
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFBFBFBF),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      color: const Color(0xFFF8F8F8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 16.8,
                          offset: Offset(2.265, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 11.324,
                          sigmaY: 11.324,
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(18),
                          children: const [
                            Text('微量元素含量',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black)),
                            Text('膳食纤维：0mg',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF868686))),
                            Text('膳食纤维：0mg',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF868686))),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              // // 词云块
              // RandomWordCloud(words: words),
              const SizedBox(height: 30),
              _buildWhiteListCard(), // 添加本餐
              const SizedBox(height: 30),
              _buildNutrientAnalysisCard(),
              const SizedBox(height: 30),
              _buildHealthAdviceCard(),
              const SizedBox(height: 30),
              _buildDietSuggestionCard(),
              const SizedBox(height: 30),
              _buildDietSuggestionCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientAnalysisCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '均衡度：',
                style: TextStyle(fontSize: 16, color: text2Color),
              ),
              Text(
                '优质蛋白：',
                style: TextStyle(fontSize: 16, color: text2Color),
              ),
              Text(
                '膳食纤维情况：',
                style: TextStyle(fontSize: 16, color: text2Color),
              ),
              Text(
                '微量元素情况：',
                style: TextStyle(fontSize: 16, color: text2Color),
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey),
              SizedBox(height: 10),
              // 第二部分：图片展示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFoodImage('assets/images/egg.jpeg'),
                  _buildFoodImage('assets/images/egg.jpeg'),
                  _buildFoodImage('assets/images/egg.jpeg'),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '低GI的',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF595959)),
                  )
                ],
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey),
              SizedBox(height: 10),
              // 第二部分：图片展示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFoodImage('assets/images/egg.jpeg'),
                  _buildFoodImage('assets/images/egg.jpeg'),
                  _buildFoodImage('assets/images/egg.jpeg'),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '提高免疫力的',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF595959)),
                  )
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          left: 10,
          child: Container(
            padding: EdgeInsets.only(left: 18, right: 18),
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Text(
                  '营养分析',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthAdviceCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(color: Colors.grey),
              SizedBox(height: 10),
              // 第二部分：图片展示
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(IconFont.meirongyangyanjianyi, size: 30),
                  Text(
                    '皮肤美容',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: text2Color),
                  )
                ],
              ),
              SizedBox(height: 10),
              CommonCard(
                  imagePath: 'assets/images/egg.jpeg',
                  statusIcon: Icon(IconFont.daohanglan),
                  title: '小雨A',
                  subtitle: '详细信息啊啊啊啊啊',
                  text2Color: text2Color),
              CommonCard(
                  imagePath: 'assets/images/egg.jpeg',
                  statusIcon: Icon(IconFont.daohanglan),
                  title: '小雨A',
                  subtitle: '详细信息啊啊啊啊啊',
                  text2Color: text2Color),
              SizedBox(height: 10),
              Divider(color: Colors.grey),
              SizedBox(height: 10),
              // 第二部分：图片展示
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(IconFont.meirongyangyanjianyi, size: 30),
                  Text(
                    '皮肤美容',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: text2Color),
                  )
                ],
              ),
              SizedBox(height: 10),
              CommonCard(
                  imagePath: 'assets/images/egg.jpeg',
                  statusIcon: Icon(IconFont.daohanglan),
                  title: '小雨A',
                  subtitle: '详细信息啊啊啊啊啊',
                  text2Color: text2Color),
              CommonCard(
                  imagePath: 'assets/images/egg.jpeg',
                  statusIcon: Icon(IconFont.daohanglan),
                  title: '小雨A',
                  subtitle: '详细信息啊啊啊啊啊',
                  text2Color: text2Color),
              SizedBox(height: 10),
              //这里需要加一个血糖mmol/l的的echart面积图，
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Color(0XFFFAFAFA),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.07),
                      offset: Offset(2.26, 4.53),
                      blurRadius: 2.06,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: false,
                    ),
                    titlesData: FlTitlesData(
                      show: false,
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    minX: 0,
                    maxX: (glucoseData.length - 1).toDouble(),
                    minY: 3,
                    maxY: 10,
                    lineBarsData: [
                      LineChartBarData(
                        spots: glucoseData
                            .asMap()
                            .entries
                            .map((entry) => FlSpot(
                                  entry.key.toDouble(),
                                  entry.value.value,
                                ))
                            .toList(),
                        isCurved: true,
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(255, 128, 44, 1),
                            Color.fromRGBO(255, 128, 44, 0)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFFF6B81).withOpacity(0.2),
                              Color(0xFFFFA07A).withOpacity(0.2)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (FlSpot spot, double xPercentage,
                              LineChartBarData bar, int index) {
                            // 仅在最顶点显示数字
                            if (index == glucoseData.length - 5) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Color.fromRGBO(255, 128, 44, 1),
                                strokeWidth: 0,
                                strokeColor: Colors.transparent,
                              );
                            }
                            return FlDotCirclePainter(
                              radius: 0,
                              color: Colors.transparent,
                              strokeWidth: 0,
                              strokeColor: Colors.transparent,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(color: Colors.grey),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(IconFont.meirongyangyanjianyi, size: 30),
                  Text(
                    '皮肤美容',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: text2Color),
                  )
                ],
              ),
              SizedBox(height: 10),
              CommonCard(
                  imagePath: 'assets/images/egg.jpeg',
                  statusIcon: Icon(IconFont.daohanglan),
                  title: '小雨A',
                  subtitle: '详细信息啊啊啊啊啊',
                  text2Color: text2Color),
              CommonCard(
                  imagePath: 'assets/images/egg.jpeg',
                  statusIcon: Icon(IconFont.daohanglan),
                  title: '小雨A',
                  subtitle: '详细信息啊啊啊啊啊',
                  text2Color: text2Color),
              SizedBox(height: 10),
              Divider(color: Colors.grey),
              SizedBox(height: 10),
              // 第二部分：图片展示
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(IconFont.meirongyangyanjianyi, size: 30),
                  Text(
                    '皮肤美容',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: text2Color),
                  )
                ],
              ),
              SizedBox(height: 10),
              CommonCard(
                  imagePath: 'assets/images/egg.jpeg',
                  statusIcon: Icon(IconFont.daohanglan),
                  title: '小雨A',
                  subtitle: '详细信息啊啊啊啊啊',
                  text2Color: text2Color),
              CommonCard(
                  imagePath: 'assets/images/egg.jpeg',
                  statusIcon: Icon(IconFont.daohanglan),
                  title: '小雨A',
                  subtitle: '详细信息啊啊啊啊啊',
                  text2Color: text2Color),
            ],
          ),
        ),
        Positioned(
          top: -20,
          left: 10,
          child: Container(
            padding: EdgeInsets.only(left: 18, right: 18),
            decoration: BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '健康建议：',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                Text(
                  '哪些食物需注意',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: text2Color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodImage(String imagePath) {
    return Container(
      width: 80,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildLegendItem(NutrientData item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(4),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.1),
      //       blurRadius: 2,
      //       offset: const Offset(0, 1),
      //     ),
      //   ],
      // ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Text(
                '${item.value}％',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  //tabs
  Widget _buildTabs() {
    return DefaultTabController(
      // initialIndex: 0, // 默认选中第一个Tab
      length: 4,
      child: Container(
        width: 280,
        height: 32,
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Align(
            alignment: Alignment.centerLeft, // 左对齐
            child: TabBar(
              isScrollable: false,
              labelPadding: EdgeInsets.zero,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Color.fromRGBO(23, 23, 23, 0.6),
              tabs: const [
                SizedBox(
                  width: 50,
                  height: 24,
                  child: Tab(text: '早餐'),
                ),
                SizedBox(
                  width: 50,
                  height: 24,
                  child: Tab(text: '午餐'),
                ),
                SizedBox(
                  width: 50,
                  height: 24,
                  child: Tab(text: '晚餐'),
                ),
                SizedBox(
                  width: 50,
                  height: 24,
                  child: Tab(text: '加餐'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKcalCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧分数组件（模拟ScoreCircle）
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScoreCircle(score: totalScore),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Text(
                  '保持得很牛，加油呀！',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10),
        // 右侧竖向卡路里块（基于_buildCalorieBlock逻辑）
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 第一个块：黑色背景 + 图标 + 文字
              Container(
                width: 200,
                height: 50,
                margin: EdgeInsets.only(top: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black, // 黑色背景
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconFont.yisheruzhi,
                        color: Color(0xFFEA7B3C), // 橙色图标
                        size: 28,
                      ),
                      SizedBox(width: 6),
                      Text(
                        totalCal,
                        style: TextStyle(
                            color: Color(0xFFEA7B3C), // 橙色文字
                            fontSize: 30),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              // 第二个块：白色背景 + 虚线边框 + 文字
              Container(
                width: 120,
                height: 45,
                margin: EdgeInsets.all(1), // 微小边距创造分隔效果
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color.fromARGB(255, 241, 241, 241), // 白色虚线边框
                    width: 1,
                  ),
                  color: Colors.white,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconFont.chifanshijiansudu,
                        color: Color(0xFF777777),
                        size: 26,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '32min',
                        style:
                            TextStyle(color: Color(0xFF777777), fontSize: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //摄入时间
  // Widget _buildCalorieBlock() {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       final blockWidth = constraints.maxWidth * 0.9; // 使用90%的可用宽度
  //       return Container(
  //         width: blockWidth,
  //         height: 66,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         child: Row(
  //           children: [
  //             // 左侧刀叉和卡路里
  //             Container(
  //               width: blockWidth * 0.6, // 左侧占50%
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(16),
  //                 color: Color(0xFFD8D1CF),
  //               ),
  //               child: Center(
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     const Icon(
  //                       IconFont.yisheruzhi,
  //                       color: Color(0xFFEA7B3C),
  //                       size: 36,
  //                     ),
  //                     const SizedBox(width: 5),
  //                     Flexible(
  //                       child: Text(
  //                         '本次摄入400kcal',
  //                         style: TextStyle(
  //                           fontWeight: FontWeight.bold,
  //                           color: Color(0xFFEA7B3C),
  //                         ),
  //                         overflow: TextOverflow.ellipsis,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             // 右侧时间
  //             Expanded(
  //               child: Container(
  //                 margin: const EdgeInsets.only(left: 10),
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(16),
  //                   color: Color(0xFF373737),
  //                 ),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     const Icon(Icons.access_time, color: Color(0xFFEA7B3C)),
  //                     Text(
  //                       '32min',
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         color: Color(0xFFEA7B3C),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // //营养成分分析
  // Widget _buildNutritionAnalysis(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFEFECEB),
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // 标题行
  //         Row(
  //           children: [
  //             const Icon(IconFont.fenxitongji, size: 20),
  //             const SizedBox(width: 5),
  //             Text(
  //               '营养成分分析',
  //               style: TextStyle(
  //                 fontWeight: FontWeight.w800,
  //                 fontSize: 16,
  //               ),
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 16),
  //         // 第一组柱状图
  //         _buildNutrientBars(context, {
  //           '碳水': 10,
  //           '蛋白质': 10,
  //           '脂肪': 20
  //         }, [
  //           const Color(0xFFEA7B3C),
  //           const Color(0xFFB59E41),
  //           const Color(0xFFFF6767)
  //         ]),
  //         const SizedBox(height: 16),

  //         // 第二组柱状图
  //         _buildNutrientBars(context, {'膳食纤维': 10, '钠': 50},
  //             [const Color(0xFF4CAF50), const Color(0xFF2196F3)]),
  //         const SizedBox(height: 16),

  //         // 关键微量营养素
  //         Text(
  //           '关键微量营养素：',
  //           style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               fontSize: 14,
  //               color: Color.fromRGBO(115, 115, 115, 1)),
  //         ),
  //         const SizedBox(height: 8),
  //         Column(
  //           children: [
  //             _buildNutrientItem('• 维生素A：0mg'),
  //             _buildNutrientItem('• 维生素B：0mg'),
  //             _buildNutrientItem('• 维生素C：0mg'),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildNutrientBars(
  //     BuildContext context, Map<String, int> labels, List<Color> colors) {
  //   final totalWidth = MediaQuery.of(context).size.width - 100; // 减去更多padding
  //   final totalPercentage =
  //       labels.entries.map((e) => e.value).reduce((a, b) => a + b);
  //   List<MapEntry<String, int>> maplist = labels.entries.toList();
  //   return Container(
  //     height: 58,
  //     padding: EdgeInsets.all(5),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFD9D9D9),
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: SizedBox(
  //       height: 16,
  //       child: Column(
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: List.generate(maplist.length, (index) {
  //               double currentWidth = double.parse(
  //                   (maplist[index].value / totalPercentage * totalWidth)
  //                       .toStringAsFixed(2));
  //               return SizedBox(
  //                 width: currentWidth, // 每个柱状图占30%的宽度
  //                 height: 20,
  //                 child: OverflowBox(
  //                   maxWidth: double.infinity, // 允许无限宽度
  //                   alignment: Alignment.centerLeft, // 左对齐
  //                   child: Text(
  //                     '${maplist[index].key} ${maplist[index].value}g',
  //                     style: TextStyle(fontSize: 12, color: colors[index]),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ),
  //               );
  //             }),
  //             // children: labels.entries.map((label) {
  //             //   return Text(
  //             //     label.key,
  //             //     style: TextStyle(fontSize: 12),
  //             //   );
  //             // }).toList(),
  //           ),
  //           const SizedBox(height: 5),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: List.generate(maplist.length, (index) {
  //               double currentWidth = double.parse(
  //                   (maplist[index].value / totalPercentage * totalWidth)
  //                       .toStringAsFixed(2));
  //               return Container(
  //                 width: currentWidth, // 每个柱状图占30%的宽度
  //                 height: 16,
  //                 decoration: BoxDecoration(
  //                   color: colors[index],
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               );
  //             }),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildNutrientItem(String text) {
  //   return Text(
  //     text,
  //     style: TextStyle(fontSize: 12, color: Color.fromRGBO(115, 115, 115, 1)),
  //   );
  // }

  // 本餐
  Widget _buildWhiteListCard() {
    return Stack(
        clipBehavior: Clip.none, // 关键设置，允许子组件溢出
        children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFEFECEB),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: Offset(2, 2),
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(-2, -2),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SizedBox(
              height: 300, // 固定高度
              child: PageView(
                children: [
                  // 第一页：菜品列表
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 10, top: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...foods.map((food) => _buildFoodItem(food.food.name,
                            food.calories, '${food?.quantity}${food?.unit}'))
                      ],
                    ),
                  ),
                  // 第二页：全屏图片
                  Center(
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 8,
                            offset: Offset(1, 1),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Image.network(
                        mealRecordsData?.imageUrl ?? '',
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -20,
            left: 10,
            child: Container(
              padding: EdgeInsets.only(left: 18, right: 18),
              decoration: BoxDecoration(
                color: Color(0xFFEFECEB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Text(
                    '本餐',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 44,
            left: 0,
            child: Container(
              padding: EdgeInsets.only(left: 18, right: 18),
              decoration: BoxDecoration(
                color: Color(0xFFEFECEB),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomPaint(
                    size: Size(274, 4),
                    painter: _LeftArrowPainter(color: Color(0xFFEA7B3C)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '供能占比',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFEA7B3C),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]);
  }

// 构建单个菜品项
  Widget _buildFoodItem(String name, double calories, String weight) {
    String percentage =
        '${(calories / mealRecordsData!.totalCalories * 100).toStringAsFixed(0)}%';
    return Expanded(
      child: Container(
        height: 180,
        margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
        decoration: BoxDecoration(
          color: Color(0xFF000000),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: Offset(2, 2),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(-2, -2),
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none, // 关键设置，允许子组件溢出
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 菜品图片部分
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(
                      _getRandomFoodImage(),
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child:
                            Icon(Icons.fastfood, size: 40, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                // 菜品信息部分
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 5), // 调整左侧padding
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft, // 强制左对齐
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left, // 明确设置文本左对齐
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft, // 强制左对齐
                          child: Text(
                            weight,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFE5A454),
                            ),
                            textAlign: TextAlign.left, // 明确设置文本左对齐
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft, // 强制左对齐
                          child: Text(
                            '$calories',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7C7C7C),
                            ),
                            textAlign: TextAlign.left, // 明确设置文本左对齐
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 0,
              bottom: -20,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFFEA7B3C),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    percentage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// 获取随机食物图片（示例用）
  String _getRandomFoodImage() {
    final images = [
      'https://img.freepik.com/free-photo/delicious-vietnamese-food-including-pho-ga-noodles-spring-rolls_335224-895.jpg',
      'https://img.freepik.com/free-photo/top-view-table-full-delicious-food-composition_23-2149141352.jpg',
      'https://img.freepik.com/free-photo/healthy-vegetables-wooden-table_1150-38014.jpg'
    ];
    return images[DateTime.now().millisecond % images.length];
  }

  // 膳食调整建议
  Widget _buildDietSuggestionCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 20, top: 30),
          decoration: BoxDecoration(
            color: Color(0xFFEFECEB),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: Offset(2, 2),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(-2, -2),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一行三个图文结合体
              Container(
                height: 128,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSuggestionItem(
                        'https://img.freepik.com/free-photo/grilled-chicken-breast-vegetables_2829-19744.jpg',
                        Icon(IconFont.daohanglan)),
                    SizedBox(width: 5),
                    _buildSuggestionItem(
                        'https://img.freepik.com/free-photo/assortment-raw-whole-grains_23-2148892083.jpg',
                        Icon(IconFont.daohanglan)),
                    SizedBox(width: 5),
                    _buildSuggestionItem(
                        'https://img.freepik.com/free-photo/healthy-vegetables-wooden-table_1150-38014.jpg',
                        Icon(IconFont.daohanglan)),
                  ],
                ),
              ),

              // 饮食建议列表
              Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, bottom: 16, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSuggestionText('1、蛋白质：优质蛋白'),
                    _buildSuggestionText('2、碳水摄入结构失衡'),
                    _buildSuggestionText('3、膳食纤维：长期缺乏'),
                    _buildSuggestionText('4、微量营养素：Omega-3、维生素D、碘元素、钾镁钙'),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          left: 10,
          child: Container(
            padding: EdgeInsets.only(left: 18, right: 18),
            decoration: BoxDecoration(
              color: Color(0xFFEFECEB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '健康建议：',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                Text(
                  '消化分析',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: text2Color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// 构建单个建议项
  Widget _buildSuggestionItem(String imageUrl, Widget statusIcon) {
    return Flexible(
      child: Stack(children: [
        Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.fastfood, size: 40, color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Center(child: statusIcon),
          ),
        ),
      ]),
    );
  }

// 构建建议文本项
  Widget _buildSuggestionText(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          height: 1.25, // 行高20/16=1.25
          color: Color(0xFF737373),
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  // 通用文案卡片
  Widget _buildTextCard({
    required String title,
    required List<String> content,
    required IconData icon,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Color(0xFFEFECEB),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: Offset(2, 2),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(-2, -2),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题
              Padding(
                padding: EdgeInsets.only(left: 70, top: 12, bottom: 8),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    Container(
                      height: 2,
                      width: 100,
                      margin: EdgeInsets.only(top: 4),
                      color: titleColor,
                    ),
                  ],
                ),
              ),

              // 内容区域
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 16,
                  top: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content
                      .map((text) => _buildSuggestionText(text))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -20,
          left: 10,
          child: Icon(
            icon,
            size: 60,
            color: const Color.fromARGB(255, 4, 160, 56),
          ),
        ),
      ],
    );
  }
}

// 评分圆形组件
class ScoreCircle extends StatelessWidget {
  final num score;

  const ScoreCircle({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 60,
      child: RichText(
        textAlign: TextAlign.left,
        textScaler: TextScaler.noScaling,
        overflow: TextOverflow.clip,
        text: TextSpan(
          style: const TextStyle(
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          children: [
            WidgetSpan(
              child: Stack(
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(fontSize: 40, color: Colors.black),
                  ),
                  Positioned(
                    right: 0,
                    top: 15,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA7B3C),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TextSpan(
              text: '分',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NutrientData {
  final String name;
  final num value;
  final Color color;

  NutrientData({
    required this.name,
    required this.value,
    required this.color,
  });
}
