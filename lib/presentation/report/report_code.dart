import 'package:flutter/material.dart';
import '../../services/api.dart';
import '../../core/app_export.dart';

class ReportCodePage extends StatefulWidget {
  const ReportCodePage({super.key});

  @override
  State<ReportCodePage> createState() => _ReportCodePageState();
}

class _ReportCodePageState extends State<ReportCodePage> {
  Map<String, dynamic>? _recognitionData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecognitionData();
  }

  /// 加载最新识别数据，和 report_detail.dart 中的方式一致
  Future<void> _loadRecognitionData() async {
    try {
      final data = await Api.getLatestRecognition();
      if (mounted) {
        setState(() {
          _recognitionData = data;
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12.h),
                  _buildMealSummary(),
                  SizedBox(height: 16.h),
                  _buildNutritionBreakdown(),
                  SizedBox(height: 16.h),
                  _buildFoodItems(),
                  SizedBox(height: 16.h),
                  _buildHealthTags(),
                  SizedBox(height: 16.h),
                  _buildProfessionalAdvice(),
                  SizedBox(height: 60.h), // 底部导航栏空间
                ],
              ),
            ),
    );
  }

  Widget _buildMealSummary() {
    if (_recognitionData == null) return const SizedBox.shrink();

    final nutritionAnalysis =
        _recognitionData!['nutrition_analysis'] as Map? ?? {};
    final mealScore =
        (nutritionAnalysis['meal_score'] as num?)?.toDouble() ?? 0.0;
    final score = mealScore * 10; // 转换为0-100分

    return Container(
      height: 90.h, // 降低卡片高度
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(10.h),
        child: Row(
          children: [
            // 左侧图标区域
            Container(
              width: 70.h,
              height: 70.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.h),
                color: Colors.grey[200],
              ),
              child: Icon(
                Icons.restaurant,
                color: Colors.grey[600],
                size: 28.h,
              ),
            ),
            SizedBox(width: 8.h),
            // 右侧内容区域
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    score.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 36.fSize,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0B0B0B),
                    ),
                  ),
                  Text(
                    'Meal Score',
                    style: TextStyle(
                      fontSize: 12.fSize,
                      color: const Color(0xFF747474),
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

  Widget _buildNutritionBreakdown() {
    if (_recognitionData == null) return const SizedBox.shrink();

    final nutritiveProportion =
        _recognitionData!['nutritive_proportion'] as Map? ?? {};
    final carb =
        (nutritiveProportion['carbohydrate'] as num?)?.toDouble() ?? 0.0;
    final protein = (nutritiveProportion['protein'] as num?)?.toDouble() ?? 0.0;
    final fat = (nutritiveProportion['fat'] as num?)?.toDouble() ?? 0.0;
    final fiber = (nutritiveProportion['fiber'] as num?)?.toDouble() ?? 0.0;

    // 计算百分比（简化计算）
    final total = carb + protein + fat + fiber;
    final carbPercent = total > 0 ? (carb / total) * 100 : 0;
    final proteinPercent = total > 0 ? (protein / total) * 100 : 0;
    final fatPercent = total > 0 ? (fat / total) * 100 : 0;
    final fiberPercent = total > 0 ? (fiber / total) * 100 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition Balance',
          style: TextStyle(
            color: const Color(0xFF0B0B0B),
            fontSize: 20.fSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(12.h),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNutrientCard('${carbPercent.toStringAsFixed(1)}g', 'Carbs',
                  carbPercent / 100),
              _buildNutrientCard('${proteinPercent.toStringAsFixed(1)}g',
                  'Protein', proteinPercent / 100),
              _buildNutrientCard(
                  '${fatPercent.toStringAsFixed(1)}g', 'Fat', fatPercent / 100),
              _buildNutrientCard('${fiberPercent.toStringAsFixed(1)}g', 'Fiber',
                  fiberPercent / 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientCard(String value, String label, double progress) {
    Color getProgressColor(String nutrientLabel) {
      switch (nutrientLabel.toLowerCase()) {
        case 'carbs':
        case '碳水化合物':
          return const Color(0xFF9D4300); // 橙色
        case 'protein':
        case '蛋白质':
          return const Color(0xFF006C49); // 绿色
        case 'fat':
        case '脂肪':
          return const Color(0xFF005AC2); // 蓝色
        case 'fiber':
        case '纤维':
          return const Color(0xFF31C98F); // 浅绿色
        default:
          return const Color(0xFF747474); // 默认灰色
      }
    }

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.h),
        padding: EdgeInsets.all(6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFC),
          borderRadius: BorderRadius.circular(6.h),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14.fSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0B0B0B),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.fSize,
                color: const Color(0xFF747474),
              ),
            ),
            SizedBox(height: 6.h),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE0E3E5),
              valueColor: AlwaysStoppedAnimation<Color>(getProgressColor(label)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItems() {
    if (_recognitionData == null) return const SizedBox.shrink();

    final foods = _recognitionData!['foods'] as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Components',
          style: TextStyle(
            color: const Color(0xFF0B0B0B),
            fontSize: 20.fSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        ...foods.asMap().entries.map((entry) {
          final index = entry.key;
          final foodItem = entry.value;
          final food = foodItem['food'] as Map? ?? {};
          final name = food['name'] as String? ?? '';
          final quantity = foodItem['quantity'] as num? ?? 0;
          final unit = foodItem['unit'] as String? ?? 'g';
          final imageUrl = food['image_url'] as String? ?? '';

          return Padding(
            padding: EdgeInsets.only(bottom: index < foods.length - 1 ? 12.h : 0),
            child: Container(
              height: 90.h, // 降低卡片高度
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(12.h),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10.h),
                child: Row(
                  children: [
                    // 左边正方形图片
                    Container(
                      width: 70.h,
                      height: 70.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.h),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.h),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.restaurant,
                                    color: Colors.grey[600],
                                    size: 28.h,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.restaurant,
                                color: Colors.grey[600],
                                size: 28.h,
                              ),
                      ),
                    ),
                    SizedBox(width: 8.h),
                    // 右边内容区域
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: const Color(0xFF0B0B0B),
                              fontSize: 14.fSize,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            '${quantity.toStringAsFixed(0)} $unit',
                            style: TextStyle(
                              color: const Color(0xFF747474),
                              fontSize: 12.fSize,
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
        }),
      ],
    );
  }

  Widget _buildHealthTags() {
    if (_recognitionData == null) return const SizedBox.shrink();

    final nutritionAnalysis =
        _recognitionData!['nutrition_analysis'] as Map? ?? {};
    final tags = <String>[];

    if ((nutritionAnalysis['high_quality_protein'] as List?)?.isNotEmpty ??
        false) {
      tags.add('High Quality Protein');
    }
    if ((nutritionAnalysis['high_fiber'] as List?)?.isNotEmpty ?? false) {
      tags.add('High Fiber');
    }
    if ((nutritionAnalysis['low_gi'] as List?)?.isNotEmpty ?? false) {
      tags.add('Low GI');
    }
    if ((nutritionAnalysis['immunity_boosting'] as List?)?.isNotEmpty ??
        false) {
      tags.add('Immunity Boosting');
    }
    if ((nutritionAnalysis['antioxidant'] as List?)?.isNotEmpty ?? false) {
      tags.add('Antioxidant');
    }
    if ((nutritionAnalysis['calcium_rich'] as List?)?.isNotEmpty ?? false) {
      tags.add('Calcium Rich');
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags
          .map((tag) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _getTagColor(tag).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: _getTagColor(tag).withValues(alpha: 0.2)),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11.fSize,
                    fontWeight: FontWeight.w600,
                    color: _getTagColor(tag),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag) {
      case 'High Quality Protein':
        return const Color(0xFF006C49);
      case 'High Fiber':
        return const Color(0xFF9D4300);
      case 'Low GI':
        return const Color(0xFF005AC2);
      case 'Immunity Boosting':
        return const Color(0xFF31C98F);
      case 'Antioxidant':
        return const Color(0xFFFD761A);
      case 'Calcium Rich':
        return const Color(0xFFD8E2FF);
      default:
        return const Color(0xFF6E7A6E);
    }
  }

  Widget _buildProfessionalAdvice() {
    if (_recognitionData == null) return const SizedBox.shrink();

    final healthTips = _recognitionData!['health_tips'] as Map? ?? {};

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The Curator\'s Advice',
            style: TextStyle(
              fontSize: 16.fSize,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0B0B0B),
            ),
          ),
          const Divider(color: Color(0xFFE0E3E5)),
          const SizedBox(height: 12),
          _buildAdviceItem(
            Icons.directions_run,
            'Post-meal Exercise',
            healthTips['post_meal_exercise'] as String? ?? '',
          ),
          const SizedBox(height: 8),
          _buildAdviceItem(
            Icons.restaurant,
            'Dietary Suggestions',
            healthTips['dietary_suggestions'] as String? ?? '',
          ),
          const SizedBox(height: 8),
          _buildAdviceItem(
            Icons.access_time,
            'Digestion Note',
            healthTips['digestion_note'] as String? ?? '',
          ),
          const SizedBox(height: 8),
          _buildAdviceItem(
            Icons.kitchen,
            'Cooking Method Advice',
            healthTips['cooking_method_advice'] as String? ?? '',
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceItem(IconData icon, String title, String content) {
    Color getAdviceColor(String adviceTitle) {
      switch (adviceTitle.toLowerCase()) {
        case 'post-meal exercise':
        case '餐后运动':
          return const Color(0xFF31C98F); // 运动 - 浅绿色
        case 'dietary suggestions':
        case '饮食建议':
          return const Color(0xFF9D4300); // 饮食 - 橙色
        case 'digestion note':
        case '消化提示':
          return const Color(0xFF005AC2); // 消化 - 蓝色
        case 'cooking method advice':
        case '烹饪方法建议':
          return const Color(0xFF006C49); // 烹饪 - 绿色
        default:
          return const Color(0xFF747474); // 默认灰色
      }
    }

    final iconColor = getAdviceColor(title);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.fSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0B0B0B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14.fSize,
                  color: const Color(0xFF747474),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
