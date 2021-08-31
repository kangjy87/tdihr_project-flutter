import 'package:flutter/cupertino.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:hr_project_flutter/Beacon/BeaconManager.dart';

class BeaconCtrl extends GetxController with WidgetsBindingObserver {
  var bluetoothState = BluetoothState.stateOff.obs;
  var authorizationStatus = AuthorizationStatus.notDetermined.obs;
  var isAuthorization = false.obs;
  var isLocationService = false.obs;
  var scanCount = 0.obs;

  @override
  void onInit() {
    BeaconManager()
        .buildBluetooth(
          () {
            bluetoothState.value = BeaconManager().bluetoothState;
          },
          () {
            bluetoothState.value = BeaconManager().bluetoothState;
            authorizationStatus.value = BeaconManager().authorizationStatus;
            isAuthorization.value = BeaconManager().isAuthorization;
            isLocationService.value = BeaconManager().isLocationService;
          },
        )
        .buildBeacon(() {
          if (BeaconManager().isBeaconEmpty == true)
            scanCount.value = 0;
          else
            scanCount.value++;
        })
        .buildBeaconRegion('BeaconType1', '8fef2e11-d140-2ed1-2eb1-4138edcabe09')
        .buildBeaconRegion('BeaconType2', '4d9c357a-0640-11ec-9a03-0242ac130003')
        .initialize();

    super.onInit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    BeaconManager().changeAppLifecycleState(state);
    super.didChangeAppLifecycleState(state);
  }

  @override
  void onClose() {
    BeaconManager().close();
    super.onClose();
  }
}

class BeaconBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BeaconCtrl>(() => BeaconCtrl());
  }
}
