import 'package:flutter/material.dart';
import 'package:hr_project_flutter/Page/HomePage.dart';
import 'package:lottie/lottie.dart';

void main() async {
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

  @override
  Widget build(BuildContext context) {
    if (_showAnimation == true)
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: Lottie.asset(
              'assets/splash.json',
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
    else
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      );
  }
}
