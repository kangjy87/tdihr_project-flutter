import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/Page/Pages.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
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
            if (TDIUser.isAleadyLogin == true)
              Get.toNamed(PAGES.tdiGroupware);
            else
              Get.toNamed(PAGES.title);
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
    return Scaffold(
      body: SafeArea(
        child: Container(
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
}
