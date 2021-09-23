import 'package:get/get.dart';
import 'package:hr_project_flutter/Beacon/BeaconController.dart';
import 'package:hr_project_flutter/Beacon/BeaconPage.dart';
import 'package:hr_project_flutter/Page/SplashPage.dart';
import 'package:hr_project_flutter/Page/GroupwarePage.dart';
import 'package:hr_project_flutter/Page/TitlePage.dart';

class Pages {
  static String nameSplash = "/splash";
  static String nameTitle = "/title";
  static String nameGroupware = "/groupware";
  static String nameBeacon = "/beacon";

  static List<GetPage> get container => [
        GetPage(
          name: nameSplash,
          page: () => SplashPage(),
        ),
        GetPage(
          name: nameTitle,
          page: () => TitlePage(),
        ),
        GetPage(
          name: nameGroupware,
          page: () => GroupwarePage(),
        ),
        GetPage(
          name: nameBeacon,
          page: () => BeaconPage(),
          binding: BeaconBinding(),
        ),
      ];
}
