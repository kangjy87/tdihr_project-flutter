import 'package:hr_project_flutter/General/FileIO.dart';

class TDIAccount {
  final String provider;
  final String token;
  final String email;
  final String name;
  final String os;
  final String appversion;

  TDIAccount(this.provider, this.token, this.email, this.name, this.os,this.appversion);

  TDIAccount.formJson(Map<String, dynamic> json)
      : provider = json["provider"],
        token = json["token"],
        email = json["email"],
        name = json["name"],
        os = json["os"],
        appversion = json["app_version"];

  Map<String, dynamic> toJson() => {"provider": provider, "token": token, "email": email, "name": name, "os": os, "app_version": appversion};
}

class TDIToken {
  final String token;
  final String app_version ;
  final String app_path ;

  TDIToken(this.token, this.app_path, this.app_version);

  TDIToken.formJson(Map<String, dynamic> json)
      : token = json["token"],
        app_version = json["app_version"],
        app_path = json["app_path"];

  Map<String, dynamic> toJson() => {"token": token, "app_version": app_version, "app_path": app_path,};
}

class TDIUser {
  static String fileAccountJson = "user.json";
  static String fileTokenJson = "usert.json";

  static TDIAccount? account;
  static TDIToken? token;
  static bool readUserJSON = false;
  static bool readUserTokenJSON = false;

  static void clearData() {
    deleteFile(fileAccountJson);
    deleteFile(fileTokenJson);
    account = null;
    token = null;
    readUserJSON = false;
    readUserTokenJSON = false;
  }

  static bool get isAleadyLogin => token != null;
}
