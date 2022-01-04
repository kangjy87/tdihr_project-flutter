import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/retrofit/beacon_login_dto.dart';
import 'package:hr_project_flutter/retrofit/group_ware_server.dart';
import 'package:hr_project_flutter/retrofit/tdi_servers.dart';

class BleController extends GetxController{
  var isScanns = false.obs;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  var beacontList = RxList<BeaconData>([]).obs ;
  var scanResultList = RxList<ScanResult>([]).obs ;

  //////////////////////////////
  var scannsServerSendEndCheck = false.obs ;
  var scanningCheck = false.obs ;
  var beaconList = RxList<BeaconData>([]).obs ;
  RxString strCommute = "in".obs ;
  RxString strServerRequest = "출/퇴근 실패".obs ;
  //////////////////////////////

  @override
  void onInit() {
    print('여기오니???');
    initBle();
  }
  initBle() {
    // BLE 스캔 상태 얻기 위한 리스너
    flutterBlue.isScanning.listen((isScanning) {
      print('지금 상태는?????????${isScanning}');
      isScanns.value = isScanning ;
    });
  }
  //****서버에 값을 보낸다.
  serverSend(){
    String strInOut = strCommute.value == "in" ? "출근":"퇴근" ;
    print('출퇴근 상태는 ????${strCommute.value}>>>>>>>>>>>>>>>${strInOut}');

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
          int? code = value.code ;
          switch(code){
            case 0 :
              strServerRequest.value = "${strInOut} 완료" ;
              Get.back();
              break ;
            case 100 :
              strServerRequest.value = "이미 출근처리됨" ;
              break ;
            case 110 :
              strServerRequest.value = "이미 퇴근처리됨" ;
              break ;
            case 200 :
              strServerRequest.value = "미출근 시 퇴근요청함" ;
              break ;
            case 300 :
              strServerRequest.value = "외부에서 ${strInOut}근요청함" ;
              break ;
            default:
              strServerRequest.value = "출/퇴근 실패" ;
              break ;
          }
          Fluttertoast.showToast(
              msg: strServerRequest.value,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              fontSize: 16.0
          );
        }).catchError((Object obj) async {
          scannsServerSendEndCheck.value = true ;
          strServerRequest.value = "에러!\n${obj}" ;
          print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>여기222222222???${obj}');
        });
      });
    }else{
      scannsServerSendEndCheck.value = true ;
      strServerRequest.value = "에러!\n블루투스 재시작후 재시도 해주세요.!" ;
      Fluttertoast.showToast(
          msg: strServerRequest.value,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          fontSize: 16.0
      );
    }
  }
  start(){
    print('구른다!!1112312313123!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    if(!isScanns.value){
      // 스캔 중이 아니라면
      // 기존에 스캔된 리스트 삭제
      scanResultList.value.clear();
      // 스캔 시작, 제한 시간 4초
      flutterBlue.startScan(timeout: Duration(seconds: 4));
      // 스캔 결과 리스너
      flutterBlue.scanResults.listen((results) {
        // print('${results.length}>>>>>>>>${results[0].device.id}');
        // List<ScanResult> 형태의 results 값을 scanResultList에 복사
        scanResultList.value.clear();
        scanResultList.value.addAll(results.where((element) => deviceName(element) != "N/A"));
        // scanResultList.value.addAll(results.where((element) =>
        //       element.device.id.id == "7C:66:9D:90:2F:96"
        //           || element.device.id.id == "DD:0D:30:46:3A:41"));
        print('구른다!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        for (ScanResult r in scanResultList.value) {
          BeaconData data = BeaconData();
          data.uuid = r.device.id.id ;
          data.rssi = r.rssi ;
          print('${r.device.name}구른다!!!!!!!!!!!!!!!!${r.rssi}');//proximityUUID
          beacontList.value.add(data);
        }
        // print('${results.length}>>>>>>>>>>>>>>>>>>>${scanResultList.value.length}');
        // UI 갱신
      });
    }
  }
  stop(){
    if(isScanns.value){
      // 스캔 중이라면 스캔 정지
      flutterBlue.stopScan();
    }
  }

  String deviceName(ScanResult r) {
    String name = '';

    if (r.device.name.isNotEmpty) {
      // device.name에 값이 있다면
      name = r.device.name;
    } else if (r.advertisementData.localName.isNotEmpty) {
      // advertisementData.localName에 값이 있다면
      name = r.advertisementData.localName;
    } else {
      // 둘다 없다면 이름 알 수 없음...
      name = 'N/A';
    }
    return name ;
  }
}

class BleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BleController>(() => BleController());
  }
}
