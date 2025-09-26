import 'package:flutter/material.dart';

class FoodItemCard extends StatelessWidget {
  final String name;
  final String calories;
  final String weight;
  final VoidCallback? onEditPressed;

  const FoodItemCard({
    Key? key,
    required this.name,
    required this.calories,
    required this.weight,
    this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFFF6F6F6),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // 左侧图片
          Image.asset('assets/images/egg.jpeg', width: 114, height: 114),
          // 中间文字
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF646464),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    calories,
                    style: const TextStyle(
                      color: Color(0xFF8FB500),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weight,
                    style: const TextStyle(
                      color: Color(0xFF636363),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 右侧按钮
          IconButton(
            icon: Image.asset('assets/images/edit.png', width: 45, height: 45),
            onPressed: onEditPressed,
          ),
        ],
      ),
    );
  }
}
