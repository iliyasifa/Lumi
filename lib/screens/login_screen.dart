import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_flutter_clone/screens/sign_up_screen.dart';
import 'package:instagram_flutter_clone/utils/utils.dart';
import 'package:instagram_flutter_clone/view_models/auth_view_model.dart';
import 'package:instagram_flutter_clone/widgets/text_field_input.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final authState = ref.watch(authViewModelProvider);

    void loginUser() async {
      if (!formKey.currentState!.validate()) return;

      final authNotifier = ref.read(authViewModelProvider.notifier);
      String res = await authNotifier.loginUser(
        email: emailController.text,
        password: passwordController.text,
      );
      if (res == "success" && context.mounted) {
        showSnackBar(
          content: 'Login successful!',
          ctx: context,
          isError: false,
        );
        // StreamBuilder in main.dart will automatically switch home to ReponsiveLayout
      } else {
        if (!context.mounted) return;
        showSnackBar(content: res, ctx: context, isError: true);
      }
    }

    void signInWithGoogle() async {
      final authNotifier = ref.read(authViewModelProvider.notifier);
      String res = await authNotifier.signInWithGoogle();
      if (res == "success" && context.mounted) {
        showSnackBar(
          content: 'Login successful!',
          ctx: context,
          isError: false,
        );
        // StreamBuilder in main.dart will automatically switch home to ReponsiveLayout
      } else if (res != "cancelled" && context.mounted) {
        showSnackBar(content: res, ctx: context, isError: true);
      }
    }

    return Scaffold(
      body: PopScope(
        canPop: false,
        child: Container(
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
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 64),
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
                      const SizedBox(height: 64),
                      TextFieldInput(
                        hintText: 'Email address',
                        textInputType: TextInputType.emailAddress,
                        textEditingController: emailController,
                        enabled: !authState.isLoading,
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Colors.grey),
                        textInputAction: TextInputAction.next,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Email is required';
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
                        hintText: 'Password',
                        textInputType: TextInputType.visiblePassword,
                        textEditingController: passwordController,
                        isPass: true,
                        enabled: !authState.isLoading,
                        prefixIcon:
                            const Icon(Icons.lock_outline, color: Colors.grey),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            authState.isLoading ? null : loginUser(),
                        validator: (val) =>
                            val!.isEmpty ? 'Password is required' : null,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: authState.isLoading ? null : () {},
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: Ink(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: authState.isLoading
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
                            boxShadow: authState.isLoading
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
                            onTap: authState.isLoading ? null : loginUser,
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: authState.isEmailPasswordLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Log in',
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
                      const SizedBox(height: 32),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR',
                                style: TextStyle(color: Colors.grey)),
                          ),
                          Expanded(child: Divider(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 32),
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
                            onTap: authState.isLoading ? null : signInWithGoogle,
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
                      const Divider(color: Colors.grey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: authState.isLoading
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen(),
                                      ),
                                    );
                                  },
                            child: const Text(
                              'Sign up.',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
