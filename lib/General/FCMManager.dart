import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hr_project_flutter/General/Logger.dart';

class FCMManager {
  static final FCMManager _manager = FCMManager._internal();
  late FirebaseMessaging _firebaseMessaging;
  late NotificationSettings notificationSettings;
  late String? _token;

  Function(RemoteMessage event)? _onMessageCallback;
  Function(RemoteMessage event)? _onMessageOpenedAppCallback;

  String? get token => _token;

  factory FCMManager() {
    return _manager;
  }

  FCMManager._internal() {
    _firebaseMessaging = FirebaseMessaging.instance;
  }

  Future<void> initialize() async {
    await _checkPermission();
    await _getToken();
  }

  Future<void> _checkPermission() async {
    notificationSettings = await _firebaseMessaging
        .requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
    )
        .then((value) {
      slog.i('alert : ${value.alert}');
      slog.i('announcement : ${value.announcement}');
      slog.i('carPlay : ${value.carPlay}');
      return value;
    });
  }

  Future<void> _getToken() async {
    _token = await _firebaseMessaging.getToken().then((value) {
      slog.i('FCM Token : $value');
    });
  }

  Future<void> setListener(void onMessage(RemoteMessage event)?, void onMessageOpenedApp(RemoteMessage event)?) async {
    _onMessageCallback = onMessage;
    _onMessageOpenedAppCallback = onMessageOpenedApp;

    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }

    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  void _onMessage(RemoteMessage message) {
    _onMessageCallback!(message);
    slog.i('onMessage ${message.notification!.title}/${message.notification!.body}');
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _onMessageOpenedAppCallback!(message);
    slog.i('onMessage ${message.notification!.title}/${message.notification!.body}');
  }
}
