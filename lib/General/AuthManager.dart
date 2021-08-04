import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/FileIO.dart';
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

  Future<int> googleSingIn() async {
    try {
      final GoogleSignInAccount? gUser = await gSignIn.signIn();
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final User? fUser = (await fAuth.signInWithCredential(credential)).user;

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

        urlPhoto = fUser.photoURL;

        slog.i('user info : ${COMMON.TDI_USER!.toJson()}');
        slog.i('token:' + COMMON.TDI_TOKEN!.token);
      } else {
        slog.e(response);
        return COMMON.LOGIN_FAILED;
      }

      return COMMON.LOGIN_SUCCESS;
    } on Exception catch (e) {
      slog.e(e.toString());
      List<String> result = e.toString().split(", ");
      authManager.setLastFBMessage(result[0]);
      googleSignOut();
      return COMMON.LOGIN_EXCEPTION;
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
