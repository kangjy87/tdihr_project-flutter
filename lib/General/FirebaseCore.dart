import 'package:firebase_core/firebase_core.dart';

class FirebaseCore {
  static final FirebaseCore _instance = FirebaseCore._internal();

  late FirebaseApp _firebaseApp;

  FirebaseApp get firebaseApp => _firebaseApp;

  factory FirebaseCore() {
    return _instance;
  }

  FirebaseCore._internal();

  Future<void> initialize() async {
    _firebaseApp = await Firebase.initializeApp();
  }
}
