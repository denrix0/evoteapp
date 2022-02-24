import 'package:local_auth/local_auth.dart';

class AuthManager {
  LocalAuthentication localAuth = LocalAuthentication();
  static bool didAuthenticateBio = false;
  static bool didAuthenticatePin = false;
  static bool didAuthenticateOtp = false;
  static bool didAuthenticateGid = false;

  Future<bool> getBiometricAuth() async {
    bool _hasAuth = await localAuth.canCheckBiometrics;

    if (_hasAuth && !didAuthenticateBio) {
      didAuthenticateBio =
      await localAuth.authenticate(
          localizedReason: 'Authenticate',
          biometricOnly: true);
    }

    return didAuthenticateBio;
  }

  bool getPinAuth(String _pin) {
    String userPin = '7777';

    if (_pin == userPin) {
      didAuthenticatePin = true;
    }

    return didAuthenticatePin;
  }

  bool getGovernmentAuth(String _gid) {
    String userGid = '00000000';

    if (_gid == userGid) {
      didAuthenticateGid = true;
    }

    return didAuthenticateGid;
  }

  bool getOtpAuth(String _otp) {
    String _gotOtp = '666';

    if (_otp == _gotOtp) {
      didAuthenticateOtp = true;
    }

    return didAuthenticateOtp;
  }


}