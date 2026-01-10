import '../models/user.dart';

class AuthService {
  static final List<User> _users = [];

  Future<bool> signUp(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final exists = _users.any((u) => u.email == email);
    if (exists) return false;

    _users.add(User(
      email: email.trim(),
      password: password.trim(),
    ));
    return true;
  }

  Future<User?> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      return _users.firstWhere(
            (u) =>
        u.email == email.trim() &&
            u.password == password.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Optional (debug)
  static int get userCount => _users.length;
}
