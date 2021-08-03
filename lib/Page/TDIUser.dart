class TDIUser {
  final String provider;
  final String token;
  final String email;
  final String name;
  final String os;

  TDIUser(this.provider, this.token, this.email, this.name, this.os);

  TDIUser.formJson(Map<String, dynamic> json)
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

class TDIUserToken {
  final String token;

  TDIUserToken(this.token);

  TDIUserToken.formJson(Map<String, dynamic> json) : token = json['token'];
  Map<String, dynamic> toJson() => {'token': token};
}
