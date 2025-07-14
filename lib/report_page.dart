import 'package:flutter/material.dart';
import 'package:zenify/random_word_cloud.dart';
import 'package:zenify/utils/iconfont.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final words = [
      {'text': '甜食', 'highlight': true},
      {'text': '辣味', 'highlight': false},
      {'text': '海鲜', 'highlight': true},
      {'text': '素食', 'highlight': false},
      {'text': '烧烤', 'highlight': true},
      {'text': '火锅', 'highlight': false},
      {'text': '面食', 'highlight': true},
      {'text': '油炸', 'highlight': false},
      {'text': '清淡', 'highlight': false},
      {'text': '重口味', 'highlight': true},
    ];
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: Text(
                  '我的报告',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Tabs行
              _buildTabs(),

              const SizedBox(height: 20),

              // 卡路里统计块
              _buildCalorieBlock(),

              const SizedBox(height: 20),

              // 营养成分分析块
              _buildNutritionAnalysis(context),

              const SizedBox(height: 20),

              // 词云块
              RandomWordCloud(words: words),
            ],
          ),
        ),
      ),
    );
  }

  //tabs
  Widget _buildTabs() {
    return DefaultTabController(
      // initialIndex: 0, // 默认选中第一个Tab
      length: 5,
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
                  child: Tab(text: '全天'),
                ),
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

  //摄入时间
  Widget _buildCalorieBlock() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final blockWidth = constraints.maxWidth * 0.9; // 使用90%的可用宽度
        return Container(
          width: blockWidth,
          height: 66,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // 左侧刀叉和卡路里
              Container(
                width: blockWidth * 0.6, // 左侧占50%
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Color(0xFFD8D1CF),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        IconFont.yisheruzhi,
                        color: Color(0xFFEA7B3C),
                        size: 36,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '本次摄入400kcal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEA7B3C),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 右侧时间
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Color(0xFF373737),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFFEA7B3C)),
                      Text(
                        '32min',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEA7B3C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //营养成分分析
  Widget _buildNutritionAnalysis(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFECEB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(IconFont.fenxitongji, size: 20),
              const SizedBox(width: 5),
              Text(
                '营养成分分析',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 第一组柱状图
          _buildNutrientBars(context, {
            '碳水': 10,
            '蛋白质': 10,
            '脂肪': 20
          }, [
            const Color(0xFFEA7B3C),
            const Color(0xFFB59E41),
            const Color(0xFFFF6767)
          ]),
          const SizedBox(height: 16),

          // 第二组柱状图
          _buildNutrientBars(context, {'膳食纤维': 10, '钠': 50},
              [const Color(0xFF4CAF50), const Color(0xFF2196F3)]),
          const SizedBox(height: 16),

          // 关键微量营养素
          Text(
            '关键微量营养素：',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color.fromRGBO(115, 115, 115, 1)),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              _buildNutrientItem('• 维生素A：0mg'),
              _buildNutrientItem('• 维生素B：0mg'),
              _buildNutrientItem('• 维生素C：0mg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientBars(
      BuildContext context, Map<String, int> labels, List<Color> colors) {
    final totalWidth = MediaQuery.of(context).size.width - 100; // 减去更多padding
    final totalPercentage =
        labels.entries.map((e) => e.value).reduce((a, b) => a + b);
    List<MapEntry<String, int>> maplist = labels.entries.toList();
    return Container(
      height: 58,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        height: 16,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(maplist.length, (index) {
                double currentWidth = double.parse(
                    (maplist[index].value / totalPercentage * totalWidth)
                        .toStringAsFixed(2));
                return SizedBox(
                  width: currentWidth, // 每个柱状图占30%的宽度
                  height: 20,
                  child: Text(
                    maplist[index].key,
                    style: TextStyle(fontSize: 12, color: colors[index]),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
              // children: labels.entries.map((label) {
              //   return Text(
              //     label.key,
              //     style: TextStyle(fontSize: 12),
              //   );
              // }).toList(),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(maplist.length, (index) {
                double currentWidth = double.parse(
                    (maplist[index].value / totalPercentage * totalWidth)
                        .toStringAsFixed(2));
                return Container(
                  width: currentWidth, // 每个柱状图占30%的宽度
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientItem(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, color: Color.fromRGBO(115, 115, 115, 1)),
    );
  }
}
