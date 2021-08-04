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
        return 'none';
      case OS_TYPE.IOS:
        return 'none';
      default:
        return '';
    }
  }
}

enum RESULT_TYPE {
  SUCCESS,
  FAILED,
  EXCEPTION,
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
  static String errLogin = '회사메일로 로그인 하세요.';
}

class STRINGS {
  static String tdiGroupware = 'TDI Groupware';
  static String googleLogin = '구글 로그인(회사메일)';
  static String logout = '로그아웃';
}
