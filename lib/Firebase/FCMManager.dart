import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hr_project_flutter/General/Logger.dart';

typedef CallbackRemoteMessage = void Function(RemoteMessage event);

class FCMManager {
  static final FCMManager _instance = FCMManager._internal();

  factory FCMManager() {
    return _instance;
  }

  FCMManager._internal() {
    _firebaseMessaging = FirebaseMessaging.instance;
    _onMessageCallback = null;
    _onMessageOpenedAppCallback = null;
  }

  late FirebaseMessaging _firebaseMessaging;
  // late NotificationSettings _notificationSettings;
  late String _token;

  CallbackRemoteMessage? _onMessageCallback;
  CallbackRemoteMessage? _onMessageOpenedAppCallback;

  String get token => _token;

  void buildRemoteMessage(CallbackRemoteMessage? onMessage, CallbackRemoteMessage? onMessageOpenedApp) {
    _onMessageCallback = onMessage;
    _onMessageOpenedAppCallback = onMessageOpenedApp;
  }

  Future<void> initialize() async {
    await _checkPermission();
    await _getToken();
    await _setListener();
  }

  Future<void> _checkPermission() async {
    // _notificationSettings = await _firebaseMessaging
    await _firebaseMessaging
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
    await _firebaseMessaging.getToken().then((value) {
      // slog.i('FCM Token : $value');
      print('FCM Token : $value');
      _token = value!;
    });
  }

  Future<void> _setListener() async {
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
