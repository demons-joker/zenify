import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zenify/models/enums.dart';
import 'package:zenify/services/recognition_report_service.dart';

class MealAnalysisReport extends StatefulWidget {
  final String image;
  final String title;
  final String tag; // 'Balanced' or 'Unbalanced'
  final List<dynamic> foods; // 食物列表
  final Map<String, dynamic>? recordData;

  const MealAnalysisReport({
    super.key,
    required this.image,
    required this.title,
    required this.tag,
    required this.foods,
    this.recordData,
  });

  @override
  State<MealAnalysisReport> createState() => _MealAnalysisReportState();
}

class _MealAnalysisReportState extends State<MealAnalysisReport> {
  List<dynamic> get _effectiveFoods {
    if (widget.foods.isNotEmpty) {
      return widget.foods;
    }
    return RecognitionReportService.resolveFoods(widget.recordData);
  }

  String get _effectiveImage {
    if (widget.image.isNotEmpty) {
      return widget.image;
    }
    return widget.recordData?['image_url']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景图片（完全覆盖整个页面，可以超出）
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: _effectiveImage,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFF454A30),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 100,
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF454A30),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),
          ),

          // 黑色70%蒙版
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(214, 0, 0, 0), // 黑色70%透明度
            ),
          ),

          // 内容区域
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  // 顶部Banner区域
                  _buildTopHeader(),

                  // 内容区域
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          // 第一行内容区域：高度165
                          _buildFirstRow(),
                          const SizedBox(height: 24),
                          // 第二行内容区域：2*N宫格列表
                          _buildFoodGrid(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 顶部Banner
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 回退按钮
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFFC8C8C8),
              size: 24,
            ),
          ),

          // 中间文案
          Expanded(
            child: Text(
              'Analysis Result',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFC8C8C8),
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 24 / 18, // line-height 24px
              ),
            ),
          ),

          // 占位，保持文字居中
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  /// 第一行内容区域：高度165
  Widget _buildFirstRow() {
    return Container(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左边：显示card的图片
          _buildLeftImage(),

          const SizedBox(width: 10),

          // 右边：tag和提示信息
          Expanded(
            child: _buildRightContent(),
          ),
        ],
      ),
    );
  }

  /// 左边图片
  Widget _buildLeftImage() {
    return Container(
      width: 120,
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: _effectiveImage,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.restaurant,
              size: 32,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(
              Icons.restaurant,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  /// 右边内容：tag和提示信息
  Widget _buildRightContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 第一行：tag
          _buildTag(),

          // 第二行：提示信息
          _buildTips(),
        ],
      ),
    );
  }

  /// Tag样式
  Widget _buildTag() {
    final isBalanced = widget.tag == 'Balanced';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isBalanced ? const Color(0xFFE1EC7C) : const Color(0xFFFFB596),
        borderRadius: BorderRadius.circular(90),
      ),
      child: Text(
        widget.tag,
        style: TextStyle(
          color: isBalanced ? const Color(0xFF747474) : const Color(0xFFC0613A),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// 提示信息
  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: const Text(
        'Tips:  👊\nPortion sizes are based on the volume of cooked food—your fist is a simple visual guide.',
        style: TextStyle(
          color: Color(0xFFAFAFAF),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// 第二行内容区域：2*N宫格列表
  Widget _buildFoodGrid() {
    final groupedFoods = _groupFoodsByCategory();

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        children: [
          // 第一行：固定标题
          _buildGridHeader(),
          const SizedBox(height: 8),
          // 数据行
          ...groupedFoods.entries.map((entry) => _buildFoodRow(
                category: entry.key,
                foods: entry.value,
              )),
        ],
      ),
    );
  }

  /// 网格标题行
  Widget _buildGridHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.white,
                    width: 0.5,
                  ),
                ),
              ),
              child: const Text(
                'Recommended eating sequence',
                style: TextStyle(
                  color: Color(0xFFC8C8C8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: const Text(
                'Recommended intake',
                style: TextStyle(
                    color: Color(0xFFC8C8C8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 食物数据行
  Widget _buildFoodRow({
    required FoodCategory category,
    required List<Map<String, dynamic>> foods,
  }) {
    // 计算该分类需要显示的内容
    String? secondColumnContent;
    if (category == FoodCategory.vegetable ||
        category == FoodCategory.protein ||
        category == FoodCategory.carbohydrate) {
      // 显示拳头符号
      final fistCount = category == FoodCategory.vegetable ? 2 : 1;
      secondColumnContent = List.generate(fistCount, (index) => '👊').join('');
    } else if (category == FoodCategory.fruit) {
      secondColumnContent = 'good';
    } else if (category == FoodCategory.fat || category == FoodCategory.other) {
      secondColumnContent = 'little';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 第一列：食材名称
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.white,
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: foods.map((foodData) {
                  final food = foodData['food'] as Map<String, dynamic>?;
                  final name = food?['name_en'] as String? ?? 'Unknown';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFFC8C8C8),
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // 第二列：内容
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: secondColumnContent != null
                    ? Text(
                        secondColumnContent,
                        style: const TextStyle(fontSize: 16),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 按照指定顺序分组食材
  Map<FoodCategory, List<Map<String, dynamic>>> _groupFoodsByCategory() {
    final order = [
      FoodCategory.vegetable,
      FoodCategory.protein,
      FoodCategory.carbohydrate,
      FoodCategory.fruit,
      FoodCategory.fat,
      FoodCategory.other,
    ];

    final Map<FoodCategory, List<Map<String, dynamic>>> grouped = {};

    // 初始化所有分类
    for (final category in order) {
      grouped[category] = [];
    }

    // 分组食材
    for (final foodData in _effectiveFoods) {
      final food = foodData['food'] as Map<String, dynamic>?;
      final categoryStr = food?['category'] as String?;

      if (categoryStr != null) {
        final category = FoodCategoryExtension.fromString(categoryStr);

        if (category != null && grouped.containsKey(category)) {
          grouped[category]!.add(foodData as Map<String, dynamic>);
        }
      }
    }

    // 移除空分类
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }
}
