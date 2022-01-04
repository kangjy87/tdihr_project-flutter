
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/Beacon/BeaconManager.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/retrofit/beacon_list_dto.dart';
import 'package:hr_project_flutter/retrofit/beacon_login_dto.dart';
import 'package:hr_project_flutter/retrofit/group_ware_server.dart';
import 'package:hr_project_flutter/retrofit/tdi_servers.dart';

class GroupwareControler extends GetxController{
  var scannsServerSendEndCheck = false.obs ;
  var scanningCheck = false.obs ;
  var beaconList = RxList<BeaconData>([]).obs ;
  RxString strCommute = "in".obs ;
  RxString strServerRequest = "출/퇴근 실패".obs ;

  StreamSubscription<RangingResult>? _streamRanging;
  StreamSubscription<BluetoothState>? _streamBluetooth;
  Map<Region, List<Beacon>> regionBeacons = <Region, List<Beacon>>{};

  final regions = <Region>[];
  /**
   * 비콘 리스트 받아오기
   */
  getbeaconList(){
    TdiServers(groupWareServer: (GroupWareServer gws)async{
      await gws.beaconList(TDIUser.token!.token).then((value){
        List<String>? uuid = value.data!.uuid!;
        for(int i = 0 ; i < uuid.length; i++){
          regions.add(Region(
              identifier: 'BeaconTdi_${i}',
              proximityUUID: uuid[i]));
        }
      }).catchError((Object obj) async {

      });
    });
  }
  /**
   * 비콘 모니터링 시작
   */
  Future<void> beaconRangingStart(Function onServerSend)async{
    await _listeningBluetooth();
    await _checkAllRequirements();
    await _beacon_ranging((){
      onServerSend();
    });
  }

  Future<void> _listeningBluetooth() async {
    _streamBluetooth = flutterBeacon.bluetoothStateChanged().listen((BluetoothState state) async {

    });
  }
  Future<void> _checkAllRequirements() async {
    await flutterBeacon.bluetoothState;
    await flutterBeacon.authorizationStatus;
    await flutterBeacon.checkLocationServicesIfEnabled;
  }
  Future<void> _beacon_ranging(Function onServerSend)async{
    scanningCheck.value = false ;
    if(regions.length == 0){
      regions.add(Region(
          identifier: 'TDI_Mars',
          proximityUUID: 'fda50693-a4e2-4fb1-afcf-c6eb07647821'));
      regions.add(Region(
          identifier: 'TDI_2F',
          proximityUUID: 'fda50693-a4e2-4fb1-afcf-c6eb07647822'));
      regions.add(Region(
          identifier: 'TDI_3F',
          proximityUUID: 'fda50693-a4e2-4fb1-afcf-c6eb07647823'));
      regions.add(Region(
          identifier: 'TDI_4F',
          proximityUUID: 'fda50693-a4e2-4fb1-afcf-c6eb07647824'));
      regions.add(Region(
          identifier: 'TDI_5F',
          proximityUUID: 'fda50693-a4e2-4fb1-afcf-c6eb07647825'));
    }
    //STATE_ON
    await flutterBeacon.initializeScanning;
    _streamRanging  = flutterBeacon.ranging(regions).listen((RangingResult result) async {
      print('>>>>>>>>>>뭥미!!!!!!!!!!!!!!!!');
      print('11111???>>>>>>>>>>>>>>>>>${await flutterBeacon.bluetoothState}');
      print('22222???>>>>>>>>>>>>>>>>>${await flutterBeacon.authorizationStatus}');
      print('33333???>>>>>>>>>>>>>>>>>${await flutterBeacon.checkLocationServicesIfEnabled}');
      if(!scanningCheck.value){
        scanningCheck.value = true ;
        Timer.periodic(Duration(seconds: 5), (timer) {
          beaconRangingStop();
          timer.cancel();
          // for(List<Beacon> in _regionBeacons.values)
          // _regionBeacons.values.forEach((list) {
          //   print('!!!!!!!!!!!!!!!!!!!!!!!dfgdffgdfgdfgdgdgdgdgdgdgdff${beaconList.value.length}');
          //   for(Beacon b in list){
          //     print('새로운!!!!${b.macAddress}구른다!!!!!!!!!!!!!!!!${b.rssi}');
          //     BeaconData data = BeaconData();
          //     data.bssid = b.macAddress ;
          //     data.rssi = b.rssi ;
          //     beaconList.value.add(data);
          //   }
          // });
          // print('새로운!!sdfsdfsdfsdfsdfsdfsdfgsdgsdgsdf!');
          onServerSend();
        });
      }
      beaconList.value.clear();
      print("음트트트트트트트!!!>>>>>>>>${result.region}?????????>>>>>>>>>>>>>>>>${result.beacons.length}");
      if(result.beacons.length > 0){
        regionBeacons[result.region] = result.beacons;
        print('새로운!!!!구른다!!!!!!!!!!!!!!!!${regionBeacons.length}');
      }
    });
  }
  /**
   * 비콘 모니터링 멈춤
   */
  beaconRangingStop(){
    _streamBluetooth?.cancel();
    _streamRanging?.cancel();
    BeaconManager().close();
  }

  /**
   * 서버에 값을 보낸다.
   */
  serverSend(Function completion){
    String strInOut = strCommute.value == "in" ? "출근":"퇴근" ;
    if(beaconList.value.length > 0){
      TdiServers(groupWareServer: (GroupWareServer gws)async{
        SendBeaconLoginDto sendData = SendBeaconLoginDto();
        sendData.token = TDIUser.token!.token;
        sendData.commute = strCommute.value ;
        sendData.data = beaconList.value ;
        await gws.inAndOut(sendData).then((value){
          scannsServerSendEndCheck.value = true ;

          /**
           * code 0 : 정상처리
           *    100 : 이미 출근처리됨
           *    110 : 이미 퇴근처리됨
           *    200 : 미출근 시 퇴근요청함
           *    300 : 외부에서 출퇴근요청함
           */
          // int? code = value.code ;
          // switch(code){
          //   case 0 :
          //     strServerRequest.value = "${strInOut} 완료" ;
          //     Get.back();
          //     break ;
          //   case 100 :
          //     strServerRequest.value = "이미 출근처리됨" ;
          //     break ;
          //   case 110 :
          //     strServerRequest.value = "이미 퇴근처리됨" ;
          //     break ;
          //   case 200 :
          //     strServerRequest.value = "미출근 시 퇴근요청함" ;
          //     break ;
          //   case 300 :
          //     strServerRequest.value = "외부에서 ${strInOut}근요청함" ;
          //     break ;
          //   default:
          //     strServerRequest.value = "출/퇴근 실패" ;
          //     break ;
          // }
          // Fluttertoast.showToast(
          //     msg: strServerRequest.value,
          //     toastLength: Toast.LENGTH_SHORT,
          //     gravity: ToastGravity.BOTTOM,
          //     timeInSecForIosWeb: 1,
          //     fontSize: 16.0
          // );
          completion(strCommute.value,value.result!,value.code!);
          Get.back();
        }).catchError((Object obj) async {
          scannsServerSendEndCheck.value = true ;
          // strServerRequest.value = "에러!\n관리자에게 문의해주세요." ;
          completion(strCommute.value,"fail",400);
          Get.back();
        });
      });
    }else{
      scannsServerSendEndCheck.value = true ;
      Get.back();
      // strServerRequest.value = "에러!\n블루투스 재시작후 재시도 해주세요.!" ;
      completion(strCommute.value,"fail",500);
    }
  }
}

class GroupwareBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupwareControler>(() => GroupwareControler());
  }
}
