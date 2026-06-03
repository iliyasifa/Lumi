import 'package:flutter/foundation.dart';
import 'package:instagram_flutter_clone/models/user.dart' as model;
import 'package:instagram_flutter_clone/resources/auth_methods.dart';

class AuthViewModel with ChangeNotifier {
  final Auth _authMethods = Auth();
  model.User? _user;
  bool _isLoading = false;

  model.User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> refreshUser() async {
    model.User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> checkEmailExists(String email) async {
    return await _authMethods.checkEmailExists(email);
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    _setLoading(true);
    String res = await _authMethods.signUpUser(
      email: email,
      passWord: password,
      userName: username,
      bio: bio,
      file: file,
    );
    _setLoading(false);
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    String res = await _authMethods.loginUser(
      email: email,
      password: password,
    );
    _setLoading(false);
    return res;
  }

  Future<void> signOut() async {
    await _authMethods.signOut();
    _user = null;
    notifyListeners();
  }
}
