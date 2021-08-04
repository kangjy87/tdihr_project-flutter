import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/Page/Pages.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';

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
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _showAnimation = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _showAnimation = false;
          });
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  MaterialApp _splashScreen() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: Lottie.asset(
            ASSETS.lottieSplash,
            fit: BoxFit.contain,
            controller: _animationController,
            onLoaded: (composition) {
              _animationController
                ..duration = composition.duration
                ..reset()
                ..forward();
            },
          ),
        ),
      ),
    );
  }

  GetMaterialApp _mainTitle() {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      getPages: Pages.container,
      initialRoute: PAGES.title,
      defaultTransition: Transition.noTransition,
      // home: TDIGroupwarePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showAnimation == true)
      return _splashScreen();
    else
      return _mainTitle();
  }
}
