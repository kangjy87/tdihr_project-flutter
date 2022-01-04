import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
part 'beacon_login_dto.g.dart';


@JsonSerializable ()
class BeaconData{
  String? bssid ;
  String? uuid ;
  String? major ;
  String? minor ;
  int? rssi ;
  BeaconData({
    this.bssid,
    this.uuid,
    this.major,
    this.minor,
    this.rssi
  });

  factory BeaconData.fromJson(Map<String, dynamic> json) => _$BeaconDataFromJson(json);
  Map<String, dynamic> toJson() => _$BeaconDataToJson(this);

}

@JsonSerializable ()
class SendBeaconLoginDto{
  String? token ;
  String? commute ;
  List<BeaconData>? data ;

  SendBeaconLoginDto({
    this.token,
    this.commute,
    this.data
  });

  factory SendBeaconLoginDto.fromJson(Map<String, dynamic> json) => _$SendBeaconLoginDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SendBeaconLoginDtoToJson(this);

}

@JsonSerializable ()
class getBeaconLoginDto{
  String? result ;
  int? code ;
  getBeaconLoginDto({
    this.result,
    this.code
  });
  factory getBeaconLoginDto.fromJson(Map<String, dynamic> json) => _$getBeaconLoginDtoFromJson(json);
  Map<String, dynamic> toJson() => _$getBeaconLoginDtoToJson(this);
}