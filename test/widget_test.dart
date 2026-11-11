import 'package:day_log/screens/auth/login_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QR reauthentication preserves the normal login route by default', () {
    expect(const LoginScreen().returnAfterLogin, isFalse);
    expect(const LoginScreen(returnAfterLogin: true).returnAfterLogin, isTrue);
  });
}
