import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:hr_project_flutter/Page/GroupwareControler.dart';
import 'package:hr_project_flutter/retrofit/beacon_login_dto.dart';
import 'package:lottie/lottie.dart';


inAndOutWorkshowDialog_ios(BuildContext buidContext){
  GroupwareControler groupwareControler =Get.find<GroupwareControler>();
  groupwareControler.strServerRequest.value = groupwareControler.strCommute.value == "in" ? "출근 체크중 입니다...":"퇴근 체크중 입니다..." ;
  return showDialog(
      context: buidContext,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(32.0))),
          contentPadding: EdgeInsets.only(top: 10.0),
          content: Container(
            width: 300,
            height: 300,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children :[
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(0,0, 0, 0),
                        child: Lottie.asset('assets/splash.json'),
                        height: 300,
                        width: 300,),
                      Obx(()=>Container(
                        padding: EdgeInsets.fromLTRB(50,180, 50, 90),
                        width: double.infinity,
                        child: Text(groupwareControler.strServerRequest.value
                            ,textAlign: TextAlign.center
                            ,style: TextStyle(
                                fontSize: 18,
                                color: Color(0xff454f63))),
                      )),
                    ],
                  )
                ]
            ),
          ),
        );
      });
}

inAndOutWorkScanns_ios(Function onServerSend )async{
  GroupwareControler groupwareControler =Get.find<GroupwareControler>();
  await groupwareControler.beaconRangingStart((){
    List<BeaconData> beaconList = [] ;
    groupwareControler.regionBeacons.values.forEach((list) {
      for(Beacon b in list){
        print('?????????????새로운!!!!${b.macAddress}구른다!!!!!!!!!!!!!!!!${b.major}>>>>>>>>>${b.minor}??>>>>>${b.proximityUUID}');
        BeaconData data = BeaconData();
        data.uuid = b.proximityUUID.toLowerCase() ;
        data.major = "${b.major}" ;
        data.minor = "${b.minor}" ;
        data.bssid = " ";
        data.rssi = b.rssi ;
        beaconList.add(data);
      }
    });
    onServerSend(beaconList);
    // print('새새새새샛새샗운>>>>>>>>>>>>>>>>>>>>>${groupwareControler.beaconList.value.length}');
  });
}