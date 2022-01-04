import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
part 'beacon_list_dto.g.dart';


@JsonSerializable ()
class BeaconInfo{
  // List<String>? bssid ;
  List<String>? uuid ;

  BeaconInfo({
    // this.bssid,
    this.uuid,
  });

  factory BeaconInfo.fromJson(Map<String, dynamic> json) => _$BeaconInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BeaconInfoToJson(this);

}

@JsonSerializable ()
class SendBeaconListDto{
  String? token ;

  SendBeaconListDto({
    this.token,
  });

  factory SendBeaconListDto.fromJson(Map<String, dynamic> json) => _$SendBeaconListDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SendBeaconListDtoToJson(this);

}

@JsonSerializable ()
class GetBeaconListDto{
  String? result ;
  int? code ;
  BeaconInfo? data ;
  GetBeaconListDto({
    this.result,
    this.code,
    this.data
  });
  factory GetBeaconListDto.fromJson(Map<String, dynamic> json) => _$GetBeaconListDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GetBeaconListDtoToJson(this);
}