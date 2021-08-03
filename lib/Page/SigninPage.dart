import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hr_project_flutter/Page/TDIGroupwarePage.dart';
import 'package:hr_project_flutter/Page/TDIUser.dart';
import 'package:hr_project_flutter/Utility/Logger.dart';

String tdiLoginUrl = 'https://dev.groupware.tdi9.com/api/app/auth';

class SigninPage extends StatefulWidget {
  @override
  SigninPageState createState() => SigninPageState();
}

class SigninPageState extends State<SigninPage> {
  final FirebaseAuth fAuth = FirebaseAuth.instance;
  final GoogleSignIn gSignIn = GoogleSignIn();

  TDIUser? tUser;
  TDIUserToken? tUserToken;

  User? curUser;
  String? name = "";
  String? email = "";
  String? url = "";
  String? idToken = "";
  String? uid = "";

  String? _lastFirebaseResponse = "";

  setLastFBMessage(String msg) {
    _lastFirebaseResponse = msg;
  }

  getLastFBMessage() {
    String? returnValue = _lastFirebaseResponse;
    _lastFirebaseResponse = null;
    return returnValue;
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

      curUser = fAuth.currentUser;
      assert(fUser!.uid == curUser!.uid);
      idToken = await fUser!.getIdToken();

      tUser =
          TDIUser("google", fUser.uid, fUser.email!, fUser.displayName!, 'aos');
      var response = await Dio().post(tdiLoginUrl, data: tUser!.toData());

      if (response.statusCode == 200) {
        slog.i(response);

        tUserToken = TDIUserToken.formJson(response.data);
        loginToken = tUserToken!.token;

        setState(() {
          name = fUser.displayName;
          email = fUser.email;
          url = fUser.photoURL;
          uid = fUser.uid;

          slog.i('email:' + email!);
          slog.i('name:' + name!);
          slog.i('url:' + url!);
          slog.i('idToken:' + idToken!);
          slog.i('uid:' + uid!);
        });
      } else {
        slog.e(response);
        return false;
      }

      return true;
    } on Exception catch (e) {
      slog.e(e.toString());
      List<String> result = e.toString().split(", ");
      setLastFBMessage(result[0]);
      googleSignOut();
      return false;
    }
  }

  void googleSignOut() async {
    await fAuth.signOut();
    await gSignIn.signOut();

    setState(() {
      name = "";
      email = "";
      url = "";
      idToken = "";
      uid = "";
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
            SizedBox(height: 10),
            if (email != "") goTDIGroupwareButton()
          ],
        ),
      ),
    );
  }

  Widget tdiTitle() {
    return Container(
      padding: const EdgeInsets.only(top: 200, bottom: 10, left: 50, right: 50),
      child: Image.asset(
        'assets/tdi_img.png',
        width: 200,
      ),
    );
  }

  Widget signinButton() {
    return ElevatedButton(
      onPressed: () {
        if (email == "") {
          googleSingIn();
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
          width: 260,
          // height: 30,
          margin: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
          alignment: Alignment.center,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/google.png',
                  height: 30,
                ),
                Text(
                    email == ""
                        ? 'Sign in with Google'
                        : email.toString() + " Sign out",
                    style:
                        const TextStyle(color: Color(0xff454f63), fontSize: 15),
                    textAlign: TextAlign.center),
              ])),
    );
  }

  Widget goTDIGroupwareButton() {
    return ElevatedButton(
      onPressed: () => Get.toNamed('/tdi_groupware'),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: const Color(0xffe8e8e8), width: 2),
          ))),
      child: Container(
        width: 260,
        height: 30,
        margin: EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
        alignment: Alignment.center,
        child: Text('TDI Groupware',
            style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
            textAlign: TextAlign.center),
      ),
    );
  }
}
