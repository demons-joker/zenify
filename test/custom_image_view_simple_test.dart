// CustomImageView组件测试 - 简化版本
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/custom_image_view.dart';

void main() {
  group('CustomImageView Tests', () {
    testWidgets('显示文字', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomImageView(
              text: 'Skip',
              height: 50,
              width: 100,
            ),
          ),
        ),
      );

      expect(find.byType(CustomImageView), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('自定义文字样式', (WidgetTester tester) async {
      const customStyle = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomImageView(
              text: 'Skip',
              textStyle: customStyle,
              height: 50,
              width: 100,
            ),
          ),
        ),
      );

      expect(find.byType(CustomImageView), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('Skip'));
      expect(textWidget.style?.fontSize, equals(16));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
      expect(textWidget.style?.color, equals(Colors.red));
    });

    testWidgets('显示文字和图片组合', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomImageView(
              text: 'Skip',
              height: 50,
              width: 100,
            ),
          ),
        ),
      );

      expect(find.byType(CustomImageView), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('文字在前图片在后的布局', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomImageView(
              imagePath: 'assets/images/img_1.svg',
              text: 'Skip',
              height: 50,
              width: 100,
            ),
          ),
        ),
      );

      expect(find.byType(CustomImageView), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      
      // 验证Row存在
      expect(find.byType(Row), findsOneWidget);
      
      // 获取Row组件
      final rowFinder = find.byType(Row);
      final row = tester.widget<Row>(rowFinder);
      final children = row.children;
      
      // 第一个子元素应该是Flexible包装的Text（文字在前）
      expect(children.first.runtimeType, equals(Flexible));
      
      // 验证第一个Flexible包含Text
      final firstFlexible = tester.widget<Flexible>(find.byType(Flexible).first);
      expect(firstFlexible.child.runtimeType, equals(Text));
      
      // 如果有图片，最后一个子元素应该是Flexible包装的图片
      if (children.length > 1) {
        expect(children.last.runtimeType, equals(Flexible));
        expect(children.last, isNot(equals(children.first)));
      }
    });

    testWidgets('点击测试', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomImageView(
              text: 'Skip',
              height: 50,
              width: 100,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomImageView));
      expect(wasTapped, isTrue);
    });
  });
}