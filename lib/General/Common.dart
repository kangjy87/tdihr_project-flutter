import 'TDIUser.dart';

class COMMON {
  static String OS_NONE = 'none';
  static String OS_AOS = 'aos';
  static String OS_IOS = 'ios';

  static String PROVIDER_GOOGLE = 'goole';

  static String URL_TDI_LOGIN = 'https://dev.groupware.tdi9.com/api/app/auth';
  static String URL_TDI_HOME =
      'https://dev.groupware.tdi9.com/app/login/token/';

  static String PAGE_SIGNIN = '/page_signin';
  static String PAGE_TDI_GROUPWARE = '/page_tdi_groupware';

  static String TDI_GROUPWARE = 'TDI Groupware';
  static String LOGIN_GOOGLE = '구글 로그인(회사메일)';
  static String LOGOUT = '로그아웃';

  static String ERROR_LOGIN = '회사메일로 로그인 하세요.';

  static String FILE_USER_JSON = 'user.json';
  static String FILE_USER_TOKEN_JSON = 'usert.json';

  static String ASSET_LOTTIE_SPLASH = 'assets/splash.json';
  static String ASSET_TDI_LOGO = 'assets/tdi_img.png';
  static String ASSET_GOOGLE = 'assets/google.png';

  static TDIUser? TDI_USER;
  static TDIToken? TDI_TOKEN;
}
