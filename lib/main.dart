import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/Auth/LocalAuthManager.dart';
import 'package:hr_project_flutter/Beacon/BeaconManager.dart';
import 'package:hr_project_flutter/Firebase/FCMManager.dart';
import 'package:hr_project_flutter/Firebase/FirebaseCore.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/FileIO.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/Geofence/GeofenceManager.dart';
import 'package:hr_project_flutter/Geofence/LocationPermmision.dart';
import 'package:hr_project_flutter/Geofence/LocationService.dart';
import 'package:hr_project_flutter/Page/Pages.dart';
import 'package:logger/logger.dart';

void main() async {
  if (kReleaseMode == true) {
    Logger.level = Level.error;
  } else {
    Logger.level = Level.verbose;
  }
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
  //   SystemUiOverlay.bottom,
  //   SystemUiOverlay.top,
  // ]);
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

    readText(TDIUser.fileAccountJson).then(_readAcountComplete);
    readText(TDIUser.fileTokenJson).then(_readTokenComplete);

    readPackageInfo();

    FCMManager()
      ..buildRemoteMessage(_onMessage, _onMessageOpenedApp)
      ..initialize().then((value) => null);
    LocalAuthManager().initialize().then((value) => null);

    checkLocationPermission().then((value) {
      if (value == true) {
        GeofenceManager()
          ..buildEventCallback(_onGeofenceEvent)
          ..initialize().then((value) => null);
        GeofenceManager().register("TDI", 37.4881, 127.0117, 30.0);

        LocationService().initialize().then((_) {
          LocationService().start();
        });
      }
    });

    super.initState();
  }

  Future<void> _readTokenComplete(String json) async {
    if (json.isEmpty == false) {
      TDIUser.token = TDIToken.formJson(jsonDecode(json));
    } else {
      TDIUser.token = null;
    }
    setState(() => TDIUser.readUserTokenJSON = TDIUser.account != null);
  }

  Future<void> _readAcountComplete(String json) async {
    if (json.isEmpty == false) {
      TDIUser.account = TDIAccount.formJson(jsonDecode(json));
    } else {
      TDIUser.account = null;
    }
    setState(() => TDIUser.readUserJSON = TDIUser.account != null);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    var cur = Get.currentRoute;
    if (cur == Pages.nameBeacon) {
      BeaconManager().changeAppLifecycleState(state);
    }
    if (kIsPushLink == true) {
      if (state == AppLifecycleState.resumed) {
        if (cur != Pages.nameGroupware) {
          Get.toNamed(Pages.nameGroupware);
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
        fontFamily: ASSETS.font,
      ),
      getPages: Pages.container,
      initialRoute: Pages.nameSplash,
      defaultTransition: Transition.fadeIn,
      transitionDuration: Duration(seconds: 1),
    );
  }

  void _onMessage(RemoteMessage message) {
    slog.i("message: ${message.notification!.title!}/${message.notification!.body!}");
    showSnackBar(message.notification!.title!, message.notification!.body!);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    slog.i("message: ${message.notification!.title!}/${message.notification!.body!}");
    // showSnackBar(message.notification!.title!, message.notification!.body!);
    kIsPushLink = false;
    if (message.data.isNotEmpty == true) {
      kIsPushLink = message.data.keys.contains("link");
      if (kIsPushLink == true) {
        kPushLinkURL = message.data["link"];
      }
    }
  }

  void _onGeofenceEvent(dynamic data) {
    slog.i("geofence event: $data");
    showToastMessage("geofence event: $data");
  }
}
