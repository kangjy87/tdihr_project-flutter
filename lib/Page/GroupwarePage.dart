import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/Auth/AuthManager.dart';
import 'package:hr_project_flutter/BLE/BleManager.dart';
import 'package:hr_project_flutter/BLE/inOutWorkAndroidDialog.dart';
import 'package:hr_project_flutter/BLE/in_out_work.dart';
import 'package:hr_project_flutter/Beacon/InOutWorkIosDialog.dart';
import 'package:hr_project_flutter/Beacon/inOutWorkDialog.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:hr_project_flutter/General/ShowAlertDialogMessage.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/Page/GroupwareControler.dart';
import 'package:hr_project_flutter/Page/Pages.dart';
import 'package:hr_project_flutter/retrofit/beacon_login_dto.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GroupwarePage extends StatefulWidget {
  @override
  _GroupwarePageState createState() => _GroupwarePageState();
}

class _GroupwarePageState extends State<GroupwarePage> with WidgetsBindingObserver {
  late WebViewController _controller;
  final Completer<WebViewController> _controllerComplete = Completer<WebViewController>();

  @override
  void initState() {
    slog.i("TDI Groupware Start ...${TDIUser.token!.token}");
    GroupwareControler groupwareControler = Get.find<GroupwareControler>();
    groupwareControler.getbeaconList();
    WidgetsBinding.instance!.addObserver(this);
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    var cur = Get.currentRoute;
    if (kIsPushLink == true) {
      if (state == AppLifecycleState.resumed) {
        if (cur == Pages.nameGroupware) {
          _controller.loadUrl(kPushLinkURL);
        }
      }
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    slog.i("TDI Groupware Start ...");
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => _goBack(context),
          child: _buildWebView(),
        ),
      ),
      // floatingActionButton: _buildFloatingActionButtonOnyIOS(),
      // floatingActionButton: testiosbeacon(), //비콘테스트용 버튼
    );
  }
  //재민씨폰 테스트 테스트후 삭제
  Widget testiosbeacon() {
    return Align(
      alignment: Alignment(-0.85, 1.0),
      child: FloatingActionButton(
        backgroundColor: Colors.black87,
        child: Icon(Icons.navigate_before),
        onPressed: (){
          String strInOut = "out" ;
          checkLocationServices(strInOut,(){
            GroupwareControler groupwareControler = Get.find<GroupwareControler>();
            groupwareControler.strCommute.value = strInOut ;
            if(Platform.isIOS){
              inAndOutWorkshowDialog_ios(context);
              inAndOutWorkScanns_ios((List<BeaconData> beaconList){
                groupwareControler.beaconList.value.addAll(beaconList);
                print("${beaconList.length}라스트 결과물>>>>>>>>${groupwareControler.beaconList.value.length}");
                Get.back();
              });
            }else{
              print('쓰발ㄴㅇㄹㄴㄹㄴㅇㄹㄴㄹㄴㄹㄴㄹ');
              inAndOutWorkshowDialog_android(context);
              inAndOutWorkScanns_android((){
                //groupwareControler.beaconList
                for(int i = 0 ; i < groupwareControler.beaconList.value.length; i++){
                  print('마물쓰>>>>>>>>>>>>>>>>>>>${groupwareControler.beaconList.value[i].uuid}>>>>${groupwareControler.beaconList.value[i].major}>>>>>${groupwareControler.beaconList.value[i].bssid}');
                }
                Get.back();
              });
            }
          });
        },
      ),
    );
  }
  Widget _buildWebView() {
    return WebView(
      // userAgent: 'random', ios에서 문제 발생 - 주석 처리 함
      initialUrl: kIsPushLink ? kPushLinkURL : URL.tdiLogin + TDIUser.token!.token +'?os='+ (Platform.isIOS ? "ios" :"aos") + '&app_version='+ kAppVersion,
      onWebViewCreated: (WebViewController webViewController) {
        _controllerComplete.complete(webViewController);
        _controllerComplete.future.then((value) => _controller = value);
      },

      javascriptMode: JavascriptMode.unrestricted,
      gestureNavigationEnabled: true,
      javascriptChannels: <JavascriptChannel>{
          _javascriptLogoutChannel(context),
          _javascriptInWorkChannel(context),
          _javascriptOutWorkChannel(context),
      },
      // javascriptChannels: Set.from([
      //   _javascriptLogoutChannel(context),
      //   _javascriptInWorkChannel(context),
      //   _javascriptOutWorkChannel(context),
      // ]),
      // javascriptChannels: <JavascriptChannel>{
      //   _javascriptLogoutChannel(context),
      //   // _javascriptInWorkChannel(context),
      //   // _javascriptOutWorkChannel(context),
      // },
      // onProgress: (int progress) {
      //   slog.i("TDI Groupware is loading (progress : $progress%)");
      // },
      onPageStarted: (String url) {
        slog.i("page started $url");
      },
      onPageFinished: (String url) {
        slog.i("page finished $url");
        kIsPushLink = false;
      },
      navigationDelegate: (NavigationRequest request) {
        slog.i("allowing navigation to ${request.url}");
        _checkLogin(request.url);
        return NavigationDecision.navigate;
      },
    );
  }

  Widget _buildFloatingActionButtonOnyIOS() {
    return Visibility(
      visible: Platform.isIOS,
      child: Align(
        alignment: Alignment(-0.85, 1.0),
        child: FloatingActionButton(
          backgroundColor: Colors.black87,
          child: Icon(Icons.navigate_before),
          onPressed: () => _goBack(context),
        ),
      ),
    );
  }

  Future<void> loadHtmlFromAssets(String filename, controller) async {
    String fileText = await rootBundle.loadString(filename);
    controller
        .loadUrl(Uri.dataFromString(fileText, mimeType: "text/html", encoding: Encoding.getByName("utf-8")).toString());
  }

  JavascriptChannel _javascriptLogoutChannel(BuildContext context) {
    return JavascriptChannel(
      name: "_webToAppLogout",
      onMessageReceived: (JavascriptMessage message) {
        slog.i("JavascriptChannel _webToAppLogout : ${message.message}");
        _goTitleAndLogout();
      },
    );
  }
  JavascriptChannel _javascriptInWorkChannel(BuildContext context) {
    return JavascriptChannel(
      name: "_webToAppInWork",
      onMessageReceived: (JavascriptMessage message)async{
        String strInOut = "in" ;
        checkLocationServices(strInOut,(){
          GroupwareControler groupwareControler = Get.find<GroupwareControler>();
          groupwareControler.strCommute.value = strInOut ;
          if(Platform.isIOS){
            inAndOutWorkshowDialog_ios(context);
            inAndOutWorkScanns_ios((List<BeaconData> beaconList){
              groupwareControler.beaconList.value.addAll(beaconList);
              print("${beaconList.length}라스트 결과물>>>>>>>>${groupwareControler.beaconList.value.length}");
              groupwareControler.serverSend((type,result,code){
                print('>>>>>>>>구른다.commuteMember(\'${type}\',\'${result}\',\'${code}\')');
                _controller.evaluateJavascript('commuteMember(\'${type}\',\'${result}\',${code})');
              });
            });
            // inAndOutWorkDialog(context,(List<BeaconData> beaconList){
            //   groupwareControler.beaconList.value.addAll(beaconList);
            //   print("${beaconList.length}라스트 결과물>>>>>>>>${groupwareControler.beaconList.value.length}");
            //   groupwareControler.serverSend((type,result,code){
            //     print('>>>>>>>>구른다.commuteMember(\'${type}\',\'${result}\',\'${code}\')');
            //     _controller.evaluateJavascript('commuteMember(\'${type}\',\'${result}\',${code})');
            //   });
            // });
          }else{
            inAndOutWorkshowDialog_android(context);
            inAndOutWorkScanns_android((){
              //groupwareControler.beaconList
              // for(int i = 0 ; i < groupwareControler.beaconList.value.length; i++){
              //   print('${groupwareControler.beaconList.value[i].uuid}>>>>${groupwareControler.beaconList.value[i].major}>>>>>${groupwareControler.beaconList.value[i].bssid}');
              // }
              groupwareControler.serverSend((type,result,code){
                print('>>>>>>>>구른다.commuteMember(\'${type}\',\'${result}\',\'${code}\')');
                _controller.evaluateJavascript('commuteMember(\'${type}\',\'${result}\',${code})');
              });
            });
            // inAndOutWork(context,(){
            //   //groupwareControler.beaconList
            //   for(int i = 0 ; i < groupwareControler.beaconList.value.length; i++){
            //     print('${groupwareControler.beaconList.value[i].uuid}>>>>${groupwareControler.beaconList.value[i].major}>>>>>${groupwareControler.beaconList.value[i].bssid}');
            //   }
            //   groupwareControler.serverSend((type,result,code){
            //     print('>>>>>>>>구른다.commuteMember(\'${type}\',\'${result}\',\'${code}\')');
            //     _controller.evaluateJavascript('commuteMember(\'${type}\',\'${result}\',${code})');
            //   });
            // });
          }
        });
      },
    );
  }
  JavascriptChannel _javascriptOutWorkChannel(BuildContext context) {
    return JavascriptChannel(
      name: "_webToAppOutWork",
      onMessageReceived: (JavascriptMessage message)async {
        String strInOut = "out" ;
        checkLocationServices(strInOut,(){
          GroupwareControler groupwareControler = Get.find<GroupwareControler>();
          groupwareControler.strCommute.value = strInOut ;
          if(Platform.isIOS){
            inAndOutWorkshowDialog_ios(context);
            inAndOutWorkScanns_ios((List<BeaconData> beaconList){
              groupwareControler.beaconList.value.addAll(beaconList);
              print("${beaconList.length}라스트 결과물>>>>>>>>${groupwareControler.beaconList.value.length}");
              groupwareControler.serverSend((type,result,code){
                print('>>>>>>>>구른다.commuteMember(\'${type}\',\'${result}\',\'${code}\')');
                _controller.evaluateJavascript('commuteMember(\'${type}\',\'${result}\',${code})');
              });
            });
            // inAndOutWorkDialog(context,(List<BeaconData> beaconList){
            //   groupwareControler.beaconList.value.addAll(beaconList);
            //   print("${beaconList.length}라스트 결과물>>>>>>>>${groupwareControler.beaconList.value.length}");
            //   groupwareControler.serverSend((type,result,code){
            //     print('>>>>>>>>구른다.commuteMember(\'${type}\',\'${result}\',\'${code}\')');
            //     _controller.evaluateJavascript('commuteMember(\'${type}\',\'${result}\',${code})');
            //   });
            // });
          }else{
            inAndOutWorkshowDialog_android(context);
            inAndOutWorkScanns_android((){
              //groupwareControler.beaconList
              // for(int i = 0 ; i < groupwareControler.beaconList.value.length; i++){
              //   print('${groupwareControler.beaconList.value[i].uuid}>>>>${groupwareControler.beaconList.value[i].major}>>>>>${groupwareControler.beaconList.value[i].bssid}');
              // }
              groupwareControler.serverSend((type,result,code){
                print('>>>>>>>>구른다.commuteMember(\'${type}\',\'${result}\',\'${code}\')');
                _controller.evaluateJavascript('commuteMember(\'${type}\',\'${result}\',${code})');
              });
            });
          }
        });
      },
    );
  }

  checkLocationServices(String inoutCheck, Function function)async{
    bool checkLocation = await flutterBeacon.checkLocationServicesIfEnabled ;
    var bluetoothState = await flutterBeacon.bluetoothState ;
    bool checkBluetooth = (bluetoothState == BluetoothState.stateOn);
    if(!checkLocation){
      if (Platform.isAndroid) {
        _controller.evaluateJavascript('commuteMember(\'${inoutCheck}\',\'fail\',601)');
        // await showDialog(
        //     context: context,
        //     builder: (context) {
        //       return AlertDialog(
        //         title: Text("위치 서비스 활성화"),
        //         content: Text("위치 서비스를 활성화해주세요."),
        //         actions: [
        //           TextButton(
        //             onPressed: () async {
        //               await flutterBeacon.openLocationSettings;
        //               Navigator.pop(context);
        //             },
        //             child: Text("예"),
        //           ),
        //           TextButton(
        //             onPressed: () async {
        //               Navigator.pop(context);
        //             },
        //             child: Text("아니요"),
        //           ),
        //         ],
        //       );
        //     });
      } else if (Platform.isIOS) {
        _controller.evaluateJavascript('commuteMember(\'${inoutCheck}\',\'fail\',601)');
        // await showDialog(
        //     context: context,
        //     builder: (context) {
        //       return AlertDialog(
        //         title: Text("위치 서비스 활성화"),
        //         content: Text("위치 서비스를 활성화해주세요."),
        //         actions: [
        //           TextButton(
        //             onPressed: () => Navigator.pop(context),
        //             child: Text("OK"),
        //           ),
        //         ],
        //       );
        //     });
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
        if(Platform.isIOS){
          if(checkBluetooth){
            function();
          }else{
            _controller.evaluateJavascript('commuteMember(\'${inoutCheck}\',\'fail\',600)');
          }
        }else{
          function();
        }
      }
    }
  }
  void _checkLogin(String urlString) {
    print('adsfasdfasdfaaaaaaaaaaaaaaaaaaaaaaaaaa');
    var url = Uri.parse(urlString);
    var error = url.queryParameters["error"];
    if (error == "unauthenticated") {
      _goTitleAndLogout();
      showToastMessage(MESSAGES.errLoginFailed);
    }else if(error == "updatable"){
      Get.toNamed(Pages.nameTitle, arguments: {"UPDATE": true} );
      // showAlertDialogMessage(
      //     context,
      //     MESSAGES.errAppUpdateTitle,
      //     MESSAGES.errAppUpdate,
      //     null,
      //     MESSAGES.errAppUpdateBtn1,
      //     MESSAGES.errAppUpdateBtn2,
      //         (){
      //       //앱 업데이트
      //       _goTitleAndLogout();
      //     },
      //         (){
      //       //다음에 하기
      //       Navigator.of(context).pop();
      //       _controller.loadUrl(kIsPushLink ? kPushLinkURL : URL.tdiLogin + TDIUser.token!.token +'?os='+ (Platform.isIOS ? "ios" :"aos") + '&app_version='+ '1.2.0',);
      //     }
      // );
      // showToastMessage(MESSAGES.errAppUpdateBtn1);
    }
  }

  void _goTitleAndLogout() {
    AuthManager().googleSignOut().then(
          (value) => {
            TDIUser.clearData(),
            Get.toNamed(Pages.nameTitle),
          },
        );
  }
  Future<bool> _goBack(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      Get.toNamed(Pages.nameTitle); // 더 이상 back를 할 수 없으면 title로 이동
      return Future.value(false);
    }
  }
}
