import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/Beacon/BeaconCtrl.dart';
import 'package:hr_project_flutter/Beacon/BeaconManager.dart';
import 'package:hr_project_flutter/General/Logger.dart';

class BeaconPage extends GetView<BeaconCtrl> {
  @override
  Widget build(BuildContext context) {
    slog.i("Flutter Sample : Beacon");
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacon'),
        actions: <Widget>[
          Obx(_buildAuthorizedIcon),
          Obx(() {
            return _buildLocationIcon(context);
          }),
          Obx(() {
            return _buildBluetoothIcon(context);
          }),
        ],
      ),
      body: Obx(() {
        return _buildBodyList(context);
      }),
    );
  }

  Widget _buildAuthorizedIcon() {
    if (controller.isLocationService.value == false)
      return IconButton(
        tooltip: 'Not Determined',
        icon: Icon(Icons.portable_wifi_off),
        color: Colors.grey,
        onPressed: () {},
      );

    if (controller.isAuthorization == false)
      return IconButton(
        tooltip: 'Not Authorized',
        icon: Icon(Icons.portable_wifi_off),
        color: Colors.red,
        onPressed: () async {
          await flutterBeacon.requestAuthorization;
        },
      );

    return IconButton(
      tooltip: 'Authorized',
      icon: Icon(Icons.wifi_tethering),
      color: Colors.lightBlueAccent,
      onPressed: () async {
        await flutterBeacon.requestAuthorization;
      },
    );
  }

  Widget _buildLocationIcon(BuildContext context) {
    final service = controller.isLocationService.value;
    return IconButton(
      tooltip: service ? 'Location Service ON' : 'Location Service OFF',
      icon: Icon(
        service ? Icons.location_on : Icons.location_off,
      ),
      color: service ? Colors.lightBlueAccent : Colors.red,
      onPressed: service
          ? () {}
          : () {
              _handleOpenLocationSettings(context);
            },
    );
  }

  Widget _buildBluetoothIcon(BuildContext context) {
    final state = controller.bluetoothState.value;
    if (state == BluetoothState.stateOn) {
      return IconButton(
        tooltip: 'Bluetooth ON',
        icon: Icon(Icons.bluetooth_connected),
        color: Colors.lightBlueAccent,
        onPressed: () {},
      );
    }
    if (state == BluetoothState.stateOff) {
      return IconButton(
        tooltip: 'Bluetooth OFF',
        icon: Icon(Icons.bluetooth),
        color: Colors.grey,
        onPressed: () {
          _handleOpenBluetooth(context);
        },
      );
    }

    return IconButton(
      tooltip: 'Bluetooth State Unknown',
      icon: Icon(Icons.bluetooth_disabled),
      color: Colors.red,
      onPressed: () {},
    );
  }

  Widget _buildBodyList(BuildContext context) {
    return controller.scanCount.value == 0
        ? Center(child: CircularProgressIndicator())
        : ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: BeaconManager().beacons.map(
                (beacon) {
                  return ListTile(
                    title: Text(
                      beacon.proximityUUID,
                      style: TextStyle(fontSize: 15.0),
                    ),
                    subtitle: new Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            'Major: ${beacon.major}\nMinor: ${beacon.minor}',
                            style: TextStyle(fontSize: 13.0),
                          ),
                          flex: 1,
                          fit: FlexFit.tight,
                        ),
                        Flexible(
                          child: Text(
                            'Accuracy: ${beacon.accuracy}m\nRSSI: ${beacon.rssi}',
                            style: TextStyle(fontSize: 13.0),
                          ),
                          flex: 2,
                          fit: FlexFit.tight,
                        )
                      ],
                    ),
                  );
                },
              ),
            ).toList(),
          );
  }

  void _handleOpenLocationSettings(BuildContext context) async {
    if (Platform.isAndroid) {
      await flutterBeacon.openLocationSettings;
    } else if (Platform.isIOS) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('위치 서비스 활성화'),
            content: Text(
              '위치 서비스를 활성화해주세요. Settings > Privacy > Location Services.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _handleOpenBluetooth(BuildContext context) async {
    if (Platform.isAndroid) {
      try {
        await flutterBeacon.openBluetoothSettings;
      } on PlatformException catch (e) {
        slog.i(e);
      }
    } else if (Platform.isIOS) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('블루투스 활성화'),
            content: Text('블루투스를 활성화해주세요 Settings > Bluetooth.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
