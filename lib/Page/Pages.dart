import 'package:get/get.dart';
import 'package:hr_project_flutter/Page/TitlePage.dart';
import 'package:hr_project_flutter/Page/SplashPage.dart';
import 'package:hr_project_flutter/Page/TDIGroupwarePage.dart';

class PAGES {
  static String splash = '/page_splash';
  static String title = '/page_title';
  static String tdiGroupware = '/page_tdi_groupware';
}

class Pages {
  static List<GetPage> get container => [
        GetPage(name: PAGES.splash, page: () => SplashPage()),
        GetPage(name: PAGES.title, page: () => TitlePage()),
        GetPage(name: PAGES.tdiGroupware, page: () => TDIGroupwarePage()),
      ];
}
