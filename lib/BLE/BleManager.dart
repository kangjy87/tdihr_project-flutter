import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/retrofit/beacon_login_dto.dart';
import 'package:hr_project_flutter/retrofit/group_ware_server.dart';
import 'package:hr_project_flutter/retrofit/tdi_servers.dart';

class BleManager extends GetxController{



  var beaconList = RxList<BeaconData>([]).obs ;
  RxString strCommute = "in".obs ;
  RxString strServerRequest = "출/퇴근 실패".obs ;

  //****서버에 값을 보낸다.
  serverSend(Function completion){
    String strInOut = strCommute.value == "in" ? "출근":"퇴근" ;
    if(beaconList.value.length > 0){
      TdiServers(groupWareServer: (GroupWareServer gws)async{
        SendBeaconLoginDto sendData = SendBeaconLoginDto();
        sendData.token = TDIUser.token!.token;
        sendData.commute = strCommute.value ;
        sendData.data = beaconList.value ;
        await gws.inAndOut(sendData).then((value){

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

          // strServerRequest.value = "에러!\n관리자에게 문의해주세요." ;
          completion(strCommute.value,"fail",400);
          Get.back();
        });
      });
    }else{

      strServerRequest.value = "에러!\n블루투스 재시작후 재시도 해주세요.!" ;

      completion(strCommute.value,"fail",500);
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

class BleManagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BleManager>(() => BleManager());
  }
}
