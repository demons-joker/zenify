import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/recognition_report_service.dart';

class ReportDetailPage extends StatefulWidget {
  const ReportDetailPage({super.key});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _DashedLine extends StatelessWidget {
  final double height;
  final Color color;
  const _DashedLine({this.height = 1.0, this.color = const Color(0xFFBDBDBD)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, height),
          painter: _DashedLinePainter(height, color),
        );
      }),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final double height;
  final Color color;
  const _DashedLinePainter(this.height, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = height
      ..strokeCap = StrokeCap.round;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double x = 0;
    final y = size.height / 2;

    while (x < size.width) {
      final endX = math.min(x + dashWidth, size.width);
      canvas.drawLine(Offset(x, y), Offset(endX, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  double fullness = 0.5;
  double taste = 0.5;
  int moodIndex = 1;

  // 识别数据
  Map<String, dynamic>? _recognitionData;
  bool _isLoading = true;

  // 计算出的营养数据
  double _totalCalories = 0;
  double _carbPercent = 0;
  double _proteinPercent = 0;
  double _fatPercent = 0;
  int _vegetableCount = 0;
  int _carbCount = 0;
  int _proteinCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRecognitionData();
  }

  /// 加载最新识别数据
  Future<void> _loadRecognitionData() async {
    try {
      final data = await RecognitionReportService.getLatestRecord();
      if (data != null && mounted) {
        setState(() {
          _recognitionData = data;
          _isLoading = false;
        });
        _calculateNutritionData(data!);
      }
    } catch (e) {
      print('加载识别数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 计算营养数据
  void _calculateNutritionData(Map<String, dynamic> data) {
    // 从 nutritive_proportion 获取营养数据
    final nutritiveProportion = data['nutritive_proportion'] as Map? ?? {};
    final totalCalories = (data['total_calories'] ?? 0) is num
        ? (data['total_calories'] as num).toDouble()
        : 0.0;

    // 获取各营养素的克数（支持 int 和 double）
    // 使用安全的类型检查和转换
    double getNumValue(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      return 0.0;
    }

    final carbGrams = getNumValue(nutritiveProportion['carbohydrate']);
    final proteinGrams = getNumValue(nutritiveProportion['protein']);
    final fatGrams = getNumValue(nutritiveProportion['fat']);

    // 计算各营养素的热量 (1g碳水/蛋白质=4kcal, 1g脂肪=9kcal)
    final carbCalories = carbGrams * 4;
    final proteinCalories = proteinGrams * 4;
    final fatCalories = fatGrams * 9;

    // 计算百分比
    _totalCalories = totalCalories;
    _carbPercent = totalCalories > 0 ? (carbCalories / totalCalories) * 100 : 0;
    _proteinPercent =
        totalCalories > 0 ? (proteinCalories / totalCalories) * 100 : 0;
    _fatPercent = totalCalories > 0 ? (fatCalories / totalCalories) * 100 : 0;

    // 统计各类食物数量
    final foods = data['foods'] as List? ?? [];
    for (var foodItem in foods) {
      // 处理 foods 中的食物项
      if (foodItem is Map) {
        // foods 可能直接是食物对象，也可能有 'food' 字段
        final food = foodItem['food'] as Map? ?? foodItem;
        final category = food['category'] as String? ?? 'other';
        if (category == 'vegetable') {
          _vegetableCount++;
        } else if (category == 'carbohydrate') {
          _carbCount++;
        } else if (category == 'protein') {
          _proteinCount++;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 8),
                    _buildDietaryStructureCard(),
                    const SizedBox(height: 20),
                    _buildNutritionDetailsCard(),
                    const SizedBox(height: 20),
                    _buildSliderCard('How full are you?', fullness,
                        (v) => setState(() => fullness = v)),
                    const SizedBox(height: 12),
                    _buildSliderCard('Do you like the taste?', taste,
                        (v) => setState(() => taste = v)),
                    const SizedBox(height: 12),
                    _buildMoodSelector(),
                    const SizedBox(height: 24),
                    Center(
                        child: Text('-END-',
                            style: TextStyle(color: Colors.grey[400]))),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    if (_recognitionData == null) {
      return SizedBox.shrink();
    }

    // 从 start_time 解析日期
    final startTime = _recognitionData!['start_time'] as String? ?? '';
    DateTime? dateTime;
    try {
      dateTime = DateTime.parse(startTime);
    } catch (e) {
      dateTime = DateTime.now();
    }

    // 计算评分（简单示例，可以根据实际需求调整）
    final score = _calculateScore();

    // 格式化日期
    final monthDay = '${dateTime.month}月${dateTime.day}号';
    final weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
    final weekday =
        dateTime.weekday <= 7 ? weekdays[dateTime.weekday - 1] : '星期日';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('${score.toStringAsFixed(0)}',
                style:
                    const TextStyle(fontSize: 44, fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Point', style: TextStyle(fontSize: 12)),
              ],
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(monthDay,
                style: const TextStyle(fontSize: 14, color: Colors.black54)),
            Text(weekday,
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
          ],
        )
      ],
    );
  }

  /// 计算评分
  double _calculateScore() {
    // 优先使用后端 AI 分析的评分
    final nutritionAnalysis =
        _recognitionData?['nutrition_analysis'] as Map? ?? {};
    if (nutritionAnalysis.containsKey('meal_score')) {
      return ((nutritionAnalysis['meal_score'] as num?)?.toDouble() ?? 0) * 10;
    }

    // 如果后端没有评分，使用本地算法
    final foodCount = _vegetableCount + _carbCount + _proteinCount;
    if (foodCount == 0) return 0;

    // 营养均衡度（接近目标比例得分更高）
    final targetVegetable = 40.0;
    final currentVegetable = _carbPercent;
    final balanceScore = 100 - ((currentVegetable - targetVegetable).abs() * 2);

    // 食物种类加分
    final varietyScore = (foodCount >= 3) ? 20 : (foodCount * 6);

    final finalScore = (balanceScore * 0.8) + varietyScore;
    return finalScore.clamp(0, 100);
  }

  /// 计算用餐时间
  int _calculateEatTime() {
    // 直接使用后端返回的用餐时长
    final durationMinutes = _recognitionData?['duration_minutes'] as int? ?? 0;
    if (durationMinutes > 0) {
      return durationMinutes;
    }

    // 备用方案：根据食物重量估算
    final totalQuantity = (_recognitionData?['foods'] as List? ?? [])
        .fold<double>(
            0, (sum, item) => sum + ((item['quantity'] ?? 0) as double));
    // 每300g约5分钟
    return ((totalQuantity / 300) * 5).round();
  }

  Widget _buildDietaryStructureCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(2, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with dashed lines on both sides and centered text
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _DashedLine(color: Color(0xFFAC8861)),
                  )),
                  Text('2:1:1 Dietary structure',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF81592C))),
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: _DashedLine(color: Color(0xFFAC8861)),
                  )),
                ],
              ),
              const SizedBox(height: 8),
              const Text('The proportions of the three main types of food',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFAC8861))),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Image.asset('assets/images/figma/report/egg_icon.png',
                    width: 36,
                    height: 36,
                    errorBuilder: (c, e, s) => const SizedBox.shrink()),
                const SizedBox(height: 8),
                Text('${_carbPercent.toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6FAF2B))),
                const SizedBox(height: 6),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: Color(0xFFADD700),
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text('Vegetables',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildMiniCard(
                      '${_proteinPercent.toStringAsFixed(0)}%',
                      'High-Carb Foods',
                      'assets/images/figma/report/meat_stroke.png',
                      Colors.redAccent)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildMiniCard(
                      '${_fatPercent.toStringAsFixed(0)}%',
                      'High-Protein Foods',
                      'assets/images/figma/report/candy_icon.png',
                      Colors.orange)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniCard(
      String percent, String title, String icon, Color color) {
    // 获取对应的食材名称
    String ingredientName = '';
    if (_recognitionData != null) {
      final nutritionAnalysis =
          _recognitionData!['nutrition_analysis'] as Map? ?? {};

      // 所有可能的分类
      final allCategories = [
        'low_gi',
        'high_fiber',
        'antioxidant',
        'calcium_rich',
        'acne_promoting',
        'immunity_boosting',
        'high_quality_protein'
      ];

      // 根据标题确定目标 category
      String? targetCategory;
      if (title == 'High-Carb Foods') {
        targetCategory = 'carbohydrate';
      } else if (title == 'High-Protein Foods') {
        targetCategory = 'protein';
      }

      // 从所有分类中查找对应 category 的食物
      if (targetCategory != null) {
        for (var categoryKey in allCategories) {
          final foods = nutritionAnalysis[categoryKey] as List? ?? [];
          final matchedFoods = foods.where((f) {
            final foodInfo = f as Map?;
            if (foodInfo == null) return false;
            final category = foodInfo['category'] as String?;
            return category == targetCategory;
          }).toList();

          if (matchedFoods.isNotEmpty) {
            if (ingredientName.isNotEmpty) {
              ingredientName += '\n';
            }
            ingredientName += matchedFoods.map((f) {
              final foodInfo = f as Map?;
              return foodInfo?['name'] as String? ?? 'Unknown';
            }).join('\n');
          }
        }
      }
    }

    return Container(
      height: 90, // 固定高度保证两个卡片一致
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(icon,
                width: 24,
                height: 24,
                errorBuilder: (c, e, s) => const SizedBox.shrink()),
            const SizedBox(width: 8),
            Text(percent,
                style: TextStyle(
                    fontSize: 18, color: color, fontWeight: FontWeight.bold))
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(90),
                ),
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
              ),
            ],
          ),
          Text(
            ingredientName.isNotEmpty ? ingredientName : '',
            style: const TextStyle(fontSize: 12, color: Color(0xFFB88C6D)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionDetailsCard() {
    // 获取营养素克数
    final nutritiveProportion =
        _recognitionData?['nutritive_proportion'] as Map? ?? {};
    double getNumValue(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      return 0.0;
    }

    final carbGrams = getNumValue(nutritiveProportion['carbohydrate']);
    final proteinGrams = getNumValue(nutritiveProportion['protein']);
    final fatGrams = getNumValue(nutritiveProportion['fat']);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(2, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _buildPill('assets/images/figma/report/egg_icon.png',
              '${_totalCalories.toStringAsFixed(0)}kcal'),
          _buildPill('assets/images/figma/report/candy_icon.png',
              '${_calculateEatTime()}min'),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: _buildNutCard('${_carbPercent.toStringAsFixed(0)}%',
                  'Carb', Colors.redAccent, carbGrams)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildNutCard('${_proteinPercent.toStringAsFixed(0)}%',
                  'Protein', Colors.orangeAccent, proteinGrams)),
          const SizedBox(width: 8),
          Expanded(
              child: _buildNutCard('${_fatPercent.toStringAsFixed(0)}%', 'Fat',
                  Colors.yellow.shade700, fatGrams)),
        ])
      ]),
    );
  }

  Widget _buildPill(String iconPath, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.black87, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        Image.asset(iconPath,
            width: 20,
            height: 20,
            color: Colors.white,
            errorBuilder: (c, e, s) => const SizedBox.shrink()),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white))
      ]),
    );
  }

  Widget _buildNutCard(
      String percent, String title, Color color, double grams) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(percent,
            style: TextStyle(
                fontSize: 18, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Color(0xFF7A5C47))),
        const SizedBox(height: 8),
        Text('${grams.toStringAsFixed(1)}g',
            style: const TextStyle(fontSize: 12, color: Color(0xFFB88C6D))),
      ]),
    );
  }

  Widget _buildSliderCard(
      String title, double value, ValueChanged<double> onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(fontSize: 16, color: Color(0xFFAB7E4B))),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFFC8FD00),
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: const Color(0xFFC8FD00),
            overlayColor: const Color(0xFFC8FD00).withOpacity(0.2),
          ),
          child: Slider(value: value, onChanged: onChanged),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
          Text('Not Full',
              style: TextStyle(fontSize: 12, color: Colors.black38)),
          Text('Just Right',
              style: TextStyle(fontSize: 12, color: Colors.black38)),
          Text('Stuffed', style: TextStyle(fontSize: 12, color: Colors.black38))
        ])
      ]),
    );
  }

  Widget _buildMoodSelector() {
    final moods = ['Sad', 'Normal', 'Happy'];
    final emojis = ['😟', '😶', '😊'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('How have you been feeling recently?',
          style: TextStyle(fontSize: 16, color: Color(0xFF7A5C47))),
      const SizedBox(height: 12),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(moods.length, (i) {
            final selected = i == moodIndex;
            return GestureDetector(
              onTap: () => setState(() => moodIndex = i),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05), blurRadius: 6)
                    ]),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(emojis[i], style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 8),
                      Text(moods[i])
                    ]),
              ),
            );
          }))
    ]);
  }
}
