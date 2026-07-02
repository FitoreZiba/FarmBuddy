import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  AuthStatus status = AuthStatus.unknown;
  User? user;
  String? errorMessage;
  bool isLoading = false;

  late final StreamSubscription<User?> _sub;
  Timer? _timeoutTimer;

  AuthProvider() {
  print("🔥 AuthProvider constructor");

  print(
    "🔥 currentUser at startup = ${FirebaseAuth.instance.currentUser}",
  );

  debugPrint("AUTH STATUS => $status | user => $user");

  _sub = _service.authStateChanges.listen(
    (u) {
      print("🔥 AUTH EVENT RECEIVED");
      print("🔥 USER = $u");

      user = u;
      status = u == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;

      print("🔥 STATUS = $status");

      notifyListeners();
    },
    onError: (e) {
      print("🔥 AUTH STREAM ERROR");
      print(e);
    },
  );
}

  Future<bool> signIn(String email, String password) =>
      _run(() => _service.signIn(email, password));

  Future<bool> register(String email, String password) =>
      _run(() => _service.register(email, password));

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Authentication failed';
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() => _service.signOut();

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _sub.cancel();
    super.dispose();
  }
}
