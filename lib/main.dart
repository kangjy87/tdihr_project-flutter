import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/FCMManager.dart';
import 'package:hr_project_flutter/General/FileIO.dart';
import 'package:hr_project_flutter/General/FirebaseCore.dart';
import 'package:hr_project_flutter/Auth/LocalAuthManager.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/Page/Pages.dart';
import 'package:logger/logger.dart';

void main() async {
  if (kReleaseMode == true)
    Logger.level = Level.error;
  else
    Logger.level = Level.verbose;
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIOverlays([
    SystemUiOverlay.bottom,
    SystemUiOverlay.top,
  ]);
  await FirebaseCore().initialize();
  await FCMManager().initialize();
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

    readText(TDIUser.fileAccountJson).then(
      (json) => {
        if (json.isEmpty == false) TDIUser.account = TDIAccount.formJson(jsonDecode(json)) else TDIUser.account = null,
        setState(() {
          TDIUser.readUserJSON = TDIUser.account != null;
        }),
      },
    );

    readText(TDIUser.fileTokenJson).then(
      (json) => {
        if (json.isEmpty == false) TDIUser.token = TDIToken.formJson(jsonDecode(json)) else TDIUser.token = null,
        setState(() {
          TDIUser.readUserTokenJSON = TDIUser.account != null;
        })
      },
    );

    Util().readPackageInfo();

    FCMManager().setListener(_onMessage, _onMessageOpenedApp);
    LocalAuthManager().initialze();
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

  void _onMessage(RemoteMessage message) {
    Util().showSnackBar(message.notification!.title!, message.notification!.body!);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    Util().showSnackBar(message.notification!.title!, message.notification!.body!);
  }
}
