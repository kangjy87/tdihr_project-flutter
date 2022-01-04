import 'dart:async';
import 'dart:ui';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:hr_project_flutter/retrofit/beacon_login_dto.dart';

class BeaconManager {
  static final BeaconManager _instance = BeaconManager._internal();

  factory BeaconManager() {
    return _instance;
  }

  BeaconManager._internal() {
    _onBluetoothState = null;
    _onCheckAllRequriement = null;
    _onScanBeacon = null;
  }

  StreamSubscription<BluetoothState>? _streamBluetooth;
  BluetoothState _bluetoothState = BluetoothState.stateOff;
  AuthorizationStatus _authorizationStatus = AuthorizationStatus.notDetermined;
  bool _isLocationService = false;

  StreamSubscription<RangingResult>? _streamRanging;
  List<Region> _regions = <Region>[];
  Map<Region, List<Beacon>> _regionBeacons = <Region, List<Beacon>>{};
  List<Beacon> _beacons = <Beacon>[];
  List<BeaconData> _beaconDatas = <BeaconData>[];
  bool _initScanning = false;

  VoidCallback? _onBluetoothState;
  VoidCallback? _onCheckAllRequriement;
  VoidCallback? _onScanBeacon;
  BluetoothState get bluetoothState => _bluetoothState;
  bool get isBluetooth => _bluetoothState == BluetoothState.stateOn;
  AuthorizationStatus get authorizationStatus => _authorizationStatus;
  bool get isAuthorization =>
      _authorizationStatus == AuthorizationStatus.allowed ||
      _authorizationStatus == AuthorizationStatus.always ||
      _authorizationStatus == AuthorizationStatus.whenInUse;
  bool get isLocationService => _isLocationService;
  bool get initScanning => _initScanning;
  bool get canScanning => isBluetooth == true && isAuthorization == true && isLocationService == true;
  bool get isBeaconEmpty => _beacons.isEmpty;
  List<Beacon> get beacons => _beacons;
  List<BeaconData> get beaconDatas => _beaconDatas;
  // var beaconList = RxList<BeaconData>([]).obs ;

  void buildBluetooth(VoidCallback? onBluetoothState, VoidCallback? onCheckAllRequriement) {
    this._onBluetoothState = onBluetoothState;
    this._onCheckAllRequriement = onCheckAllRequriement;
  }

  void buildBeacon(VoidCallback? onScanBeacon) {
    this._onScanBeacon = onScanBeacon;
  }

  void buildBeaconRegion(String identifier, String proximityUUID) {
    _regions.add(Region(identifier: identifier, proximityUUID: proximityUUID));
  }

  Future<void> initialize() async {
    await _listeningBluetooth();
    await _checkAllRequirements();
    if (_onScanBeacon != null) {
      print('>>>>>>!!!!${_onScanBeacon}');
      await startScanBeacon();
    }
  }

  Future<void> _listeningBluetooth() async {
    _streamBluetooth = flutterBeacon.bluetoothStateChanged().listen((BluetoothState state) async {
      slog.i("beacon/bluetooth : $state");
      _bluetoothState = state;
      _onBluetoothState!();
    });
  }

  Future<void> _checkAllRequirements() async {
    _bluetoothState = await flutterBeacon.bluetoothState;
    _authorizationStatus = await flutterBeacon.authorizationStatus;
    _isLocationService = await flutterBeacon.checkLocationServicesIfEnabled;

    slog.i("beacon/bluetooth  : $_bluetoothState");
    slog.i("beacon/authorization : $_authorizationStatus");
    slog.i("beacon/location service : $_isLocationService");

    _onCheckAllRequriement!();
  }

  void changeAppLifecycleState(AppLifecycleState state) async {
    slog.i("beacon/app lifecycle state : $state");
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null) {
        if (_streamBluetooth!.isPaused) {
          _streamBluetooth?.resume();
        }
      }
      // await _checkAllRequirements();
    } else if (state == AppLifecycleState.paused) {
      _streamBluetooth?.pause();
    }
  }
  Future<void> startScanBeacon() async {
    _initScanning = await flutterBeacon.initializeScanning;

    if (_streamRanging != null) {
      if (_streamRanging!.isPaused) {
        _streamRanging?.resume();
        return;
      }
    }
    bool beaconScanningTime = false ;
    _streamRanging = flutterBeacon.ranging(_regions).listen((RangingResult result) async {
      slog.i("beacon/ranging : $result");
      if(!beaconScanningTime){
        beaconScanningTime = true ;
        print('?????>>>>>>> 응 들어옴');
        Timer.periodic(Duration(seconds: 4), (timer) {
          print('?????>>>>>>> 응 4초됨 나가');
          timer.cancel();
        });
        // await Future.delayed(Duration (seconds: 4));
      }
      await _checkAllRequirements();

      _regionBeacons[result.region] = result.beacons;
      _beacons.clear();
      _beaconDatas.clear();
      if (canScanning == true) {
        _regionBeacons.values.forEach((list) {
          _beacons.addAll(list);
          for(Beacon b in list){
            BeaconData data = BeaconData();
            data.uuid = b.proximityUUID ;
            data.rssi = b.rssi ;
            _beaconDatas.add(data);
          }

        });
        _beacons.sort(_compareParameters);
      }
      _onScanBeacon!();
    });
  }

  void pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      _beacons.clear();
      _beaconDatas.clear();
      _onScanBeacon!();
    }
  }

  void close() {
    _streamBluetooth?.cancel();
    _streamRanging?.cancel();
  }

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }
}
