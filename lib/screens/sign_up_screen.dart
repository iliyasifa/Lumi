import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_flutter_clone/utils/utils.dart';
import 'package:instagram_flutter_clone/view_models/auth_view_model.dart';
import 'package:instagram_flutter_clone/view_models/sign_up_view_model.dart';
import 'package:instagram_flutter_clone/widgets/text_field_input.dart';

class SignUpScreen extends HookConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final bioController = useTextEditingController();
    final usernameController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final signUpState = ref.watch(signUpViewModelProvider);
    final authState = ref.watch(authViewModelProvider);

    useEffect(() {
      void listener() {
        final state = ref.read(signUpViewModelProvider);
        if (state.serverEmailError != null) {
          ref.read(signUpViewModelProvider.notifier).clearServerEmailError();
          formKey.currentState?.validate();
        }
        ref
            .read(signUpViewModelProvider.notifier)
            .checkEmailDebounced(emailController.text);
      }

      emailController.addListener(listener);
      return () => emailController.removeListener(listener);
    }, [emailController]);

    Future<void> selectImage() async {
      Uint8List? img = await pickImage(ImageSource.gallery);
      if (img != null) {
        ref.read(signUpViewModelProvider.notifier).setImage(img);
      }
    }

    void signUpUser() async {
      if (!formKey.currentState!.validate()) return;

      if (signUpState.image == null) {
        showSnackBar(content: 'Please select a profile image', ctx: context);
        return;
      }

      final res = await ref.read(signUpViewModelProvider.notifier).signUp(
            email: emailController.text,
            password: passwordController.text,
            username: usernameController.text,
            bio: bioController.text,
          );

      if (res.contains('success') && context.mounted) {
        showSnackBar(
          content: 'Account created successfully!',
          ctx: context,
          isError: false,
        );
        Navigator.of(context).pop();
      } else {
        if (!context.mounted) return;
        showSnackBar(
          content: res,
          ctx: context,
          isError: true,
        );
        if (res.contains('already in use')) {
          formKey.currentState!.validate();
        }
      }
    }

    void signInWithGoogle() async {
      final authNotifier = ref.read(authViewModelProvider.notifier);
      String res = await authNotifier.signInWithGoogle();
      if (res == "success" && context.mounted) {
        showSnackBar(
          content: 'Google Sign In successful!',
          ctx: context,
          isError: false,
        );
        Navigator.of(context).pop();
      } else if (res != "cancelled" && context.mounted) {
        showSnackBar(content: res, ctx: context, isError: true);
      }
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.2,
            colors: [
              Color(0xFF1B1F2D), // Ambient indigo-navy
              Color(0xFF0C0D11), // Midnight carbon
              Color(0xFF000000), // Pure black
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFF0095F6)],
                        ).createShader(bounds),
                        child: const Text(
                          'Lumi',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 40),
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF833AB4), // Purple
                                Color(0xFFFD1D1D), // Red-orange
                                Color(0xFFF77737), // Orange
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: signUpState.image != null
                                ? CircleAvatar(
                                    radius: 58,
                                    backgroundImage:
                                        MemoryImage(signUpState.image!),
                                    backgroundColor: Colors.transparent,
                                  )
                                : CircleAvatar(
                                    radius: 58,
                                    backgroundImage: const NetworkImage(
                                      "https://i.stack.imgur.com/l60Hf.png",
                                    ),
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.1),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: signUpState.isLoading || authState.isLoading ? null : selectImage,
                            child: Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0095F6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    TextFieldInput(
                      hintText: 'Choose a username',
                      textInputType: TextInputType.text,
                      textEditingController: usernameController,
                      enabled: !signUpState.isLoading && !authState.isLoading,
                      prefixIcon:
                          const Icon(Icons.person_outline, color: Colors.grey),
                      textInputAction: TextInputAction.next,
                      validator: (val) =>
                          val!.isEmpty ? 'Username is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFieldInput(
                      hintText: 'Enter your email',
                      textInputType: TextInputType.emailAddress,
                      textEditingController: emailController,
                      enabled: !signUpState.isLoading && !authState.isLoading,
                      prefixIcon:
                          const Icon(Icons.email_outlined, color: Colors.grey),
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        if (signUpState.serverEmailError != null) {
                          return signUpState.serverEmailError;
                        }
                        if (val == null || val.isEmpty) {
                          return 'Email is required';
                        }
                        if (signUpState.isCheckingEmail) {
                          return null;
                        }
                        final emailRegExp =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegExp.hasMatch(val)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFieldInput(
                      hintText: 'Create a password',
                      textInputType: TextInputType.visiblePassword,
                      textEditingController: passwordController,
                      isPass: true,
                      enabled: !signUpState.isLoading && !authState.isLoading,
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.grey),
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Password is required';
                        }
                        if (val.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]')
                            .hasMatch(val)) {
                          return 'Password must contain letters and numbers';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFieldInput(
                      hintText: 'Confirm password',
                      textInputType: TextInputType.visiblePassword,
                      textEditingController: confirmPasswordController,
                      isPass: true,
                      enabled: !signUpState.isLoading && !authState.isLoading,
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.grey),
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (val != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFieldInput(
                      hintText: 'Tell us about yourself',
                      textInputType: TextInputType.text,
                      textEditingController: bioController,
                      enabled: !signUpState.isLoading && !authState.isLoading,
                      prefixIcon:
                          const Icon(Icons.info_outline, color: Colors.grey),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) =>
                          signUpState.isLoading || authState.isLoading
                              ? null
                              : signUpUser(),
                      validator: (val) =>
                          val!.isEmpty ? 'Bio is required' : null,
                    ),
                    const SizedBox(height: 32),
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: signUpState.isLoading || authState.isLoading
                                ? [
                                    Colors.grey.withValues(alpha: 0.5),
                                    Colors.grey.withValues(alpha: 0.5),
                                  ]
                                : [
                                    const Color(0xFF0095F6),
                                    const Color(0xFF0074CC),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: signUpState.isLoading ||
                                  authState.isLoading
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: InkWell(
                          onTap: signUpState.isLoading || authState.isLoading
                              ? null
                              : signUpUser,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: signUpState.isLoading ||
                                      authState.isEmailPasswordLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child:
                              Text('OR', style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (authState.isGoogleLoading)
                      const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    else
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: signUpState.isLoading || authState.isLoading ? null : signInWithGoogle,
                          borderRadius: BorderRadius.circular(24),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 24),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white.withValues(alpha: 0.03),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.g_mobiledata,
                                    color: Colors.redAccent.shade100, size: 30),
                                const SizedBox(width: 4),
                                const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: signUpState.isLoading || authState.isLoading
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                },
                          child: const Text(
                            'Log in.',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
