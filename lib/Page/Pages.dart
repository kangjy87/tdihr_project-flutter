import 'package:get/get.dart';
import 'package:hr_project_flutter/Page/SigninPage.dart';
import 'package:hr_project_flutter/Page/TDIGroupwarePage.dart';

class Pages {
  static List<GetPage> get container => [
        GetPage(name: '/signin', page: () => SigninPage()),
        GetPage(name: '/tdi_groupware', page: () => TDIGroupwarePage()),
      ];
}
