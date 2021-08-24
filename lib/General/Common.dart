import 'package:flutter/material.dart';
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
}

String appName = '';
String packageName = '';
String appVersion = '';
String buildNumber = '';

void readPackageInfo() {
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    appVersion = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  });
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
