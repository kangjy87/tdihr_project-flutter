import 'dart:isolate';
import 'dart:ui';

// ignore: import_of_legacy_library_into_null_safe
import 'package:geofencing/geofencing.dart';
import 'package:hr_project_flutter/General/Common.dart';

typedef GeofenceCallback = void Function(dynamic data);

class GeofenceManager {
  static final GeofenceManager _instance = GeofenceManager._internal();

  factory GeofenceManager() {
    return _instance;
  }

  GeofenceManager._internal();

  static const String _isolateName = 'geofencing_send_port';

  String _state = 'N/A';
  List<String> _registered = [];
  ReceivePort _port = ReceivePort();
  final List<GeofenceEvent> _triggers = <GeofenceEvent>[GeofenceEvent.enter, GeofenceEvent.dwell, GeofenceEvent.exit];
  final AndroidGeofencingSettings _settings = AndroidGeofencingSettings(
    initialTrigger: <GeofenceEvent>[GeofenceEvent.enter, GeofenceEvent.exit, GeofenceEvent.dwell],
    loiteringDelay: 1000 * 60,
  );

  GeofenceCallback? _onEventCallback;

  void buildEventCallback(GeofenceCallback event) {
    _onEventCallback = event;
  }

  Future<void> initialize() async {
    IsolateNameServer.registerPortWithName(_port.sendPort, _isolateName);
    _port.listen(
      (dynamic data) {
        _onEventCallback!(data);
        _state = data;
      },
    );
    await GeofencingManager.initialize();
  }

  void register(String id, double latitude, double longitude, double radius) {
    GeofencingManager.registerGeofence(
            GeofenceRegion(id, latitude, longitude, radius, _triggers, androidSettings: _settings), _eventCallback)
        .then(
      (_) {
        GeofencingManager.getRegisteredGeofenceIds().then(
          (value) {
            _registered = value;
          },
        );
      },
    );
  }

  void unregister(String id) {
    GeofencingManager.removeGeofenceById(id).then(
      (_) {
        GeofencingManager.getRegisteredGeofenceIds().then((value) => _registered = value);
      },
    );
  }

  static void _eventCallback(List<String> ids, Location l, GeofenceEvent e) async {
    showToastMessage('geofence: $ids Location $l Event: $e');
    final SendPort? send = IsolateNameServer.lookupPortByName(_isolateName);
    send!.send(e.toString());
  }
}
