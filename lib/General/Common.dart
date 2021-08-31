import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

enum OS_TYPE {
  NONE,
  AOS,
  IOS,
}

extension OSTypeExt on OS_TYPE {
  String get convertString {
    switch (this) {
      case OS_TYPE.NONE:
        return 'none';
      case OS_TYPE.AOS:
        return 'aos';
      case OS_TYPE.IOS:
        return 'ios';
      default:
        return '';
    }
  }
}

class PROVIDERS {
  static String google = 'goole';
}

class ASSETS {
  static String lottieSplash = 'assets/splash.json';
  static String tdiLogo = 'assets/tdi_img.png';
  static String googleLogo = 'assets/google.png';
}

class URL {
  static String tdiAuth = 'https://dev.groupware.tdi9.com/api/app/auth';
  static String tdiLogin = 'https://dev.groupware.tdi9.com/app/login/token/';
}

class MESSAGES {
  static String errLoginEmail = '회사메일로 로그인 하세요.';
  static String errLoginFailed = '로그인 실패 했습니다.';
}

class STRINGS {
  static String tdiGroupware = 'TDI Groupware';
  static String googleLogin = '구글 로그인(회사메일)';
  static String authenticate = "본인 인증을 완료해 주세요.";
  static String signining = '로그인중 입니다 ...';
  static String logout = '로그아웃';
  static String beacon = 'Beacon';
}

class Util {
  static final Util _instance = Util._internal();

  String _appName = '';
  String _packageName = '';
  String _appVersion = '';
  String _buildNumber = '';

  String get appName => _appName;
  String get packageName => _packageName;
  String get appVersion => _appVersion;
  String get buildNumber => _buildNumber;

  factory Util() {
    return _instance;
  }

  Util._internal();

  void readPackageInfo() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      _appName = packageInfo.appName;
      _packageName = packageInfo.packageName;
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  Future<bool?> showToastMessage(String message) {
    return Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.blueAccent,
        fontSize: 16.0,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT);
  }

  void showSnackBar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      colorText: Colors.white,
      backgroundColor: Colors.blue[800],
    );
  }
}
