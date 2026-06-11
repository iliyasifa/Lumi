import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_flutter_clone/view_models/auth/auth_view_model.dart';

class SignUpState {
  final Uint8List? image;
  final bool isCheckingEmail;
  final String? serverEmailError;
  final bool isLoading;

  const SignUpState({
    this.image,
    this.isCheckingEmail = false,
    this.serverEmailError,
    this.isLoading = false,
  });

  SignUpState copyWith({
    Uint8List? image,
    bool? isCheckingEmail,
    String? Function()? serverEmailError,
    bool? isLoading,
  }) {
    return SignUpState(
      image: image ?? this.image,
      isCheckingEmail: isCheckingEmail ?? this.isCheckingEmail,
      serverEmailError: serverEmailError != null ? serverEmailError() : this.serverEmailError,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SignUpNotifier extends AutoDisposeNotifier<SignUpState> {
  Timer? _debounce;

  @override
  SignUpState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });
    return const SignUpState();
  }

  void setImage(Uint8List img) {
    state = state.copyWith(image: img);
  }

  void clearServerEmailError() {
    state = state.copyWith(serverEmailError: () => null);
  }

  void checkEmailDebounced(String email) {
    clearServerEmailError();

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 800), () async {
      state = state.copyWith(isCheckingEmail: true);
      
      final authNotifier = ref.read(authViewModelProvider.notifier);
      bool exists = await authNotifier.checkEmailExists(email);
      
      state = state.copyWith(
        isCheckingEmail: false,
        serverEmailError: exists ? () => 'This email is already in use' : null,
      );
    });
  }

  Future<String> signUp({
    required String email,
    required String password,
    required String username,
    required String bio,
  }) async {
    if (state.image == null) {
      return 'Please select a profile image';
    }

    state = state.copyWith(isLoading: true);
    final authNotifier = ref.read(authViewModelProvider.notifier);
    
    final res = await authNotifier.signUpUser(
      email: email,
      password: password,
      username: username,
      bio: bio,
      file: state.image!,
    );

    if (res.contains('already in use')) {
      state = state.copyWith(
        isLoading: false,
        serverEmailError: () => res,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }

    return res;
  }
}

final signUpViewModelProvider =
    AutoDisposeNotifierProvider<SignUpNotifier, SignUpState>(() {
  return SignUpNotifier();
});
