import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  final String category;
  final List<dynamic> recipeFoods;

  const MenuPage({
    Key? key,
    required this.category,
    required this.recipeFoods,
  }) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late PageController _pageController;
  double _currentPage = 0;
  final double _viewportFraction = 0.2; // 减小视口比例，使页面同时显示5个菜品
  final int _actualItemCount = 10; // 实际菜品数量

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
    int initialPage = 5000;
    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction: _viewportFraction,
    );
    _currentPage = initialPage.toDouble();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Back button and title row
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, top: 16.0, right: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      '${widget.category}菜单',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),

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
                      selected: false,
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
                        // Handle tag selection
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
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  itemCount: widget.recipeFoods.isEmpty ? 1 : 10000,
                  padEnds: false,
                  itemBuilder: (context, index) {
                    if (widget.recipeFoods.isEmpty) {
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

                    final actualIndex = widget.recipeFoods.isEmpty
                        ? 0
                        : index % widget.recipeFoods.length;
                    final foodItem = widget.recipeFoods.isEmpty
                        ? {
                            'name': '示例菜品',
                            'image_url': null,
                            'quantity': 100,
                            'unit': 'g',
                            'category': '示例'
                          }
                        : widget.recipeFoods[actualIndex];
                    final food = foodItem ?? {};
                    double value = (index - _currentPage);
                    print('${widget.recipeFoods}');

                    // Extract food data with null checks
                    final foodName = food['name'] ?? '未知菜品';
                    final imageUrl = food['image_url'];
                    // final quantity = foodItem['quantity']?.toString() ?? '1';
                    // final unit = foodItem['unit']?.toString() ?? '份';
                    // final category = food['category'] ?? '其他';
                    // final calories = food['nutritional_info_json'] != null
                    //     ? '${_parseCalories(food['nutritional_info_json'])}kcal'
                    //     : '';

                    return Transform(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    );
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
    final categories = widget.recipeFoods
        .map((rf) => rf['food']?['category']?.toString() ?? '其他')
        .toSet()
        .toList();
    return categories.isNotEmpty ? categories : ['全部'];
  }

  int _parseCalories(String? nutritionalInfo) {
    try {
      if (nutritionalInfo == null) return 0;
      final data = nutritionalInfo is String ? nutritionalInfo : '';
      // Simple parsing - adjust according to your actual nutritional_info_json structure
      return int.tryParse(data) ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
