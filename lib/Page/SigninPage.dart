import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/FileIO.dart';
import 'package:hr_project_flutter/General/AuthManager.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/General/ToastMessage.dart';

class SigninPage extends StatefulWidget {
  @override
  SigninPageState createState() => SigninPageState();
}

class SigninPageState extends State<SigninPage> {
  @override
  void initState() {
    super.initState();

    readText(COMMON.FILE_USER_JSON).then((json) => {
          COMMON.TDI_USER = TDIUser.formJson(jsonDecode(json)),
          setState(() {
            COMMON.readUserJSON = COMMON.TDI_USER != null;
          })
        });

    readText(COMMON.FILE_USER_TOKEN_JSON).then((json) => {
          COMMON.TDI_TOKEN = TDIToken.formJson(jsonDecode(json)),
          setState(() {
            COMMON.readUserTokenJSON = COMMON.TDI_USER != null;
            if (COMMON.readUserTokenJSON == true)
              Get.toNamed(COMMON.PAGE_TDI_GROUPWARE);
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
            if (COMMON.TDI_TOKEN != null) _buttonTDIGroupware()
          ],
        ),
      ),
    );
  }

  void _login(int result) {
    switch (result) {
      case COMMON.LOGIN_SUCCESS:
        Get.toNamed(COMMON.PAGE_TDI_GROUPWARE);
        break;
      case COMMON.LOGIN_FAILED:
        COMMON.clearLoginData();
        toastMessage(COMMON.ERROR_LOGIN);
        break;
      case COMMON.LOGIN_EXCEPTION:
        COMMON.clearLoginData();
        toastMessage(COMMON.ERROR_LOGIN);
        break;
      default:
    }
  }

  Widget _tdiTitle() {
    return Container(
      padding: const EdgeInsets.only(top: 200, bottom: 10, left: 50, right: 50),
      child: Image.asset(
        COMMON.ASSET_TDI_LOGO,
        width: 200,
      ),
    );
  }

  Widget _buttonSignin() {
    return ElevatedButton(
      onPressed: () {
        if (COMMON.TDI_TOKEN == null) {
          authManager.googleSingIn().then((value) => {
                setState(() {}),
                _login(value),
              });
        } else {
          authManager.googleSignOut().then((value) => {
                setState(() {}),
                COMMON.clearLoginData(),
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
              COMMON.ASSET_GOOGLE,
              height: 30,
            ),
            Text(
                COMMON.TDI_USER == null
                    ? COMMON.LOGIN_GOOGLE
                    : COMMON.TDI_USER!.email + " " + COMMON.LOGOUT,
                style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buttonTDIGroupware() {
    return ElevatedButton(
      onPressed: () => Get.toNamed(COMMON.PAGE_TDI_GROUPWARE),
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
            Text(COMMON.TDI_GROUPWARE,
                style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
