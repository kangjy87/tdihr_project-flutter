import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hr_project_flutter/General/FileIO.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';

enum GOOGLE_AUTH_RESULT {
  SUCCESS,
  FAILED,
  ERROR_EMAIL,
}

class AuthManager {
  static final AuthManager _instance = AuthManager._internal();

  factory AuthManager() {
    return _instance;
  }

  AuthManager._internal();

  final FirebaseAuth _fbAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _fbCurUser;
  String? _urlPhoto;
  String? _googleIDToken;
  String? _lastError;

  String? get urlPhoto {
    return _urlPhoto;
  }

  String? get googleIDToken {
    return _googleIDToken;
  }

  set lastError(String? value) {
    _lastError = value;
    slog.i('Last Error : $_lastError');
  }

  String? get lastError {
    String? returnValue = _lastError;
    _lastError = null;
    return returnValue;
  }

  Future<GOOGLE_AUTH_RESULT> googleSingIn() async {
    try {
      final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
      if (gUser == null) return GOOGLE_AUTH_RESULT.FAILED;

      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final User? fUser = (await _fbAuth.signInWithCredential(credential)).user;

      _fbCurUser = _fbAuth.currentUser;
      assert(fUser!.uid == _fbCurUser!.uid);
      _googleIDToken = await fUser!.getIdToken();

      String platformOS = OS_TYPE.NONE.convertString;
      if (Platform.isAndroid == true)
        platformOS = OS_TYPE.AOS.convertString;
      else if (Platform.isIOS) platformOS = OS_TYPE.IOS.convertString;
      TDIUser.account = TDIAccount(PROVIDERS.google, fUser.uid, fUser.email!, fUser.displayName!, platformOS);
      var response = await Dio().post(URL.tdiAuth, data: TDIUser.account!.toData());

      if (response.statusCode == 200) {
        TDIUser.token = TDIToken.formJson(response.data);

        writeJSON(TDIUser.fileAccountJson, TDIUser.account!.toJson());
        writeJSON(TDIUser.fileTokenJson, TDIUser.token!.toJson());

        _urlPhoto = fUser.photoURL;

        slog.i('user info : ${TDIUser.account!.toJson()}');
        slog.i('token:' + TDIUser.token!.token);
      } else {
        slog.e(response);
        return GOOGLE_AUTH_RESULT.ERROR_EMAIL;
      }

      return GOOGLE_AUTH_RESULT.SUCCESS;
    } on Exception catch (e) {
      slog.e(e.toString());
      List<String> result = e.toString().split(", ");
      lastError = result[0];
      googleSignOut();
      return GOOGLE_AUTH_RESULT.ERROR_EMAIL;
    }
  }

  Future<void> googleSignOut() async {
    await _fbAuth.signOut();
    await _googleSignIn.signOut();

    _urlPhoto = "";
    _googleIDToken = "";

    slog.i("User Sign Out");
  }
}
