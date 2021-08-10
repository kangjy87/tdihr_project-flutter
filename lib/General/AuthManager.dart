import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hr_project_flutter/General/FileIO.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';

AuthManager authManager = AuthManager();

class AuthManager {
  final FirebaseAuth fAuth = FirebaseAuth.instance;
  final GoogleSignIn gSignIn = GoogleSignIn();
  User? fCurUser;
  String? urlPhoto = "";
  String? idTokenGoogle = "";

  String? _lastFirebaseResponse = "";

  setLastFBMessage(String msg) {
    _lastFirebaseResponse = msg;
  }

  getLastFBMessage() {
    String? returnValue = _lastFirebaseResponse;
    _lastFirebaseResponse = null;
    return returnValue;
  }

  Future<RESULT_TYPE> googleSingIn() async {
    try {
      final GoogleSignInAccount? gUser = await gSignIn.signIn();
      if (gUser == null) return RESULT_TYPE.LOGIN_FAILED;

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final User? fUser = (await fAuth.signInWithCredential(credential)).user;

      fCurUser = fAuth.currentUser;
      assert(fUser!.uid == fCurUser!.uid);
      idTokenGoogle = await fUser!.getIdToken();

      String platformOS = OS_TYPE.NONE.convertString;
      if (Platform.isAndroid == true)
        platformOS = OS_TYPE.AOS.convertString;
      else if (Platform.isIOS) platformOS = OS_TYPE.IOS.convertString;
      TDIUser.account =
          TDIAccount(PROVIDERS.google, fUser.uid, fUser.email!, fUser.displayName!, platformOS);
      var response = await Dio().post(URL.tdiAuth, data: TDIUser.account!.toData());

      if (response.statusCode == 200) {
        TDIUser.token = TDIToken.formJson(response.data);

        writeJSON(TDIUser.fileAccountJson, TDIUser.account!.toJson());
        writeJSON(TDIUser.fileTokenJson, TDIUser.token!.toJson());

        urlPhoto = fUser.photoURL;

        slog.i('user info : ${TDIUser.account!.toJson()}');
        slog.i('token:' + TDIUser.token!.token);
      } else {
        slog.e(response);
        return RESULT_TYPE.LOGIN_EMAIL_ERROR;
      }

      return RESULT_TYPE.LOGIN_SUCCESS;
    } on Exception catch (e) {
      slog.e(e.toString());
      List<String> result = e.toString().split(", ");
      authManager.setLastFBMessage(result[0]);
      googleSignOut();
      return RESULT_TYPE.LOGIN_EMAIL_ERROR;
    }
  }

  Future<void> googleSignOut() async {
    await fAuth.signOut();
    await gSignIn.signOut();

    urlPhoto = "";
    idTokenGoogle = "";

    slog.i("User Sign Out");
  }
}
