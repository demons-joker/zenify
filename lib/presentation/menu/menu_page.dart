import 'package:flutter/material.dart';
import 'package:zenify/services/api.dart';

class MenuPage extends StatefulWidget {
  final String category;
  final int recipeFoodId;

  const MenuPage({
    Key? key,
    required this.category,
    required this.recipeFoodId,
  }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late PageController _pageController;
  double _currentPage = 0;
  final double _viewportFraction = 0.2; // 减小视口比例，使页面同时显示5个菜品
  String selectedTag = '全部'; // 默认选中【全部】标签
  List<dynamic> allFoods = []; // 所有食物列表（未过滤）
  List<dynamic> categoryFilteredFoods = []; // 按category筛选后的食物列表
  List<dynamic> filteredFoods = []; // 最终显示的食物列表（tag筛选后）
  bool _isLoadingFoods = true; // 是否正在加载食物数据
  // final int _actualItemCount = 10; // 实际菜品数量

  // 固定的随机颜色列表
  final List<Color> _colorList = [
    Color(0xFFFF9AA2), // 浅红色
    Color(0xFFFFB7B2), // 粉红色
    Color(0xFFFFDAC1), // 浅橙色
    Color(0xFFE2F0CB), // 浅绿色
    Color(0xFFB5EAD7), // 薄荷绿
    Color(0xFFC7CEEA), // 浅蓝色
    Color(0xFFFDFDFE), // 浅灰色
    Color(0xFFD4A5A5), // 浅棕色
    Color(0xFFF9CEDF), // 浅紫色
    Color(0xFFE0BBE4), // 淡紫色
  ];

  // 根据索引获取颜色
  Color getColorForIndex(int index) {
    return _colorList[index % _colorList.length];
  }

  @override
  void initState() {
    super.initState();
    print('category:${widget.category}');
    _loadFoods(); // 加载食物数据
    int initialPage = 500;
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: _viewportFraction,
    );
    _currentPage = initialPage.toDouble();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
      // 仅在食物数量>5时启用无限循环
      if (filteredFoods.length > 5) {
        if (_pageController.page!.round() >= filteredFoods.length - 1) {
          _pageController.jumpToPage((filteredFoods.length / 2).toInt());
        } else if (_pageController.page!.round() <= 0) {
          _pageController.jumpToPage((filteredFoods.length / 2).toInt());
        }
      }
    });
  }

  /// 加载食物数据
  Future<void> _loadFoods() async {
    try {
      setState(() {
        _isLoadingFoods = true;
      });

      // 查询所有食物，不传递category参数
      final response = await Api.getFoods(
        FoodsRequest(
          skip: 0,
          limit: 10000,
          category: widget.category, // 传null查询所有食物
        ),
      );

      print('getFoods响应: $response');

      if (mounted) {
        setState(() {
          // 解析响应数据，提取foods列表
          if (response is Map && response['foods'] is List) {
            allFoods = response['foods'];
          } else if (response is List) {
            allFoods = response;
          } else {
            allFoods = [];
          }
          categoryFilteredFoods = allFoods;

          filteredFoods = categoryFilteredFoods; // 初始显示按category筛选后的所有食物

          _isLoadingFoods = false;
        });
      }
    } catch (e) {
      print('加载食物数据失败: $e');
      if (mounted) {
        setState(() {
          filteredFoods = [];
          _isLoadingFoods = false;
        });
      }
    }
  }

  Future<void> _replacePlanFood(int foodId) async {
    print('_replacePlanFood:');
    try {
      final response = await Api.replacePlanFood(
          {'plan_food_id': widget.recipeFoodId, 'food_id': foodId});
      print('_replacePlanFood: $response');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('替换成功')),
        );
        Navigator.of(context).pop(true); // 传递 true 表示需要刷新
      }
    } catch (e) {
      print('替换计划食物失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('替换失败: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = getTags();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.category,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Tags
            Container(
              height: 40,
              margin: EdgeInsets.only(top: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: ChoiceChip(
                      label: Text(tags[index]),
                      selected: tags[index] == selectedTag,
                      selectedColor: Color(0xFFEA7B3C),
                      backgroundColor: Color(0xFFEAEAEA),
                      labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          selectedTag = tags[index];
                          // 在categoryFilteredFoods基础上进行tag筛选
                          filteredFoods = selectedTag == '全部'
                              ? categoryFilteredFoods // 显示按category筛选后的所有食物
                              : categoryFilteredFoods
                                  .where((food) =>
                                      food['subcategory']?.toString() ==
                                      selectedTag)
                                  .toList();
                          _pageController.jumpToPage(0); // 重置PageController到第一页
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // 3. Food items list
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20.0),
                child: PageView.builder(
                  key: ValueKey(filteredFoods), // 强制重建PageView（基于数据变化）
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  itemCount: filteredFoods.isEmpty
                      ? 1
                      : (filteredFoods.length < 5
                          ? filteredFoods.length
                          : 2 * filteredFoods.length),
                  padEnds: false,
                  itemBuilder: (context, index) {
                    if (filteredFoods.isEmpty) {
                      return Center(
                        child: Text(
                          '暂无菜品数据',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    final actualIndex = filteredFoods.isEmpty
                        ? 0
                        : index % filteredFoods.length;
                    final foodItem = filteredFoods.isEmpty
                        ? {
                            'name': '示例菜品',
                            'image_url': null,
                            'quantity': 100,
                            'unit': 'g',
                            'category': '示例'
                          }
                        : filteredFoods[actualIndex];
                    final food = foodItem ?? {};
                    double value = (index - _currentPage);

                    // Extract food data with null checks
                    final foodName = food['name'] ?? '未知菜品';
                    final imageUrl = food['image_url'];
                    // final quantity = foodItem['quantity']?.toString() ?? '1';
                    // final unit = foodItem['unit']?.toString() ?? '份';
                    // final category = food['category'] ?? '其他';
                    // final calories = food['nutritional_info_json'] != null
                    //     ? '${_parseCalories(food['nutritional_info_json'])}kcal'
                    //     : '';

                    return GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('确认替换'),
                              content: Text('是否替换为该食物？'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text('取消'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text('确认'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && foodItem['id'] != null) {
                            _replacePlanFood(foodItem['id']);
                          }
                        },
                        child: Transform(
                          alignment: Alignment(-1.5, -1.0),
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.002)
                            ..rotateX(value * 0.03)
                            ..rotateZ(value * 0.1),
                          child: Container(
                            width: 300,
                            height: 160, // Increased height
                            margin: EdgeInsets.symmetric(
                              horizontal: 20.0,
                              vertical: 5.0,
                            ),
                            decoration: BoxDecoration(
                              color: getColorForIndex(actualIndex),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Left side - Text content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Food name and category
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                foodName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  height: 20 / 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          children: [
                                            Text(
                                              '100g',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        // Weight and calories
                                        // Spacer(),
                                        // Brand and action buttons
                                        Row(
                                          children: [
                                            Text(
                                              '@Zenify',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Right side - Image
                                  Container(
                                    width: 90, // Increased size
                                    height: 90,
                                    margin: EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: imageUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage(imageUrl),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      color: Colors.grey[200],
                                    ),
                                    child: imageUrl == null
                                        ? Icon(Icons.fastfood,
                                            size: 40, color: Colors.grey)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> getTags() {
    final categories = allFoods
        .map((rf) => rf['subcategory']?.toString() ?? '其他')
        .toSet()
        .toList();
    return ['全部']..addAll(categories);
  }

  // int _parseCalories(String? nutritionalInfo) {
  //   try {
  //     if (nutritionalInfo == null) return 0;
  //     final data = nutritionalInfo is String ? nutritionalInfo : '';
  //     // Simple parsing - adjust according to your actual nutritional_info_json structure
  //     return int.tryParse(data) ?? 0;
  //   } catch (e) {
  //     return 0;
  //   }
  // }
}
