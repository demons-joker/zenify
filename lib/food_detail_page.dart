import 'package:flutter/material.dart';

class FoodDetailPage extends StatelessWidget {
  const FoodDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 第二行：图片和文字
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧图片
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/cai.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 右侧文字
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题
                      const Text(
                        '香煎鸡排、鸡蛋、西兰花盖饭',
                        style: TextStyle(
                          color: Color(0xFF363636),
                          fontSize: 19,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 时间
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/user.png',
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            '时间',
                            style: TextStyle(
                              color: Color(0xFF636363),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '20分钟',
                            style: TextStyle(
                              color: Color(0xFF636363),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Image.asset(
                            'assets/images/user.png',
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            '已吃',
                            style: TextStyle(
                              color: Color(0xFF636363),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '2.1万人',
                            style: TextStyle(
                              color: Color(0xFF636363),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // 难度
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/user.png',
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            '难度',
                            style: TextStyle(
                              color: Color(0xFF636363),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '轻松拿捏',
                            style: TextStyle(
                              color: Color(0xFF636363),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 第三行：推荐指数
            Container(
              width: double.infinity,
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFA2CA0B),
                  width: 1,
                ),
                color: const Color(0xFFFDFDFD),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '推荐指数',
                    style: TextStyle(
                      color: Color(0xFFA2CA0B),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        '8',
                        style: TextStyle(
                          color: Color(0xFFA2CA0B),
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        '/',
                        style: TextStyle(
                          color: Color(0xFFA2CA0B),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        '10',
                        style: TextStyle(
                          color: Color(0xFFA2CA0B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 第四行：营养成分
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '营养成分',
                    style: TextStyle(
                      color: Color(0xFF363636),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 卡路里
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '卡路里',
                        style: TextStyle(
                          color: Color(0xFF636363),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Text(
                        '600kcal',
                        style: TextStyle(
                          color: Color(0xFF636363),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 脂肪
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '脂肪',
                        style: TextStyle(
                          color: Color(0xFF636363),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Text(
                        '400g',
                        style: TextStyle(
                          color: Color(0xFF636363),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
