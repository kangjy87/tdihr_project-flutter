import 'dart:async';
import 'dart:ui';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:hr_project_flutter/General/Logger.dart';

class BeaconManager {
  static final BeaconManager _instance = BeaconManager._internal();

  factory BeaconManager() {
    return _instance;
  }

  BeaconManager._internal() {
    onBluetoothState = null;
    onCheckAllRequriement = null;
    onScanBeacon = null;
  }

  StreamSubscription<BluetoothState>? _streamBluetooth;
  BluetoothState _bluetoothState = BluetoothState.stateOff;
  AuthorizationStatus _authorizationStatus = AuthorizationStatus.notDetermined;
  bool _isLocationService = false;

  StreamSubscription<RangingResult>? _streamRanging;
  List<Region> _regions = <Region>[];
  Map<Region, List<Beacon>> _regionBeacons = <Region, List<Beacon>>{};
  List<Beacon> _beacons = <Beacon>[];
  bool _initScanning = false;

  VoidCallback? onBluetoothState;
  VoidCallback? onCheckAllRequriement;
  VoidCallback? onScanBeacon;

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

  void buildBluetooth(VoidCallback? onBluetoothState, VoidCallback? onCheckAllRequriement) {
    this.onBluetoothState = onBluetoothState;
    this.onCheckAllRequriement = onCheckAllRequriement;
  }

  void buildBeacon(VoidCallback? onScanBeacon) {
    this.onScanBeacon = onScanBeacon;
  }

  void buildBeaconRegion(String identifier, String proximityUUID) {
    _regions.add(Region(identifier: identifier, proximityUUID: proximityUUID));
  }

  Future<void> initialize() async {
    await _listeningBluetooth();
    await _checkAllRequirements();
    if (onScanBeacon != null) await startScanBeacon();
  }

  Future<void> _listeningBluetooth() async {
    slog.i('Listening to bluetooth state');
    _streamBluetooth = flutterBeacon.bluetoothStateChanged().listen((BluetoothState state) async {
      _bluetoothState = state;
      onBluetoothState!();
    });
  }

  Future<void> _checkAllRequirements() async {
    _bluetoothState = await flutterBeacon.bluetoothState;
    slog.i('Bluetooth : $_bluetoothState');

    _authorizationStatus = await flutterBeacon.authorizationStatus;
    slog.i('Authorization : $_authorizationStatus');

    _isLocationService = await flutterBeacon.checkLocationServicesIfEnabled;
    slog.i('Location service : $_isLocationService');

    onCheckAllRequriement!();
  }

  void changeAppLifecycleState(AppLifecycleState state) async {
    slog.i('App lifecycle state : $state');
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null) {
        if (_streamBluetooth!.isPaused) {
          _streamBluetooth?.resume();
        }
      }
      await _checkAllRequirements();
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

    _streamRanging = flutterBeacon.ranging(_regions).listen((RangingResult result) async {
      slog.i('Beacon ranging : $result');

      await _checkAllRequirements();

      _regionBeacons[result.region] = result.beacons;
      _beacons.clear();
      if (canScanning == true) {
        _regionBeacons.values.forEach((list) {
          _beacons.addAll(list);
        });
        _beacons.sort(_compareParameters);
      }
      onScanBeacon!();
    });
  }

  void pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      _beacons.clear();
      onScanBeacon!();
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
