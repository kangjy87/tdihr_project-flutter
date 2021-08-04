import 'package:get/get.dart';
import 'package:hr_project_flutter/Page/SigninPage.dart';
import 'package:hr_project_flutter/Page/TDIGroupwarePage.dart';
import 'package:hr_project_flutter/General/Common.dart';

class Pages {
  static List<GetPage> get container => [
        GetPage(name: COMMON.PAGE_SIGNIN, page: () => SigninPage()),
        GetPage(
            name: COMMON.PAGE_TDI_GROUPWARE, page: () => TDIGroupwarePage()),
      ];
}
