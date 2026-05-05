import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService(this._auth);

  Future<String> signInAnonymously() async {
    final user = _auth.currentUser;

    if (user != null) {
      return user.uid;
    }

    final credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }

  String? get currentUserId => _auth.currentUser?.uid;
}