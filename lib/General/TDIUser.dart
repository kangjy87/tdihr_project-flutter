import 'package:hr_project_flutter/General/FileIO.dart';

class TDIAccount {
  final String provider;
  final String token;
  final String email;
  final String name;
  final String os;

  TDIAccount(this.provider, this.token, this.email, this.name, this.os);

  TDIAccount.formJson(Map<String, dynamic> json)
      : provider = json['provider'],
        token = json['token'],
        email = json['email'],
        name = json['name'],
        os = json['os'];

  Map<String, dynamic> toJson() => {
        'provider': provider,
        'token': token,
        'email': email,
        'name': name,
        'os': os
      };

  toData() {
    return {
      'provider': provider,
      'token': token,
      'email': email,
      'name': name,
      'os': os
    };
  }
}

class TDIToken {
  final String token;

  TDIToken(this.token);

  TDIToken.formJson(Map<String, dynamic> json) : token = json['token'];
  Map<String, dynamic> toJson() => {'token': token};
}

class TDIUser {
  static String fileAccountJson = 'user.json';
  static String fileTokenJson = 'usert.json';

  static TDIAccount? account;
  static TDIToken? token;
  static bool readUserJSON = false;
  static bool readUserTokenJSON = false;

  static void clearLoginData() {
    deleteFile(fileAccountJson);
    deleteFile(fileTokenJson);
    account = null;
    token = null;
    readUserJSON = false;
    readUserTokenJSON = false;
  }
}
