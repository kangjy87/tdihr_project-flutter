import 'package:flutter/services.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:local_auth_device_credentials/auth_strings.dart';
import 'package:local_auth_device_credentials/local_auth.dart';
// import 'package:local_auth/local_auth.dart';

enum BIO_SURPPORT {
  UNKNOWN,
  SUPPORTED,
  UNSUPPORTED,
}

LocalAuthManager localAuthManager = LocalAuthManager();

class LocalAuthManager {
  final LocalAuthentication auth = LocalAuthentication();
  BIO_SURPPORT _supportState = BIO_SURPPORT.UNKNOWN;
  bool _canCheckBiometrics = false;
  late List<BiometricType> _availableBiometics = <BiometricType>[];
  bool _authenticated = false;
  bool _authenticating = false;
  String _lastError = '';

  BIO_SURPPORT get supportState => _supportState;
  bool get authenticated => _authenticated;
  bool get authenticating => _authenticating;

  void setLastError(String err) {
    _lastError = err;
    slog.i(err);
  }

  String getLastError() {
    String err = _lastError;
    _lastError = '';
    return err;
  }

  Future<void> initialze() async {
    await _checkDeviceSupported();
    await _checkBiometrics();
    await _checkAvailableBiometrics();
  }

  Future<void> _checkDeviceSupported() async {
    try {
      await auth.isDeviceSupported().then((value) {
        _supportState = value ? BIO_SURPPORT.SUPPORTED : BIO_SURPPORT.UNSUPPORTED;
        return value;
      });
    } on PlatformException catch (e) {
      _supportState = BIO_SURPPORT.UNKNOWN;
      setLastError("Error - ${e.message}");
    }

    slog.i('Support State $_supportState');
  }

  Future<void> _checkBiometrics() async {
    try {
      _canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      _canCheckBiometrics = false;
      setLastError("Error - ${e.message}");
    }

    slog.i('Can Biometrics $_canCheckBiometrics');
  }

  Future<void> _checkAvailableBiometrics() async {
    try {
      _availableBiometics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      _availableBiometics = <BiometricType>[];
      setLastError("Error - ${e.message}");
    }

    _availableBiometics.forEach((element) {
      slog.i('Available Biometic ${element.toString()}');
    });
  }

  Future<void> authenticate() async {
    try {
      _authenticating = true;
      _authenticated = await auth
          .authenticate(
        localizedReason: '계속하려면 바이오 인증을 완료하세요.',
        useErrorDialogs: true,
        stickyAuth: true,
        sensitiveTransaction: true,
        androidAuthStrings: AndroidAuthMessages(
          signInTitle: 'XXXXX',
          biometricHint: '인증 처리 입니다.',
        ),
        // biometricOnly: true,
      )
          .then((value) {
        _authenticating = false;
        slog.i('Authenticated : $value');
        return value;
      });
    } on PlatformException catch (e) {
      _authenticated = false;
      _authenticating = false;
      setLastError("Error - ${e.message}");
      slog.i(e);
    }
  }

  void cancelAuthentication() async {
    await auth.stopAuthentication();
    _authenticated = false;
    _authenticating = false;
  }
}
