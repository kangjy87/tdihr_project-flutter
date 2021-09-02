import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/Auth/LocalAuthManager.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/Page/Pages.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  void _goNextStep() {
    if (TDIUser.isAleadyLogin == true) {
      LocalAuthManager().authenticate().then((value) {
        switch (value) {
          case LOCAL_AUTH_RESULT.SUCCESS:
          case LOCAL_AUTH_RESULT.NO_AUTHORIZE:
            Get.toNamed(PAGES.tdiGroupware);
            break;
          case LOCAL_AUTH_RESULT.FAILED:
            Get.toNamed(PAGES.title);
            break;
        }
      });
    } else {
      Get.toNamed(PAGES.title);
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _goNextStep();
          setState(() {});
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
