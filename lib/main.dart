import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/Beacon/BeaconManager.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/Firebase/FCMManager.dart';
import 'package:hr_project_flutter/General/FileIO.dart';
import 'package:hr_project_flutter/Firebase/FirebaseCore.dart';
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
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin, WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return _splashScreen();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);

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

    FCMManager()
      ..buildRemoteMessage(_onMessage, _onMessageOpenedApp)
      ..initialize().then((value) => null);
    LocalAuthManager()..initialze().then((value) => null);

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    var cur = Get.currentRoute;
    if (cur == PAGES.beacon) {
      BeaconManager().changeAppLifecycleState(state);
    }
    if (TDIUser.isLink == true) {
      if (state == AppLifecycleState.resumed) {
        if (cur != PAGES.tdiGroupware) {
          Get.toNamed(PAGES.tdiGroupware);
        }
      }
    }
    super.didChangeAppLifecycleState(state);
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
    // Util().showSnackBar(message.notification!.title!, message.notification!.body!);
    TDIUser.isLink = false;
    if (message.data.isNotEmpty == true) {
      TDIUser.isLink = message.data.keys.contains("link");
      if (TDIUser.isLink == true) {
        TDIUser.linkURL = message.data["link"];
      }
    }
  }
}
