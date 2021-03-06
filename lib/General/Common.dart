import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';

enum OS_TYPE {
  NONE,
  AOS,
  IOS,
}

extension OSTypeEx on OS_TYPE {
  String get convertString {
    switch (this) {
      case OS_TYPE.NONE:
        return "none";
      case OS_TYPE.AOS:
        return "aos";
      case OS_TYPE.IOS:
        return "ios";
      default:
        return '';
    }
  }
}

class PROVIDERS {
  static String google = "google";
}

class ASSETS {
  static String lottieSplash = "assets/splash.json";
  static String tdiLogo = "assets/tdi_img.png";
  static String googleLogo = "assets/google.png";
  static String font = "NanumRoundB";
}

class URL {
  // static String tdiAuth = "https://dev.groupware.tdi9.com/api/app/auth";
  // static String tdiLogin = "https://dev.groupware.tdi9.com/app/login/token/";
  static String tdiAuth = "https://groupware.tdi9.com/api/app/auth";
  static String tdiLogin = "https://groupware.tdi9.com/app/login/token/";
}

class MESSAGES {
  static String errLoginEmail = "회사메일로 로그인 하세요.";
  static String errLoginFailed = "로그인 실패 했습니다.";
  static String errAppUpdateTitle = "앱이 업데이트되었습니다.";
  static String errIosAppUpdateMsg1 = "테스트플라이트에서 새로운 버전의 ";
  static String errIosAppUpdateMsg2 = "TDI Groupware를 업데이트 해주세요.";
  static String errAppUpdate = "업데이트를 진행하시겠습니까?";
  static String errAppUpdateBtn1 = "예";
  static String errAppUpdateBtn2 = "아니요";
}

class STRINGS {
  static String tdiGroupware = "TDI Groupware";
  static String googleLogin = "구글 로그인(회사메일)";
  static String authenticate = "본인 인증을 완료해 주세요.";
  static String signining = "로그인중 입니다 ...";
  static String logout = "로그아웃";
  static String beacon = "Beacon";
  static String geofence = "Geofence";
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

String kAppName = "";
String kPackageName = "";
String kAppVersion = "";
String kBuildNumber = "";

void readPackageInfo() {
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    kAppName = packageInfo.appName;
    kPackageName = packageInfo.packageName;
    kAppVersion = packageInfo.version;
    kBuildNumber = packageInfo.buildNumber;
  });
}

bool kIsPushLink = false;
String kPushLinkURL = "";
