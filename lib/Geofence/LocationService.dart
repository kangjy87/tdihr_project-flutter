import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:hr_project_flutter/General/Logger.dart';
import 'package:hr_project_flutter/Geofence/LocationPermmision.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  static const String isolateName = 'LocatorIsolate';
  ReceivePort port = ReceivePort();
  bool _isRunning = false;
  int _count = -1;

  Future<void> initialize() async {
    if (IsolateNameServer.lookupPortByName(isolateName) != null) {
      IsolateNameServer.removePortNameMapping(isolateName);
    }
    IsolateNameServer.registerPortWithName(port.sendPort, isolateName);

    port.listen((dynamic data) async {});

    await BackgroundLocator.initialize();
    _isRunning = await BackgroundLocator.isServiceRunning();
  }

  void stop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    _isRunning = await BackgroundLocator.isServiceRunning();
  }

  void start() async {
    if (await checkLocationPermission() == true) {
      await _startLocator();
      _isRunning = await BackgroundLocator.isServiceRunning();
    } else {
      // show error
    }
  }

  Future<void> _startLocator() async {
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
      _eventCallback,
      initCallback: _initCallback,
      initDataCallback: data,
      disposeCallback: _disposeCallback,
      iosSettings: IOSSettings(accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
      autoStop: false,
      androidSettings: AndroidSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        interval: 5,
        distanceFilter: 0,
        client: LocationClient.google,
        // androidNotificationSettings: AndroidNotificationSettings(
        //   notificationChannelName: 'Location tracking',
        //   notificationTitle: 'Start Location Tracking',
        //   notificationMsg: 'Track location in background',
        //   notificationBigMsg:
        //       'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
        //   notificationIconColor: Colors.grey,
        //   notificationTapCallback: LocationCallbackHandler.notificationCallback,
        // ),
      ),
    );
  }

  static Future<void> _initCallback(Map<dynamic, dynamic> params) async {
    await LocationService()._onInit(params);
  }

  static Future<void> _disposeCallback() async {
    await LocationService()._onDispose();
  }

  static Future<void> _eventCallback(LocationDto locationDto) async {
    await LocationService()._onEvent(locationDto);
  }

  Future<void> _onInit(Map<dynamic, dynamic> params) async {
    slog.i("location service/init callback handler");
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    slog.i("location service/count:$_count, service $_isRunning");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> _onDispose() async {
    slog.i("location service/dispose callback handler [count:$_count]");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> _onEvent(LocationDto locationDto) async {
    slog.i('location service/$_count location in dart: ${locationDto.toString()}');
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto);
    _count++;
  }
}
