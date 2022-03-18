
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
  var strLogbeacon = "".obs ; // 재민씨 폰  테스트용
  var scannsServerSendEndCheck = false.obs ;
  var scanningCheck = false.obs ;
  var beaconList = RxList<BeaconData>([]).obs ;
  RxString strCommute = "in".obs ;
  RxString strServerRequest = "출/퇴근 실패".obs ;

  StreamSubscription<RangingResult>? _streamRanging;
  StreamSubscription<BluetoothState>? _streamBluetooth;
  // late Timer _timer ;
  Timer? scan_timer ;
  Timer? scan_allcount_timer ;
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
      // //테스트
      // regions.add(Region(
      //     identifier: 'Test1',
      //     proximityUUID: '4d9c357a-0640-11ec-9a03-0242ac130003'));
      // regions.add(Region(
      //     identifier: 'Test2',
      //     proximityUUID: '8fef2e11-d140-2ed1-2eb1-4138edcabe09'));
    }
    //STATE_ON
    await flutterBeacon.initializeScanning;
    if (_streamRanging != null) {
      if (_streamRanging!.isPaused) {
        _streamRanging?.resume();
        return;
      }
    }
    regionBeacons.clear();
    bool timerstart = false ;
    _streamRanging  = flutterBeacon.ranging(regions).listen((RangingResult result) async {
      print('>>>>>>>>>>뭥미!!!!!!!!!!!!!!!!');
      print('11111???>>>>>>>>>>>>>>>>>${await flutterBeacon.bluetoothState}');
      print('22222???>>>>>>>>>>>>>>>>>${await flutterBeacon.authorizationStatus}');
      print('33333???>>>>>>>>>>>>>>>>>${await flutterBeacon.checkLocationServicesIfEnabled}');

      print('>>>>>>>>>>>>>>>>>>>>>>>${timerstart}');
      if(!scanningCheck.value){
        scanningCheck.value = true ;
        scan_allcount_timer = Timer.periodic(Duration(seconds: 60), (timer){
          print('>>>>>>>>>>>>>>>>>>>>>>>>60초 타이머 입니다.>>>>>>>>>>>>${scan_timer}');
          /**
           * 만약 60초가 지난 후에 scan_timer(4초 타이머)가 널이 아니라는 소리는 스캔이 진행되고 있다는 소리이다.
           * 그러면 60초 카운터만 끝내고 스캔기능은 scan_timer(4초 타이머)에서 스캔을 멈추고 나머지 작업을 하게 하자
           * scan_timer(4초 타이머)가 널인경우는 60초가 지났지만 아무런 스캔을 못했다는 소리임으로 스캔을 끝낸다.
            */
          if(scan_timer == null){
            beaconRangingStop();
          }
          timer.cancel();
        });
      }
      if(timerstart){
        timerstart = false ; //타이머가 한번만 타게 하기 위하여 다시 초기화를 해주자.
          print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>4초 카운트 시작');
          scan_timer = Timer.periodic(Duration(seconds: 4), (timer) {
            strLogbeacon.value = "${strLogbeacon.value}\n    스캔끝!" ;
            /**
             * 60초가 안끝났지만 4초동안 스캔이 완료 되었으면 60초 타이머두 끝내주자.
             */
            if(scan_allcount_timer != null){
              scan_allcount_timer?.cancel();
            }
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
      // await _checkAllRequirements();
      beaconList.value.clear();
      if(strLogbeacon.value == ''){
        strLogbeacon.value = "    스캔작동중!!!!";
      }
      print("음트트트트트트트!!!>>>>>>>>${result.region}?????????>>>>>>>>>>>>>>>>${result.beacons.length}");
      if(result.beacons.length > 0){
        timerstart = true ;
        regionBeacons[result.region] = result.beacons;
        print('새로운!!!!구른다!!!!!!!!!!!!!!!!${regionBeacons.length}');
        strLogbeacon.value = "${strLogbeacon.value}\n    ${result.beacons[0].proximityUUID.toLowerCase()}" ;
      }
    });
  }
  /**
   * 비콘 모니터링 멈춤
   */
  beaconRangingStop(){
    if(_streamBluetooth != null){
      _streamBluetooth?.cancel();
    }
    if(_streamRanging != null){
      _streamRanging?.cancel();
    }
    if(scan_timer != null){
      scan_timer?.cancel();
    }
    // BeaconManager().close();
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
