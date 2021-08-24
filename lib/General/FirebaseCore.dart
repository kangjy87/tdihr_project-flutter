import 'package:firebase_core/firebase_core.dart';

FirebaseCore firebaseCore = FirebaseCore();

class FirebaseCore {
  late FirebaseApp _firebaseApp;

  FirebaseApp get firebaseApp => _firebaseApp;

  Future<void> initialize() async {
    _firebaseApp = await Firebase.initializeApp();
  }
}
