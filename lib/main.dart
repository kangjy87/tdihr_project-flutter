import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/FileIO.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/Page/Pages.dart';
import 'package:logger/logger.dart';

void main() async {
  if (kReleaseMode == true)
    Logger.level = Level.error;
  else
    Logger.level = Level.verbose;
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top]);
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);
  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return _splashScreen();
  }

  @override
  void initState() {
    super.initState();

    readText(TDIUser.fileAccountJson).then((json) => {
          TDIUser.account = TDIAccount.formJson(jsonDecode(json)),
          setState(() {
            TDIUser.readUserJSON = TDIUser.account != null;
          })
        });

    readText(TDIUser.fileTokenJson).then((json) => {
          TDIUser.token = TDIToken.formJson(jsonDecode(json)),
          setState(() {
            TDIUser.readUserTokenJSON = TDIUser.account != null;
          })
        });

    readPackageInfo();
  }

  GetMaterialApp _splashScreen() {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'TmoneyRoundWind',
      ),
      getPages: Pages.container,
      initialRoute: PAGES.splash,
      defaultTransition: Transition.fadeIn,
      transitionDuration: Duration(seconds: 1),
    );
  }
}
