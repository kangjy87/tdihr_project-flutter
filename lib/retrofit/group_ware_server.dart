import 'dart:convert';

import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'beacon_list_dto.dart';
import 'beacon_login_dto.dart';
part 'group_ware_server.g.dart';

@RestApi(baseUrl:"https://groupware.tdi9.com")
abstract class GroupWareServer {
  factory GroupWareServer(Dio dio,{String baseUrl}) = _GroupWareServer ;
  //로그인 로그아웃
  @POST("/api/beacon/log")
  @Utf8Codec()
  Future<getBeaconLoginDto> inAndOut(
      @Body() SendBeaconLoginDto task
      );

  //비콘 리스트
  @GET("/api/beacon")
  @Utf8Codec()
  Future<GetBeaconListDto> beaconList(
      @Query("token") String token,
      // @Body() SendBeaconListDto task
      );
}