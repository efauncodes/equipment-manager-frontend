import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_manager_frontend/main.dart';

void main() {
  test('uses the confirmed staging API base URL by default', () {
    expect(apiBaseUrl, 'https://equipment-api.sentient-octopus.dev');
  });
}
