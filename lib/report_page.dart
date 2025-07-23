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
                  '你的报告',
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
              const SizedBox(height: 20),
              _buildWhiteListCard(), // 添加211白名单卡片
              const SizedBox(height: 20),
              _buildDietSuggestionCard(),
              const SizedBox(height: 20),
              _buildTextCard(
                  title: '胃肠道',
                  content: [
                    '1、每天保证充足的水分摄入',
                    '2、保持规律的作息时间',
                    '3、适量运动有助于消化',
                    '4、注意饮食多样化',
                  ],
                  icon: IconFont.weichangdaojianyi),
              const SizedBox(height: 20),
              _buildTextCard(
                  title: '美容养颜',
                  content: [
                    '1. 皮肤健康维度',
                    '氧化损伤防御力：',
                    '评估参数：深色蔬果（VC/VE/类胡萝卜素）、坚果种子（硒/VE）、茶多酚摄入频率。',
                    '关联症状：日晒后易红肿/色斑加深、皮肤修复速度慢。',
                    '胶原蛋白合成力：',
                    '评估参数：优质蛋白（肉蛋豆）、VC（柑橘/莓果）、铜锌（贝壳/内脏）摄入量。',
                    '关联症状：皮肤松弛、细纹增多、伤口愈合慢。',
                    '炎症调控能力：',
                    '评估参数：Omega-3（深海鱼/亚麻籽）/Omega-6比例、姜黄/莓果摄入、精制糖/油炸食品频率。',
                    '关联症状：反复痘痘、泛红敏感、毛孔粗大。',
                    '水合保湿力：',
                    '评估参数：必需脂肪酸（坚果/鱼油）、饮水总量、高水分蔬果（黄瓜/番茄）摄入。',
                    '关联症状：干燥脱屑、外油内干、角质层薄。',
                    '2. 代谢与循环维度',
                    '血糖平稳度：',
                    '评估参数：低GI主食占比、膳食纤维摄入量、餐后零食选择（是否高糖）。',
                    '关联症状：面部糖化（暗黄/法令纹深）、易浮肿。',
                    '肝肠解毒效率：',
                    '评估参数：十字花科蔬菜（西兰花/芥蓝）、硫化物（大蒜/洋葱）、水溶性纤维（燕麦/苹果）摄入。',
                    '关联症状：肤色晦暗、黑眼圈顽固、易长痘。',
                    '微循环状态：',
                    '评估参数：铁（红肉/菠菜）、B12（动物肝/蛋）、叶酸（深绿叶菜）是否充足。',
                    '关联症状：面色苍白/蜡黄、手脚冰凉、唇色淡。',
                    '3. 激素平衡维度',
                    '雌激素代谢支持：',
                    '评估参数：大豆异黄酮（豆腐/豆浆）、木酚素（亚麻籽）、西兰花摄入。',
                    '关联症状：经前爆痘、周期皮肤波动、更年期潮红加剧。',
                    '压力激素调节：',
                    '评估参数：镁（黑巧/杏仁）、VC（彩椒/猕猴桃）、磷脂（蛋黄）摄入。',
                    '关联症状：压力性痤疮、皮肤屏障脆弱、脱发。',
                    '4. 毛发与体态维度',
                    '发质与头皮健康：',
                    '评估参数：生物素（鸡蛋/酵母）、锌（牡蛎/南瓜籽）、优质蛋白摄入。',
                    '关联症状：脱发量增加、头发细软易断、头屑增多。',
                    '水肿与轮廓管理：',
                    '评估参数：钾（香蕉/菠菜）/钠比例、水分摄入规律性。',
                    '关联症状：晨起面部浮肿、下肢沉重。'
                  ],
                  icon: IconFont.xiaozhu)
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
                  child: OverflowBox(
                    maxWidth: double.infinity, // 允许无限宽度
                    alignment: Alignment.centerLeft, // 左对齐
                    child: Text(
                      '${maplist[index].key} ${maplist[index].value}g',
                      style: TextStyle(fontSize: 12, color: colors[index]),
                      textAlign: TextAlign.center,
                    ),
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

  // 211白名单
  Widget _buildWhiteListCard() {
    return Stack(
        clipBehavior: Clip.none, // 关键设置，允许子组件溢出
        children: [
          Container(
            height: 255,
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
                        '211白名单',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        height: 2, // 下划线高度
                        width: 100, // 下划线宽度
                        margin: EdgeInsets.only(top: 4), // 与文字的间距
                        color: Colors.black87, // 下划线颜色
                      ),
                    ],
                  ),
                ),

                // 菜品横向列表
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFoodItem('番茄炒蛋', '100kcal', '222g'),
                        SizedBox(width: 5),
                        _buildFoodItem('清蒸鱼', '120kcal', '180g'),
                        SizedBox(width: 5),
                        _buildFoodItem('西兰花', '80kcal', '150g'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -20,
            left: 10,
            child: Icon(
              IconFont.shucai,
              size: 60,
              color: const Color.fromARGB(255, 4, 160, 56),
            ),
          ),
        ]);
  }

// 构建单个菜品项
  Widget _buildFoodItem(String name, String calories, String weight) {
    return Expanded(
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Color(0xFFD8D1CF),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // 让子项填满宽度
          children: [
            // 菜品图片部分
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  _getRandomFoodImage(),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.fastfood, size: 40, color: Colors.white),
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
                  crossAxisAlignment: CrossAxisAlignment.start, // 子项左对齐
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft, // 强制左对齐
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
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
                        calories,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.left, // 明确设置文本左对齐
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft, // 强制左对齐
                      child: Text(
                        weight,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
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
                      '膳食调整建议',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      height: 2,
                      width: 100,
                      margin: EdgeInsets.only(top: 4),
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),

              // 第一行三个图文结合体
              Container(
                height: 128,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSuggestionItem('蛋白质食物',
                        'https://img.freepik.com/free-photo/grilled-chicken-breast-vegetables_2829-19744.jpg'),
                    SizedBox(width: 5),
                    _buildSuggestionItem('碳水食物',
                        'https://img.freepik.com/free-photo/assortment-raw-whole-grains_23-2148892083.jpg'),
                    SizedBox(width: 5),
                    _buildSuggestionItem('膳食纤维',
                        'https://img.freepik.com/free-photo/healthy-vegetables-wooden-table_1150-38014.jpg'),
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
          child: Icon(
            IconFont.shanshijianyi,
            size: 60,
            color: const Color.fromARGB(255, 4, 160, 56),
          ),
        ),
      ],
    );
  }

// 构建单个建议项
  Widget _buildSuggestionItem(String name, String imageUrl) {
    return Expanded(
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          color: Color(0xFFD8D1CF),
          borderRadius: BorderRadius.circular(14),
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
          children: [
            // 图片部分
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
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
            // 文字部分
            Container(
              height: 28,
              padding: EdgeInsets.only(left: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
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
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      height: 2,
                      width: 100,
                      margin: EdgeInsets.only(top: 4),
                      color: Colors.black87,
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
