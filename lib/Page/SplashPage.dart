import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/Auth/LocalAuthManager.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/Page/Pages.dart';
import 'package:lottie/lottie.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  void _goNextStep() {
    if (kIsPushLink == true) {
      Get.toNamed(Pages.nameGroupware);
    } else {
      if (TDIUser.isAleadyLogin == true) {
        LocalAuthManager().authenticate().then(
          (value) {
            switch (value) {
              case LOCAL_AUTH_RESULT.SUCCESS:
              case LOCAL_AUTH_RESULT.NO_AUTHORIZE:
                print('afasdfs>>>>>>>>>>>>>!!!!!!!!!!!!!!!');
                Get.toNamed(Pages.nameGroupware); // local auth 성공 or local auth가 없으면 groupware page로 이동
                break;
              case LOCAL_AUTH_RESULT.FAILED:
                Get.toNamed(Pages.nameTitle);
                break;
            }
          },
        );
      } else {
        Get.toNamed(Pages.nameTitle);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this)
      ..addStatusListener(
        (status) {
          if (status == AnimationStatus.completed) {
            _goNextStep();
            setState(() {});
          }
        },
      );
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
