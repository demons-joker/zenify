import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenify/presentation/report/report_detail.dart';

void main() {
  testWidgets('ReportDetailPage renders key sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReportDetailPage()));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(ReportDetailPage), findsOneWidget);
  });
}
