import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/FileIO.dart';
import 'package:hr_project_flutter/General/ToastMessage.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/General/Logger.dart';

class SigninPage extends StatefulWidget {
  @override
  SigninPageState createState() => SigninPageState();
}

class SigninPageState extends State<SigninPage> {
  final FirebaseAuth fAuth = FirebaseAuth.instance;
  final GoogleSignIn gSignIn = GoogleSignIn();
  User? fCurUser;
  String? urlPhoto = "";
  String? idTokenGoogle = "";

  String? _lastFirebaseResponse = "";
  bool readUserJSON = false;
  bool readUserTokenJSON = false;

  setLastFBMessage(String msg) {
    _lastFirebaseResponse = msg;
  }

  getLastFBMessage() {
    String? returnValue = _lastFirebaseResponse;
    _lastFirebaseResponse = null;
    return returnValue;
  }

  @override
  void initState() {
    super.initState();

    readText(COMMON.FILE_USER_JSON).then((json) => {
          COMMON.TDI_USER = TDIUser.formJson(jsonDecode(json)),
          setState(() {
            readUserJSON = COMMON.TDI_USER != null;
          })
        });

    readText(COMMON.FILE_USER_TOKEN_JSON).then((json) => {
          COMMON.TDI_TOKEN = TDIToken.formJson(jsonDecode(json)),
          setState(() {
            readUserTokenJSON = COMMON.TDI_USER != null;
            if (readUserTokenJSON == true)
              Get.toNamed(COMMON.PAGE_TDI_GROUPWARE);
          })
        });
  }

  Future<bool> googleSingIn() async {
    try {
      final GoogleSignInAccount? gUser = await gSignIn.signIn();
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final User? fUser = (await fAuth.signInWithCredential(credential)).user;
      assert(fUser!.email != null);
      assert(fUser!.displayName != null);
      assert(!fUser!.isAnonymous);
      // ignore: unnecessary_null_comparison
      assert(await fUser!.getIdToken() != null);

      fCurUser = fAuth.currentUser;
      assert(fUser!.uid == fCurUser!.uid);
      idTokenGoogle = await fUser!.getIdToken();

      String platformOS = COMMON.OS_NONE;
      if (Platform.isAndroid == true)
        platformOS = COMMON.OS_AOS;
      else if (Platform.isIOS) platformOS = COMMON.OS_IOS;
      COMMON.TDI_USER = TDIUser(COMMON.PROVIDER_GOOGLE, fUser.uid, fUser.email!,
          fUser.displayName!, platformOS);
      var response = await Dio()
          .post(COMMON.URL_TDI_LOGIN, data: COMMON.TDI_USER!.toData());

      if (response.statusCode == 200) {
        COMMON.TDI_TOKEN = TDIToken.formJson(response.data);

        writeJSON(COMMON.FILE_USER_JSON, COMMON.TDI_USER!.toJson());
        writeJSON(COMMON.FILE_USER_TOKEN_JSON, COMMON.TDI_TOKEN!.toJson());
        slog.i('user info : ${COMMON.TDI_USER!.toJson()}');
        slog.i('token:' + COMMON.TDI_TOKEN!.token);

        setState(() {
          urlPhoto = fUser.photoURL;
        });
      } else {
        slog.e(response);
        toastMessage(COMMON.ERROR_LOGIN);
        return false;
      }

      return true;
    } on Exception catch (e) {
      slog.e(e.toString());
      List<String> result = e.toString().split(", ");
      setLastFBMessage(result[0]);
      googleSignOut();
      toastMessage(COMMON.ERROR_LOGIN);
      return false;
    }
  }

  void googleSignOut() async {
    await fAuth.signOut();
    await gSignIn.signOut();

    deleteFile(COMMON.FILE_USER_JSON);
    deleteFile(COMMON.FILE_USER_TOKEN_JSON);

    COMMON.TDI_USER = null;
    COMMON.TDI_TOKEN = null;

    setState(() {
      urlPhoto = "";
      idTokenGoogle = "";
    });

    slog.i("User Sign Out");
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
            tdiTitle(),
            SizedBox(height: 100),
            signinButton(),
            SizedBox(height: 1),
            if (COMMON.TDI_TOKEN != null) goTDIGroupwareButton()
          ],
        ),
      ),
    );
  }

  Widget tdiTitle() {
    return Container(
      padding: const EdgeInsets.only(top: 200, bottom: 10, left: 50, right: 50),
      child: Image.asset(
        COMMON.ASSET_TDI_LOGO,
        width: 200,
      ),
    );
  }

  Widget signinButton() {
    return ElevatedButton(
      onPressed: () {
        if (COMMON.TDI_TOKEN == null) {
          googleSingIn().then((value) =>
              {if (value == true) Get.toNamed(COMMON.PAGE_TDI_GROUPWARE)});
        } else {
          googleSignOut();
        }
      },
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: const Color(0xffe8e8e8), width: 2),
          ))),
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
                    style:
                        const TextStyle(color: Color(0xff454f63), fontSize: 15),
                    textAlign: TextAlign.center),
              ])),
    );
  }

  Widget goTDIGroupwareButton() {
    return ElevatedButton(
      onPressed: () => Get.toNamed(COMMON.PAGE_TDI_GROUPWARE),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: const Color(0xffe8e8e8), width: 2),
          ))),
      child: Container(
        width: 300,
        height: 30,
        margin: EdgeInsets.only(top: 3, bottom: 3),
        alignment: Alignment.center,
        child: Text(COMMON.TDI_GROUPWARE,
            style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
            textAlign: TextAlign.center),
      ),
    );
  }
}
