import 'package:flutter/material.dart';

class MenuPage extends StatefulWidget {
  final String category; // 菜单类别：蔬菜、肉类、碳水

  const MenuPage({Key? key, required this.category}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late PageController _pageController;
  double _currentPage = 0;
  final double _viewportFraction = 0.2; // 减小视口比例，使页面同时显示5个菜品
  final int _actualItemCount = 10; // 实际菜品数量

  // 根据类别获取对应的标签列表
  List<String> getTags() {
    switch (widget.category) {
      case '肉类':
        return ['猪肉', '牛肉', '鸡肉', '羊肉', '鸭肉', '鱼肉', '虾', '蟹'];
      case '蔬菜':
        return ['叶菜类', '根茎类', '瓜果类', '菌菇类', '豆类', '薯类'];
      case '碳水':
        return ['米饭', '面食', '馒头', '面包', '土豆', '红薯', '玉米'];
      default:
        return ['全部'];
    }
  }

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
    // 设置初始页面为一个较大值的中间位置，这样用户可以向上或向下滚动
    int initialPage = 5000; // 从中间开始，这样可以向两个方向滚动
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
            // 1. 后退按钮
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 16.0),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // 2. 标题文本
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 8.0),
              child: Text(
                '今天吃什么${widget.category}？',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // 3. 水平滚动的标签列表
            Container(
              height: 32, // 32px高度 + 上下padding
              margin: EdgeInsets.only(top: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Container(
                      height: 32,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Color(0xFFEAEAEA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          tags[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 4. 风扇页动画效果的列表 - 竖向旋转，圆心在左侧外部
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 20.0),
                child: PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  itemCount: 10000,
                  padEnds: false,
                  itemBuilder: (context, index) {
                    final actualIndex = index % _actualItemCount;
                    double value = (index - _currentPage);

                    return Transform(
                      // 调整变换原点位置（更靠近左侧）
                      alignment: Alignment(-1.5, -1.0), // 从-3.0调整为-1.5
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002) // 增强透视效果
                        ..rotateX(value * 0.03) // 减小X轴旋转
                        ..rotateZ(value * 0.1), // 减小Z轴旋转角度
                      child: Container(
                        width: 300,
                        height: 140,
                        // 减小垂直间距（从10.0调为5.0）
                        margin: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 5.0, // 调整这里
                        ),
                        decoration: BoxDecoration(
                          color: getColorForIndex(actualIndex),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '菜品 ${actualIndex + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
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
}
