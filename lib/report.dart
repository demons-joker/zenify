import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:zenify/report_random_word_cloud.dart';
import 'package:zenify/report_page.dart';
import 'package:zenify/utils/iconfont.dart';

class Report extends StatelessWidget {
  const Report({super.key});

  @override
  Widget build(BuildContext context) {
    final words = [
      {'text': '甜瘾依赖型', 'highlight': true},
      {'text': '肉食者', 'highlight': false},
      {'text': '过程享受型', 'highlight': true},
      {'text': '精致摆盘', 'highlight': false},
      {'text': '色彩爱好者', 'highlight': true},
      {'text': '甜瘾依赖型', 'highlight': true},
      {'text': '肉食者', 'highlight': false},
      {'text': '过程享受型', 'highlight': true},
      {'text': '精致摆盘', 'highlight': false},
      {'text': '色彩爱好者', 'highlight': true},
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 时间选择器
              _buildTimeSelector(),
              const SizedBox(height: 24),
              // 评分和日期行
              _buildScoreAndDateRow(),
              const SizedBox(height: 24),
              // 饮食类型标签(词云样式)
              ReportRandomWordCloud(words: words),
              const SizedBox(height: 24),
              // 健康数据卡片(双列布局)
              _buildHealthDashboard(),
              const SizedBox(height: 24),
              // 新增卡片
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.thumb_up,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      '保持得很牛，加油呀！',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text(
                          '刚点赞',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                        Positioned(
                          right: -5,
                          top: 0,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFF34FB52),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 健康建议卡片
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          '健康建议',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // TextButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //           builder: (context) => ReportPage()),
                        //     );
                        //   },
                        //   child: const Text(
                        //     '详细参数>',
                        //     style: TextStyle(
                        //       fontSize: 14,
                        //       color: Color(0xFF6F6F6F),
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '开发当中...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6F6F6F),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreAndDateRow() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 评分组件
        ScoreCircle(score: 89),
        // 日期组件
        DateDisplay(),
      ],
    );
  }

  Widget _buildTimeSelector() {
    final options = ['日', '周', '月', '年'];
    String selectedOption = '周';

    return StatefulBuilder(builder: (context, setState) {
      return SizedBox(
        height: 32,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: options
              .map((option) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: TimeOption(
                      option: option,
                      isSelected: option == selectedOption,
                      onSelected: (option) =>
                          setState(() => selectedOption = option),
                    ),
                  ))
              .toList(),
        ),
      );
    });
  }

  Widget _buildHealthDashboard() {
    return Row(
      children: [
        // 扇形图卡片(热量分布)
        Expanded(
          flex: 7,
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // 扇形图
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF333333),
                      ),
                      child: CustomPaint(
                        painter: _PieChartPainter(
                          sections: [
                            _PieChartSection(
                              color: Color(0xFFA9B541),
                              value: 400,
                              label: '早餐',
                            ),
                            _PieChartSection(
                              color: Color(0xFFD8D1CF),
                              value: 500,
                              label: '午餐',
                            ),
                            _PieChartSection(
                              color: Color(0xFFE4BB16),
                              value: 200,
                              label: '晚餐',
                            ),
                            _PieChartSection(
                              color: Color(0xFFEE4D4B),
                              value: 100,
                              label: '加餐',
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          IconFont.yisheruzhi,
                          size: 24,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '1200',
                          style: TextStyle(
                            color: Color(0xFFEA7B3C),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'kcal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // 图例
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _LegendItem(color: Color(0xFFA9B541), label: '早餐'),
                    SizedBox(height: 8),
                    _LegendItem(color: Color(0xFFD8D1CF), label: '午餐'),
                    SizedBox(height: 8),
                    _LegendItem(color: Color(0xFFE4BB16), label: '晚餐'),
                    SizedBox(height: 8),
                    _LegendItem(color: Color(0xFFEE4D4B), label: '加餐'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 平均用餐时间卡片
        Expanded(
          flex: 3,
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                const Text(
                  '32min',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '平均',
                  style: TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// 评分圆形组件
class ScoreCircle extends StatelessWidget {
  final int score;

  const ScoreCircle({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          textScaler: TextScaler.noScaling,
          overflow: TextOverflow.clip,
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'PingFang SC',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            children: [
              WidgetSpan(
                child: Stack(
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                    Positioned(
                      right: 0,
                      top: 10,
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
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 日期显示组件
class DateDisplay extends StatelessWidget {
  const DateDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '12月1号',
          style: TextStyle(
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF6F6F6F),
          ),
        ),
        Text(
          '星期三',
          style: TextStyle(
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xFF6F6F6F),
          ),
        ),
      ],
    );
  }
}

// 时间选择选项
class TimeOption extends StatefulWidget {
  final String option;
  final ValueChanged<String> onSelected;
  final bool isSelected;

  const TimeOption({
    super.key,
    required this.option,
    required this.onSelected,
    required this.isSelected,
  });

  @override
  State<TimeOption> createState() => _TimeOptionState();
}

class _PieChartPainter extends CustomPainter {
  final List<_PieChartSection> sections;

  const _PieChartPainter({required this.sections});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius - 8; // 圆环宽度5px
    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);

    double startAngle = -0.5 * 3.1415926535;
    final total = sections.fold(0.0, (sum, section) => sum + section.value);

    for (final section in sections) {
      final sweepAngle = 2 * 3.1415926535 * (section.value / total);
      final paint = Paint()
        ..color = section.color
        ..style = PaintingStyle.fill;

      // 绘制圆环
      final path = Path()
        ..moveTo(center.dx + innerRadius * math.cos(startAngle),
            center.dy + innerRadius * math.sin(startAngle))
        ..lineTo(center.dx + outerRadius * math.cos(startAngle),
            center.dy + outerRadius * math.sin(startAngle))
        ..arcTo(outerRect, startAngle, sweepAngle, false)
        ..lineTo(center.dx + innerRadius * math.cos(startAngle + sweepAngle),
            center.dy + innerRadius * math.sin(startAngle + sweepAngle))
        ..arcTo(innerRect, startAngle + sweepAngle, -sweepAngle, false)
        ..close();

      canvas.drawPath(path, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PieChartSection {
  final Color color;
  final double value;
  final String label;

  const _PieChartSection({
    required this.color,
    required this.value,
    required this.label,
  });
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _TimeOptionState extends State<TimeOption> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onSelected(widget.option),
      child: Container(
        width: 36,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              widget.isSelected ? const Color(0xFF515151) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          widget.option,
          style: TextStyle(
            fontFamily: 'PingFang SC',
            fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 14,
            color: widget.isSelected ? Colors.white : const Color(0xFF6F6F6F),
          ),
        ),
      ),
    );
  }
}
