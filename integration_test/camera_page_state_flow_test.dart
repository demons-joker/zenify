import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zenify/presentation/camera/camera_page.dart';
import 'package:zenify/presentation/camera/camera_upload_coordinator.dart';
import 'package:zenify/services/mqtt_service.dart';
import 'package:zenify/services/upload_service.dart';

class _FakeUploadCoordinator extends CameraUploadCoordinator {
  @override
  Future<UploadResult> submitImage(File file) async {
    return UploadResult.success(
      statusCode: 200,
      body: '{"meal_session_id":1807,"meal_record_id":1806}',
    );
  }
}

class _CameraRouteHost extends StatefulWidget {
  const _CameraRouteHost({
    required this.statusStream,
    required this.imagePath,
  });

  final Stream<RecognitionStatus> statusStream;
  final String imagePath;

  @override
  State<_CameraRouteHost> createState() => _CameraRouteHostState();
}

class _CameraRouteHostState extends State<_CameraRouteHost> {
  Object? _result;
  bool _pushed = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          if (!_pushed) {
            _pushed = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CameraPage(
                    uploadCoordinator: _FakeUploadCoordinator(),
                    statusStream: widget.statusStream,
                    initialImagePath: widget.imagePath,
                    skipCameraInitialization: true,
                    completionNavigationDelay: const Duration(milliseconds: 10),
                    mqttWaitTimeout: const Duration(seconds: 2),
                  ),
                ),
              );
              if (!mounted) return;
              setState(() {
                _result = result;
              });
            });
          }

          return Scaffold(
            body: Text(
              _result == null ? 'no_result' : jsonEncode(_result),
              key: const Key('camera_route_result'),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('camera page transitions from upload to mqtt completion',
      (tester) async {
    const imagePath = String.fromEnvironment(
      'LOCAL_FOOD_IMAGE_PATH',
      defaultValue: 'F:/mingyuehu/xilanhua/food.jpg',
    );
    final statusController = StreamController<RecognitionStatus>.broadcast();
    addTearDown(statusController.close);

    await tester.pumpWidget(
      _CameraRouteHost(
        statusStream: statusController.stream,
        imagePath: imagePath,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('camera_ok_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('camera_ok_button')));
    await tester.pump();

    expect(find.byKey(const Key('camera_cancel_wait_button')), findsOneWidget);
    expect(
      find.byKey(const Key('camera_status_loading_indicator')),
      findsOneWidget,
    );

    statusController.add(
      RecognitionStatus(status: RecognitionStatusType.analyzing),
    );
    await tester.pump();

    expect(find.byKey(const Key('camera_cancel_wait_button')), findsNothing);
    expect(
      find.byKey(const Key('camera_status_loading_indicator')),
      findsOneWidget,
    );

    statusController.add(
      RecognitionStatus(status: RecognitionStatusType.completed),
    );
    await tester.pump();

    expect(find.byKey(const Key('camera_status_completed_icon')), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 200));

    final resultText = tester.widget<Text>(
      find.byKey(const Key('camera_route_result')),
    );
    expect(resultText.data, contains('switchToATE'));
    expect(resultText.data, contains('true'));
  });
}
