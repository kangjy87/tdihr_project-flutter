import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/retrofit/beacon_login_dto.dart';
import 'package:hr_project_flutter/retrofit/group_ware_server.dart';
import 'package:hr_project_flutter/retrofit/tdi_servers.dart';
import 'package:permission_handler/permission_handler.dart';

import 'BleController.dart';
import 'in_out_work.dart';

class BlePage extends GetView<BleController>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("비콘"),
        actions: [
          Obx(() => _start(context)),
          Obx(() => _stop(context)),
        ],
      ),
      body: Column(
        children: [
          SizedBox(width: double.infinity,height: 500,child: Obx(() => _buildBodyList(context)),),
          GestureDetector(
            child: Container(
              // padding: EdgeInsets.all(30),
              width: 200,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(''),
                    ),
                    Container(
                      width: 120,
                      child: Text('출근',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: Color(0xff454f63))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(''),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () async{
              checkLocationServices((){
                print('dsdfsdfsdfsdfs');
              },context);
              // bool checkLocation = await flutterBeacon.checkLocationServicesIfEnabled ;
              // if(!checkLocation){
              //   if (Platform.isAndroid) {
              //     await flutterBeacon.openLocationSettings;
              //   } else if (Platform.isIOS) {
              //     await showDialog(
              //         context: context,
              //         builder: (context) {
              //           return AlertDialog(
              //             title: Text("위치 서비스 활성화"),
              //             content: Text("위치 서비스를 활성화해주세요."),
              //             actions: [
              //               TextButton(
              //                 onPressed: () => Navigator.pop(context),
              //                 child: Text("OK"),
              //               ),
              //             ],
              //           );
              //         });
              //   }
              // }
              // controller.strCommute.value = "in" ;
              // inAndOutWork(context,(){
              //   controller.serverSend();
              //   // bleController.scannsServerSendEndCheck.value = true ;
              //   print('>>>>>>>>>>!!!!!!!!!!!!!!!!!!${controller.beaconList.value.length}');
              //   print('>>>>>>>>>>!!!!!!!!!!!!!!!!!!${controller.beaconList.value[0].bssid}');
              // });
            },
          ),
          SizedBox(height: 20,),
          GestureDetector(
            child: Container(
              // padding: EdgeInsets.all(30),
              width: 200,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                shape: BoxShape.rectangle,
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(''),
                    ),
                    Container(
                      width: 120,
                      child: Text('퇴근',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: Color(0xff454f63))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(''),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              controller.strCommute.value = "out" ;
              inAndOutWork(context,(){
                controller.serverSend();
                // bleController.scannsServerSendEndCheck.value = true ;
                print('>>>>>>>>>>!!!!!!!!!!!!!!!!!!${controller.beaconList.value.length}');
                print('>>>>>>>>>>!!!!!!!!!!!!!!!!!!${controller.beaconList.value[0].uuid}');
              });
              // controller.serverSend("out");
            },
          ),
        ],
      ),
    );
  }
  Widget _start(BuildContext context) {
   return  IconButton(
     tooltip: "시작",
     icon: Icon(controller.isScanns.value ? Icons.not_started : Icons.not_started_outlined),
     color: Colors.lightBlueAccent,
     onPressed: (){
       if(!controller.isScanns.value){
         controller.start();
       }
     },
   );
  }
  Widget _stop(BuildContext context) {
    return IconButton(
      tooltip: "멈춤",
      icon: Icon(controller.isScanns.value ? Icons.stop_circle_outlined : Icons.stop_circle_rounded),
      color: Colors.lightBlueAccent,
      onPressed: (){
        if(controller.isScanns.value){
          controller.stop();
        }
      },
    );
  }
  Widget _buildBodyList(BuildContext context) {
    // returncontroller.isScanns.value ? Center(child: CircularProgressIndicator()) : Center(child: CircularProgressIndicator()) ;
    return controller.scanResultList.value.length == 0
        ? Center(child: CircularProgressIndicator())
        : ListView.separated(
      itemCount: controller.scanResultList.value.length,
      itemBuilder: (context, index) {
        return listItem(controller.scanResultList.value[index]);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }
  /* BLE 아이콘 위젯 */
  Widget leading(ScanResult r) {
    return CircleAvatar(
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
      backgroundColor: Colors.cyan,
    );
  }
  /* 장치 아이템 위젯 */
  Widget listItem(ScanResult r) {
    return ListTile(
      // onTap: () => 'ddddd',
      // leading: leading(r),
      title: deviceNameAndMacAddress(r),
      subtitle: other(r),
      trailing: deviceSignal(r),
    );
  }
  /*  장치의 신호값 위젯  */
  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }

  /* 장치의 MAC 주소 위젯  */
  Widget other(ScanResult r) {
    StringBuffer otherDevice= StringBuffer();
    otherDevice.write(r.advertisementData.txPowerLevel);
    return Text(otherDevice.toString());
  }
  /* 장치의 명 위젯  */
  Widget deviceNameAndMacAddress(ScanResult r) {
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
    name = name +"( " + r.device.id.id + " )" ;
    return Text(name);
  }

  checkLocationServices(Function function,BuildContext context)async{
    bool checkLocation = await flutterBeacon.checkLocationServicesIfEnabled ;
    if(!checkLocation){
      if (Platform.isAndroid) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("위치 서비스 활성화"),
                content: Text("위치 서비스를 활성화해주세요."),
                actions: [
                  TextButton(
                    onPressed: () async {
                      await flutterBeacon.openLocationSettings;
                      Navigator.pop(context);
                    },
                    child: Text("예"),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text("아니요"),
                  ),
                ],
              );
            });
      } else if (Platform.isIOS) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("위치 서비스 활성화"),
                content: Text("위치 서비스를 활성화해주세요."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("OK"),
                  ),
                ],
              );
            });
      }
    }else {
      var status = await Permission.location.request();
      if (!status.isGranted) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("알림!"),
                content: Text("위치권한을 허용해주세요!"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      openAppSettings().then((value) {
                        print('>>>>>>결과값>>>>>>>>>>>>>>>>>>${value}');
                      });
                    },
                    child: Text("예"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("아니요"),
                  ),
                ],
              );
            });
      } else {
        function();
      }
    }
  }
}