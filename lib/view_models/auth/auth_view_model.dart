import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lumi/models/user.dart' as model;
import 'package:lumi/resources/auth_methods.dart';

enum AuthLoadingState {
  none,
  emailPassword,
  google,
}

class AuthState {
  final model.User? user;
  final AuthLoadingState loadingState;

  const AuthState({
    this.user,
    this.loadingState = AuthLoadingState.none,
  });

  bool get isLoading => loadingState != AuthLoadingState.none;
  bool get isEmailPasswordLoading =>
      loadingState == AuthLoadingState.emailPassword;
  bool get isGoogleLoading => loadingState == AuthLoadingState.google;

  AuthState copyWith({
    model.User? user,
    AuthLoadingState? loadingState,
  }) {
    return AuthState(
      user: user ?? this.user,
      loadingState: loadingState ?? this.loadingState,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  final Auth _authMethods = Auth();

  @override
  AuthState build() {
    return const AuthState();
  }

  Future<void> refreshUser() async {
    try {
      model.User user = await _authMethods.getUserDetails();
      state = state.copyWith(user: user);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _setLoading(AuthLoadingState value) {
    state = state.copyWith(loadingState: value);
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
    _setLoading(AuthLoadingState.emailPassword);
    String res = await _authMethods.signUpUser(
      email: email,
      passWord: password,
      userName: username,
      bio: bio,
      file: file,
    );
    _setLoading(AuthLoadingState.none);
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    _setLoading(AuthLoadingState.emailPassword);
    String res = await _authMethods.loginUser(
      email: email,
      password: password,
    );
    _setLoading(AuthLoadingState.none);
    return res;
  }

  Future<String> signInWithGoogle() async {
    _setLoading(AuthLoadingState.google);
    String res = await _authMethods.signInWithGoogle();
    if (res == 'success') {
      await refreshUser();
    }
    _setLoading(AuthLoadingState.none);
    return res;
  }

  Future<void> signOut() async {
    await _authMethods.signOut();
    state = const AuthState();
  }
}

final authViewModelProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
