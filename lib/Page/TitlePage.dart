import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/Auth/AuthManager.dart';
import 'package:hr_project_flutter/Firebase/FCMManager.dart';
import 'package:hr_project_flutter/General/Common.dart';
import 'package:hr_project_flutter/Auth/LocalAuthManager.dart';
import 'package:hr_project_flutter/General/ShowAlertDialogMessage.dart';
import 'package:hr_project_flutter/General/TDIUser.dart';
import 'package:hr_project_flutter/Page/Pages.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

class TitlePage extends StatefulWidget {
  @override
  _TitlePageState createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {


  bool _signining = false;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              child: WillPopScope(
                onWillPop: () => _goBack(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: _buildMenu(),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Text("ver. $kAppVersion"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login(GOOGLE_AUTH_RESULT result) {
    switch (result) {
      case GOOGLE_AUTH_RESULT.SUCCESS:
        LocalAuthManager().authenticate().then((value) {
          switch (value) {
            case LOCAL_AUTH_RESULT.SUCCESS:
            case LOCAL_AUTH_RESULT.NO_AUTHORIZE:
              Get.toNamed(Pages.nameGroupware);
              break;
            case LOCAL_AUTH_RESULT.FAILED:
              Get.toNamed(Pages.nameTitle);
              setState(() {});
              break;
          }
        });
        break;
      case GOOGLE_AUTH_RESULT.ERROR_EMAIL:
        TDIUser.clearData();
        showToastMessage(MESSAGES.errLoginEmail);
        break;
      case GOOGLE_AUTH_RESULT.FAILED:
        TDIUser.clearData();
        showToastMessage(MESSAGES.errLoginFailed);
        break;
      default:
        break;
    }
  }

  List<Widget> _buildMenu() {
    List<Widget> widgets = [];

    widgets.add(_buildTDITitle());
    widgets.add(SizedBox(height: 100));
    widgets.add(_buildSigninButton());
    widgets.add(SizedBox(height: 1));

    if (_signining == true)
      widgets.add(_buildSigniningProgress());
    else if (TDIUser.isAleadyLogin == true) {
      if (LocalAuthManager().authenticated == true) {
        widgets.add(_buildGroupwareButton());
        widgets.add(SizedBox(height: 1));
      } else {
        if (LocalAuthManager().authResult == LOCAL_AUTH_RESULT.NO_AUTHORIZE) {
          widgets.add(_buildGroupwareButton());
          widgets.add(SizedBox(height: 1));
        } else {
          widgets.add(_buildAuthenticateButton());
          widgets.add(SizedBox(height: 1));
        }
      }
    }else{
      print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>??? ?????? ???????????????');
      setState(() {
        AuthManager().googleSignOut().then(
              (value) => {
            TDIUser.clearData(),
            Get.toNamed(Pages.nameTitle),
          },
        );
      });
    }

    // todo: beacon
    // widgets.add(_buildBeaconButton());
    widgets.add(app_update());

    return widgets;
  }

  Widget _buildTDITitle() {
    return Container(
      padding: const EdgeInsets.only(top: 200, bottom: 10, left: 50, right: 50),
      child: Image.asset(ASSETS.tdiLogo, width: 200),
    );
  }

  Widget _buildSigninButton() {
    return ElevatedButton(
      onPressed: () {
        if (TDIUser.isAleadyLogin == false) {
          _signining = true;
          setState(() {});
          AuthManager().googleSingIn(FCMManager().token).then((value) => {
                _login(value),
                _signining = false,
                if (value != GOOGLE_AUTH_RESULT.SUCCESS) {setState(() {})}
              });
        } else {
          AuthManager().googleSignOut().then((value) => {
                _signining = false,
                setState(() {}),
                TDIUser.clearData(),
              });
        }
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: const Color(0xffe8e8e8), width: 3),
          ),
        ),
      ),
      child: Container(
        width: 300,
        height: 30,
        margin: EdgeInsets.only(top: 3, bottom: 3),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(ASSETS.googleLogo, height: 30),
            Text(
              TDIUser.account == null ? STRINGS.googleLogin : TDIUser.account!.name + " " + STRINGS.logout,
              style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSigniningProgress() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      width: 500,
      // height: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            STRINGS.signining,
            style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
            textAlign: TextAlign.center,
          ),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupwareButton() {
    return ElevatedButton(
      onPressed: () => Get.toNamed(Pages.nameGroupware),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: const Color(0xffe8e8e8), width: 3),
          ),
        ),
      ),
      child: Container(
        width: 300,
        height: 30,
        margin: EdgeInsets.only(top: 3, bottom: 3),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              STRINGS.tdiGroupware,
              style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticateButton() {
    return ElevatedButton(
      onPressed: () => LocalAuthManager().authenticate().then((value) {
        if (value == LOCAL_AUTH_RESULT.SUCCESS) {
          Get.toNamed(Pages.nameGroupware);
        }
      }),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: const Color(0xffe8e8e8), width: 3),
          ),
        ),
      ),
      child: Container(
        width: 300,
        height: 30,
        margin: EdgeInsets.only(top: 3, bottom: 3),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              STRINGS.authenticate,
              style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        ),
      );
  }

  Widget _buildBeaconButton() {
    return ElevatedButton(
      onPressed: (){
        taskInfoSetting.name ='tdi_groupware' ;
        taskInfoSetting.link = 'http://kangjy.ipdisk.co.kr:80/publist/HDD1/%EA%B3%B5%EC%9C%A0/tingco-groupware-v1.2.0-%5B2022-02-28%5D-release.apk' ;
        _requestDownload();
      },
      // onPressed: () => Get.toNamed(Pages.nameBeacon),
      // onPressed: () => Get.toNamed(Pages.nameBle),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: BorderSide(color: const Color(0xffe8e8e8), width: 3),
          ),
        ),
      ),
      child: Container(
        width: 300,
        height: 30,
        margin: EdgeInsets.only(top: 3, bottom: 3),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              STRINGS.beacon,
              style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _goBack(BuildContext context) async {
    return Future.value(false);
  }

  //?????? ????????????
  ReceivePort _port = ReceivePort();
   String _localPath = "" ;
  _TaskInfo taskInfoSetting = _TaskInfo();
  Widget app_update() {
    if(Platform.isAndroid){
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
          ),
          taskInfoSetting.status == DownloadTaskStatus.running ||
              taskInfoSetting.status == DownloadTaskStatus.paused
              ?
          Container(
            width: 350,
            height: 30,
            color: Colors.pink,
            child: LinearProgressIndicator(
              value: taskInfoSetting.progress! / 100,
            ),
          ): Container(),
          taskInfoSetting.status == DownloadTaskStatus.running ||
              taskInfoSetting.status == DownloadTaskStatus.paused
              ?
          Container(
            width: 350,
            height: 30,
            color: Colors.white,
            child: Text(
              '??????????????? ???????????? ??? ?????????.',
              style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ): Container(),
          //???????????? ?????????
          taskInfoSetting.status == DownloadTaskStatus.failed ?
          Container(
            width: 350,
            height: 30,
            color: Colors.white,
            child: ElevatedButton(
              onPressed: () async {
                if(await _checkPermission()){
                  if(taskInfoSetting != null){
                    FlutterDownloader.remove(taskId: taskInfoSetting.taskId!);
                  }
                  _requestDownload();
                }else{
                  showToastMessage('?????? ??????????????? ??????????????????.');
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(color: const Color(0xffe8e8e8), width: 3),
                  ),
                ),
              ),
              child: Container(
                width: 300,
                height: 30,
                margin: EdgeInsets.only(top: 3, bottom: 3),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Groupware ??????????????? ??????',
                      style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ): Container(),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
          ),
          taskInfoSetting.status == DownloadTaskStatus.complete
              ?
          ElevatedButton(
            onPressed: (){
              _openDownloadedFile().then((success) {
                if (!success) {
                  print('??? ?????????!!!!!!!!!!!');
                }
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(color: const Color(0xffe8e8e8), width: 3),
                ),
              ),
            ),
            child: Container(
              width: 300,
              height: 30,
              margin: EdgeInsets.only(top: 3, bottom: 3),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Groupware ???????????? ??????',
                    style: const TextStyle(color: Color(0xff454f63), fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ) : Container()
        ],
      );
    }else{
      return Container();
    }
  }
  @override
  void initState(){
    super.initState();
    if(Platform.isAndroid){
      _bindBackgroundIsolate();
      FlutterDownloader.registerCallback(downloadCallback);
      apk_permissing();
    }else{
      //???????????? ???????????? ????????? ?????? ?????????????????? ????????? ????????? ????????????.!!!!!
      if(Get.arguments != null && Get.arguments["UPDATE"] != null && Get.arguments["UPDATE"]){
        showAlertDialogMessage(
            context,
            MESSAGES.errAppUpdateTitle,
            MESSAGES.errIosAppUpdateMsg1,
            MESSAGES.errIosAppUpdateMsg2,
            MESSAGES.errAppUpdateBtn1,
            null,
                (){
              //??? ????????????
              Navigator.of(context).pop();
            },null
        );
      }
    }
  }
  void _bindBackgroundIsolate() {
    bool isSuccess =  IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    print('.>>>>>>>>>>>>${isSuccess}');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];

      if (taskInfoSetting != null) {
        setState(() {
          taskInfoSetting.status = status;
          taskInfoSetting.progress = progress;
          if(status?.value == 3 && progress == 100){
            print('>>>>????????????>>>>>>>>??????>>');
            // _openDownloadedFile().then((success) {
            //   if (!success) {
            //     Scaffold.of(context).showSnackBar(SnackBar(
            //         content: Text('Cannot open this file')));
            //   }
            // });
          }
        });
      }
    });
  }
  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }
  apk_permissing()async{
    if(await _checkPermission()){
    await _prepareSaveDir();
    }
  }
  @override
  void dispose() {
    if(Platform.isAndroid){
      _unbindBackgroundIsolate();
    }
    super.dispose();
  }
  Future<bool> _openDownloadedFile() async{
    // var status = await Permission.requestInstallPackages.request();
    if (taskInfoSetting != null) {
      return FlutterDownloader.open(taskId: taskInfoSetting.taskId!);
    } else {
      return Future.value(false);
    }
  }
  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
    IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  void _requestDownload() async {
    print('???????????????<>>>>>>>>>>>>>>>>>>>>${_localPath}');
    taskInfoSetting.taskId = await FlutterDownloader.enqueue(
      url: taskInfoSetting.link!,
      headers: {"auth": "t_sql_encoding"},
      savedDir: _localPath,
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    );
  }
  Future<void> _prepareSaveDir() async {
    if (Platform.isAndroid) {
      _localPath = (await _findLocalPath())!;
      final savedDir = Directory(_localPath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }
    }
    ////////////////////////////////////////////
    //????????? ??????????????? ????????? ?????? ??????????????? ????????????!!!
    print('>>?????????>>>>>>??????>>!!!!!!!!!!!!!!!!!>>>>>>>>>>>>>>>>>>>>${_localPath}');
    if(Get.arguments != null && Get.arguments["UPDATE"] != null && Get.arguments["UPDATE"] && _localPath != ""){
      print('????????? ????????????<>>>>>>>>>>>>>>>>>>>>${_localPath}');
      setState(() {
        taskInfoSetting.name ='tdi_groupware' ;
        taskInfoSetting.link = 'http://kangjy.ipdisk.co.kr:80/publist/HDD1/%EA%B3%B5%EC%9C%A0/tingco-groupware-v1.2.0-%5B2022-02-28%5D-release.apk' ;
        _requestDownload();
      });
    }
    ////////////////////////////////////////////
  }
  Future<String?> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    }
    return externalStorageDirPath;
  }

  /**
   * ??? ?????? ??????????????? ?????? ????????? ?????? ???????????? ?????? ????????? ??????
   * ????????? ??????????????? ????????? ?????? ???....
   */
  appversionCheck(BuildContext context){
    if(kAppVersion == TDIUser.token!.app_version){
      print('???????????????!!!!!!!!!!!!!!!!!!');
      //????????? ???????????? ??????
      Get.toNamed(Pages.nameGroupware);
    }else{
      print('???????????????!!!!!!!!!!!!!!!!!!');
      //?????? ?????? ????????????
      if(Platform.isAndroid){
        showAlertDialogMessage(
            context,
            MESSAGES.errAppUpdateTitle,
            MESSAGES.errAppUpdate,
            null,
            MESSAGES.errAppUpdateBtn1,
            MESSAGES.errAppUpdateBtn2,
                (){
              //??? ????????????
              Navigator.of(context).pop();
              taskInfoSetting.name ='tdi_groupware' ;
              taskInfoSetting.link = TDIUser.token!.app_path ;
              _requestDownload();
            },
                (){
              //????????? ??????
              Navigator.of(context).pop();
              Get.toNamed(Pages.nameGroupware);
            }
        );
      }else{
        showAlertDialogMessage(
            context,
            MESSAGES.errAppUpdateTitle,
            MESSAGES.errAppUpdate,
            MESSAGES.errAppUpdate,
            MESSAGES.errAppUpdateBtn1,
            null,
                (){

            },
                (){

            }

        );
        setState(() {
          TDIUser.clearData();
        });
        print('???????????????!!!!!!!!!!!!!!!!!!?????????!!!!!!!');
        // Get.toNamed(Pages.nameGroupware);
      }
    }
  }
}
Future<bool> _checkPermission() async {
  // if (Platform.isAndroid) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('>>>>>>>>>>>>>>>>>>>>>>>>>>???///////////>>>>>>>>>>${androidInfo.version.sdkInt!}');
    if (androidInfo.version.sdkInt! <= 29) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
  // }
  return true;
}

class _TaskInfo {
   String? name;
   String? link;

  String? taskId;
  int? progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  _TaskInfo({this.name, this.link});
}