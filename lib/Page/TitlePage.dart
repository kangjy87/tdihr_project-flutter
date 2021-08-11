import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/General/AuthManager.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/LocalAuthManager.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/General/ToastMessage.dart';
import 'package:hr_project_flutter/Page/Pages.dart';

class TitlePage extends StatefulWidget {
  @override
  TitlePageState createState() => TitlePageState();
}

class TitlePageState extends State<TitlePage> {
  bool _signining = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('TDI - Sign in with Google'),
      // ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              child: WillPopScope(
                onWillPop: () => _goBack(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildMenu(),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Text('ver. $appVersion'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login(RESULT_TYPE result) {
    switch (result) {
      case RESULT_TYPE.LOGIN_SUCCESS:
        if (localAuthManager.authResult == LOCAL_AUTH_RESULT.NO_AUTHORIZED) {
          Get.toNamed(PAGES.tdiGroupware);
          setState(() {});
        } else {
          if (localAuthManager.authenticated == true) {
            Get.toNamed(PAGES.tdiGroupware);
            setState(() {});
          }
        }
        break;
      case RESULT_TYPE.LOGIN_EMAIL_ERROR:
        TDIUser.clearLoginData();
        toastMessage(MESSAGES.errLoginEmail);
        break;
      case RESULT_TYPE.LOGIN_FAILED:
        TDIUser.clearLoginData();
        toastMessage(MESSAGES.errLoginFailed);
        break;
      default:
    }
  }

  List<Widget> _buildMenu() {
    List<Widget> widgets = [];

    widgets.add(_buildTDITitle());
    widgets.add(SizedBox(height: 100));
    widgets.add(_buildSigninButton());
    widgets.add(SizedBox(height: 1));

    if (_signining == true)
      widgets.add(_buildSigniningProgress());
    else if (TDIUser.isAleadyLogin == true) {
      if (localAuthManager.authenticated == true)
        widgets.add(_buildTDIGroupwareButton());
      else {
        if (localAuthManager.authResult == LOCAL_AUTH_RESULT.NO_AUTHORIZED)
          widgets.add(_buildTDIGroupwareButton());
        else
          widgets.add(_buildAuthenticateButton());
      }
    }

    return widgets;
  }

  Widget _buildTDITitle() {
    return Container(
      padding: const EdgeInsets.only(top: 200, bottom: 10, left: 50, right: 50),
      child: Image.asset(ASSETS.tdiLogo, width: 200),
    );
  }

  Widget _buildSigninButton() {
    return ElevatedButton(
      onPressed: () {
        if (TDIUser.isAleadyLogin == false) {
          _signining = true;
          setState(() {});
          authManager.googleSingIn().then(
              (value) => {_login(value), _signining = false, if (value != RESULT_TYPE.LOGIN_SUCCESS) setState(() {})});
        } else {
          authManager.googleSignOut().then((value) => {
                _signining = false,
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
          )),
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
            Text(TDIUser.account == null ? STRINGS.googleLogin : TDIUser.account!.name + " " + STRINGS.logout,
                style: const TextStyle(color: Color(0xff454f63), fontSize: 15), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildSigniningProgress() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      width: 300,
      // height: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            STRINGS.signining,
            style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
            textAlign: TextAlign.center,
          ),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTDIGroupwareButton() {
    return ElevatedButton(
      onPressed: () => Get.toNamed(PAGES.tdiGroupware),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
              side: BorderSide(color: const Color(0xffe8e8e8), width: 3),
            ),
          )),
      child: Container(
        width: 300,
        height: 30,
        margin: EdgeInsets.only(top: 3, bottom: 3),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              STRINGS.tdiGroupware,
              style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticateButton() {
    return ElevatedButton(
      onPressed: () => localAuthManager.authenticate().then((value) {
        if (value == LOCAL_AUTH_RESULT.AUTHORIZED) Get.toNamed(PAGES.tdiGroupware);
      }),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
              side: BorderSide(color: const Color(0xffe8e8e8), width: 3),
            ),
          )),
      child: Container(
        width: 300,
        height: 30,
        margin: EdgeInsets.only(top: 3, bottom: 3),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              STRINGS.authenticate,
              style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    return Future.value(false);
  }
}
