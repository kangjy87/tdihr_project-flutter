import 'package:flutter/services.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:local_auth_device_credentials/auth_strings.dart';
import 'package:local_auth_device_credentials/local_auth.dart';
// import 'package:local_auth/local_auth.dart';

enum BIO_SURPPORT {
  UNKNOWN,
  SUPPORTED,
  UNSUPPORTED,
}

enum LOCAL_AUTH_RESULT {
  AUTHORIZED,
  AUTHORIZED_FAIL,
  NO_AUTHORIZED,
}

LocalAuthManager localAuthManager = LocalAuthManager();

class LocalAuthManager {
  final LocalAuthentication auth = LocalAuthentication();
  BIO_SURPPORT _supportState = BIO_SURPPORT.UNKNOWN;
  bool _canCheckBiometrics = false;
  late List<BiometricType> _availableBiometics = <BiometricType>[];
  bool _authenticated = false;
  bool _authenticating = false;
  LOCAL_AUTH_RESULT _authResult = LOCAL_AUTH_RESULT.NO_AUTHORIZED;
  String _lastError = '';

  BIO_SURPPORT get supportState => _supportState;
  LOCAL_AUTH_RESULT get authResult => _authResult;
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

  Future<LOCAL_AUTH_RESULT> authenticate() async {
    try {
      _authenticating = true;
      _authenticated = await auth
          .authenticate(
        localizedReason: STRINGS.authenticate,
        useErrorDialogs: true,
        stickyAuth: true,
        sensitiveTransaction: true,
        androidAuthStrings: AndroidAuthMessages(
          signInTitle: STRINGS.tdiGroupware,
          biometricHint: ' ',
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

      _authResult = LOCAL_AUTH_RESULT.NO_AUTHORIZED;
      return _authResult;
    }

    _authResult = _authenticated ? LOCAL_AUTH_RESULT.AUTHORIZED : LOCAL_AUTH_RESULT.AUTHORIZED_FAIL;
    return _authResult;
  }

  void cancelAuthentication() async {
    await auth.stopAuthentication();
    _authenticated = false;
    _authenticating = false;
  }
}
