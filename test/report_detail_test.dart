import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenify/presentation/report/report_detail.dart';

void main() {
  testWidgets('ReportDetailPage renders key sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReportDetailPage()));

    // Header
    expect(find.text('89'), findsOneWidget);

    // Dietary structure title
    expect(find.text('2:1:1 Dietary structure'), findsOneWidget);

    // Nutritional details title (pill exists)
    expect(find.text('32min'), findsOneWidget);
  });
}
