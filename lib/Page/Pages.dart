import 'package:get/get.dart';
import 'package:hr_project_flutter/Page/SigninPage.dart';
import 'package:hr_project_flutter/Page/TDIGroupwarePage.dart';

class PAGES {
  static String title = '/page_title';
  static String tdiGroupware = '/page_tdi_groupware';
}

class Pages {
  static List<GetPage> get container => [
        GetPage(name: PAGES.title, page: () => SigninPage()),
        GetPage(name: PAGES.tdiGroupware, page: () => TDIGroupwarePage()),
      ];
}
