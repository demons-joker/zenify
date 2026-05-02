import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:zenify/services/api.dart';
import 'package:zenify/services/upload_service.dart';
import 'package:zenify/services/user_session.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const userName = 'codex_flutter_local_20260430';
  const password = 'Codex123456!';
  const email = 'codex_flutter_local_20260430@example.com';
  const fallbackUserName = 'codex_local_20260430';
  const fallbackEmail = 'codex_local_20260430@example.com';
  const deviceId = 'DEV-1-1020BA462D5C';
  const imagePath = String.fromEnvironment(
    'LOCAL_FOOD_IMAGE_PATH',
    defaultValue: 'F:/mingyuehu/xilanhua/food.jpg',
  );

  testWidgets('local upload flow works with food.jpg', (tester) async {
    await UserSession.clear();

    await _authenticate(
      const LoginRequest(
        name: userName,
        email: email,
        fullName: 'Codex Flutter Local',
        password: password,
      ),
    );

    var devices = await Api.getUserDevices();
    if (!_hasDevice(devices, deviceId)) {
      try {
        await Api.bindDevice(deviceId);
        devices = await Api.getUserDevices();
      } catch (_) {
        await UserSession.clear();
        await _authenticate(
          const LoginRequest(
            name: fallbackUserName,
            email: fallbackEmail,
            fullName: 'Codex Local Smoke',
            password: password,
          ),
        );
        devices = await Api.getUserDevices();
      }
    }

    expect(_hasDevice(devices, deviceId), isTrue);

    final file = File(imagePath);
    expect(await file.exists(), isTrue, reason: 'food image must exist');

    final result = await UploadService.uploadImage(file);
    expect(
      result.success,
      isTrue,
      reason: result.errorMessage ?? result.responseBody ?? 'upload failed',
    );
    expect(result.statusCode, anyOf(200, 201));
    expect(result.responseBody, isNotNull);

    final decoded = jsonDecode(result.responseBody!);
    expect(decoded, isA<Map<String, dynamic>>());

    final payload = decoded as Map<String, dynamic>;
    expect(payload['meal_session_id'], isNotNull);
    expect(payload['meal_record_id'], isNotNull);
    expect(payload['behavior_summary_id'], isNotNull);
    expect(payload['result_status'], anyOf('finalized', 'already_finalized'));
  });
}

Future<void> _authenticate(LoginRequest request) async {
  dynamic authPayload;
  try {
    authPayload = await Api.register(request);
  } catch (_) {
    authPayload = await Api.login(
      LoginRequest(
        name: request.name,
        password: request.password,
      ),
    );
  }

  expect(authPayload, isA<Map>());
  await UserSession.saveLoginResponse(
    Map<String, dynamic>.from(authPayload as Map),
  );
}

bool _hasDevice(List<dynamic> devices, String deviceId) {
  return devices.any((device) {
    if (device is! Map) return false;
    final raw = Map<String, dynamic>.from(device);
    final currentId =
        (raw['hardware_device_id'] ?? raw['device_id'] ?? '').toString();
    return currentId == deviceId;
  });
}
