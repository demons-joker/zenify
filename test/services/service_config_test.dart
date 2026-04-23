import 'package:flutter_test/flutter_test.dart';
import 'package:zenify/services/service_config.dart';

void main() {
  test('api and mqtt config has sane defaults', () {
    expect(ApiConfig.baseUrl, isNotEmpty);
    expect(ApiConfig.mqttBrokerAddress, isNotEmpty);
    expect(ApiConfig.mqttPort, greaterThan(0));
  });
}
