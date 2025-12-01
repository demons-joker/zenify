// lib/widgets/nutribot_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NutriBot extends StatelessWidget {
  final String expression; // 'neutral', 'happy', 'cheers', 'talking'
  final double size;
  final bool showGlass;

  const NutriBot({
    Key? key,
    required this.expression,
    this.size = 150.0,
    this.showGlass = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: _buildNutriBot(),
    );
  }

  Widget _buildNutriBot() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Shadow
        Positioned(
          bottom: 10,
          child: Container(
            width: size * 0.6,
            height: size * 0.05,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size * 0.5),
            ),
          ),
        ),

        // Body
        Container(
          width: size * 0.8,
          height: size * 0.8,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Eyes
              Positioned(
                top: size * 0.25,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEye(expression),
                    _buildEye(expression),
                  ],
                ),
              ),

              // Mouth
              Positioned(
                bottom: size * 0.3,
                child: CustomPaint(
                  size: Size(size * 0.3, size * 0.2),
                  painter: MouthPainter(),
                ),
              ),

              // Glass
              if (showGlass)
                Positioned(
                  right: size * 0.05,
                  bottom: size * 0.1,
                  child: _buildGlass(),
                ),
            ],
          ),
        )
            .animate(target: expression == 'cheers' ? 1 : 0)
            .shimmer(duration: 1000.ms, delay: 500.ms),
      ],
    ).animate().scale(
          duration: 600.ms,
          curve: Curves.elasticOut,
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
        );
  }

  Widget _buildEye(String expression) {
    return Container(
      width: size * 0.15,
      height: size * 0.06,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.03),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(
          begin: 1.0,
          end: 0.1,
          duration: 400.ms,
          delay: 3000.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildGlass() {
    return Transform.rotate(
      angle: -0.2,
      child: Container(
        width: size * 0.35,
        height: size * 0.4,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            // Liquid
            Positioned(
              left: size * 0.02,
              top: size * 0.05,
              right: size * 0.08,
              bottom: size * 0.02,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFccff00),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),

            // Straw
            Positioned(
              left: size * 0.2,
              top: 0,
              child: Container(
                width: 4,
                height: size * 0.25,
                color: Color(0xFFccff00),
              ),
            ),
          ],
        ),
      )
          .animate(target: expression == 'cheers' ? 1 : 0)
          .rotate(
            duration: 1000.ms,
            begin: 0,
            end: -0.2,
            curve: Curves.easeInOut,
          )
          .then()
          .rotate(
            duration: 1000.ms,
            begin: -0.2,
            end: 0,
            curve: Curves.easeInOut,
          ),
    );
  }
}

class MouthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.3, 0);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.8,
      size.width * 0.7,
      size.height * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
