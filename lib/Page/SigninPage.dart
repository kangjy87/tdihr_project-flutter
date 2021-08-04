import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/General/FileIO.dart';
import 'package:hr_project_flutter/General/AuthManager.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/General/ToastMessage.dart';
import 'package:hr_project_flutter/Page/Pages.dart';

class SigninPage extends StatefulWidget {
  @override
  SigninPageState createState() => SigninPageState();
}

class SigninPageState extends State<SigninPage> {
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
            if (TDIUser.readUserTokenJSON == true)
              Get.toNamed(PAGES.tdiGroupware);
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('TDI - Sign in with Google'),
      // ),
      body: Center(
        child: Column(
          children: <Widget>[
            _tdiTitle(),
            SizedBox(height: 100),
            _buttonSignin(),
            SizedBox(height: 1),
            if (TDIUser.token != null) _buttonTDIGroupware()
          ],
        ),
      ),
    );
  }

  void _login(RESULT_TYPE result) {
    switch (result) {
      case RESULT_TYPE.SUCCESS:
        Get.toNamed(PAGES.tdiGroupware);
        break;
      case RESULT_TYPE.FAILED:
        TDIUser.clearLoginData();
        toastMessage(MESSAGES.errLogin);
        break;
      case RESULT_TYPE.EXCEPTION:
        TDIUser.clearLoginData();
        toastMessage(MESSAGES.errLogin);
        break;
      default:
    }
  }

  Widget _tdiTitle() {
    return Container(
      padding: const EdgeInsets.only(top: 200, bottom: 10, left: 50, right: 50),
      child: Image.asset(
        ASSETS.tdiLogo,
        width: 200,
      ),
    );
  }

  Widget _buttonSignin() {
    return ElevatedButton(
      onPressed: () {
        if (TDIUser.token == null) {
          authManager.googleSingIn().then((value) => {
                setState(() {}),
                _login(value),
              });
        } else {
          authManager.googleSignOut().then((value) => {
                setState(() {}),
                TDIUser.clearLoginData(),
              });
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: const Color(0xffe8e8e8), width: 3),
          ),
        ),
      ),
      child: Container(
        width: 300,
        height: 30,
        margin: EdgeInsets.only(top: 3, bottom: 3),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              ASSETS.googleLogo,
              height: 30,
            ),
            Text(
                TDIUser.account == null
                    ? STRINGS.googleLogin
                    : TDIUser.account!.email + " " + STRINGS.logout,
                style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buttonTDIGroupware() {
    return ElevatedButton(
      onPressed: () => Get.toNamed(PAGES.tdiGroupware),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: const Color(0xffe8e8e8), width: 3),
          ),
        ),
      ),
      child: Container(
        width: 300,
        height: 30,
        margin: EdgeInsets.only(top: 3, bottom: 3),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image.asset(
            //   COMMON.ASSET_TDI_LOGO,
            //   height: 20,
            // ),
            // SizedBox(width: 30),
            Text(STRINGS.tdiGroupware,
                style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
