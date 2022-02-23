import 'package:local_auth/local_auth.dart';

class AuthManager {
  LocalAuthentication localAuth = LocalAuthentication();
  static bool didAuthenticateBio = false;
  static bool didAuthenticatePin = false;
  static bool didAuthenticateOtp = false;

  Future<bool> getBiometricAuth() async {
    bool hasAuth = await localAuth.canCheckBiometrics;

    if (hasAuth && !didAuthenticateBio) {
      didAuthenticateBio =
      await localAuth.authenticate(
          localizedReason: 'Authenticate',
          biometricOnly: true);
    }

    return didAuthenticateBio;
  }
}