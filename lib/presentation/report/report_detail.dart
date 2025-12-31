import 'package:flutter/material.dart';
import 'dart:math' as math;

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
  double fullness = 0.25;
  double taste = 0.5;
  int moodIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildHeader(),
              // const SizedBox(height: 8),
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
                  child:
                      Text('-END-', style: TextStyle(color: Colors.grey[400]))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('89',
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
          children: const [
            Text('12月1号',
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            Text('星期三', style: TextStyle(fontSize: 12, color: Colors.black45)),
          ],
        )
      ],
    );
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
                Image.asset('assets/images/figma/report/veg_icon.png',
                    width: 36,
                    height: 36,
                    errorBuilder: (c, e, s) => const SizedBox.shrink()),
                const SizedBox(height: 8),
                const Text('44%',
                    style: TextStyle(
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
                        style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildMiniCard(
                      '27%',
                      'High-Carb Foods',
                      'assets/images/figma/report/bread_icon.png',
                      Colors.redAccent)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildMiniCard(
                      '27%',
                      'High-Protein Foods',
                      'assets/images/figma/report/meat_icon.png',
                      Colors.orange)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniCard(
      String percent, String title, String icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Image.asset(icon,
                width: 24,
                height: 24,
                errorBuilder: (c, e, s) => const SizedBox.shrink()),
            const SizedBox(width: 8),
            Text(percent,
                style: TextStyle(
                    fontSize: 18, color: color, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontSize: 14, color: Color(0xFF7A5C47))),
          const SizedBox(height: 8),
          const Text('Ingredient 1\nIngredient 1',
              style: TextStyle(fontSize: 12, color: Color(0xFFB88C6D))),
        ],
      ),
    );
  }

  Widget _buildNutritionDetailsCard() {
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
          _buildPill('assets/images/figma/report/eat_icon.png', '32min'),
          _buildPill('assets/images/figma/report/kcal_icon.png', '400kcal'),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildNutCard('22%', 'Carb', Colors.redAccent)),
          const SizedBox(width: 8),
          Expanded(child: _buildNutCard('21%', 'Protein', Colors.orangeAccent)),
          const SizedBox(width: 8),
          Expanded(child: _buildNutCard('21%', 'Fat', Colors.yellow.shade700)),
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

  Widget _buildNutCard(String percent, String title, Color color) {
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
        const Text('X1g/X2g',
            style: TextStyle(fontSize: 12, color: Color(0xFFB88C6D))),
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
            style: const TextStyle(fontSize: 16, color: Color(0xFF7A5C47))),
        const SizedBox(height: 8),
        Slider(value: value, onChanged: onChanged),
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
