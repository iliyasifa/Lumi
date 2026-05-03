import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_flutter_clone/screens/explore_screen.dart';
import 'package:instagram_flutter_clone/utils/colors.dart';
import 'package:instagram_flutter_clone/utils/utils.dart';
import 'package:instagram_flutter_clone/screens/login_screen.dart';
import 'package:instagram_flutter_clone/view_models/auth_view_model.dart';
import 'package:instagram_flutter_clone/widgets/text_field_input.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  Future<void> selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  void signUpUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      showSnackBar(content: 'Please select a profile image', ctx: context);
      return;
    }
    final authViewModel = context.read<AuthViewModel>();
    final String res = await authViewModel.signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      file: _image!,
    );
    debugPrint(res);

    if (res.contains('success') && mounted) {
      showSnackBar(
        content: 'Account created successfully!',
        ctx: context,
        isError: false,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ExploreScreen(),
        ),
      );
    } else {
      if (!mounted) return;
      showSnackBar(
        content: res.toString(),
        ctx: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121212),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    SvgPicture.asset(
                      'assets/ic_instagram.svg',
                      height: 64,
                      colorFilter: const ColorFilter.mode(
                        primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: _image != null
                              ? CircleAvatar(
                                  radius: 64,
                                  backgroundImage: MemoryImage(_image!),
                                  backgroundColor: Colors.white,
                                )
                              : CircleAvatar(
                                  radius: 64,
                                  backgroundImage: const NetworkImage(
                                    "https://i.stack.imgur.com/l60Hf.png",
                                  ),
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.1),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: const BoxDecoration(
                              color: blueColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: selectImage,
                              icon: const Icon(
                                Icons.add_a_photo,
                                color: Colors.white,
                                size: 20,
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
                      textEditingController: _usernameController,
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
                      textEditingController: _emailController,
                      prefixIcon:
                          const Icon(Icons.email_outlined, color: Colors.grey),
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
                      hintText: 'Create a password',
                      textInputType: TextInputType.visiblePassword,
                      textEditingController: _passwordController,
                      isPass: true,
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
                      textEditingController: _confirmPasswordController,
                      isPass: true,
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.grey),
                      textInputAction: TextInputAction.next,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (val != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFieldInput(
                      hintText: 'Tell us about yourself',
                      textInputType: TextInputType.text,
                      textEditingController: _bioController,
                      prefixIcon:
                          const Icon(Icons.info_outline, color: Colors.grey),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => signUpUser(),
                      validator: (val) =>
                          val!.isEmpty ? 'Bio is required' : null,
                    ),
                    const SizedBox(height: 32),
                    InkWell(
                      onTap: signUpUser,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0095F6),
                              Color(0xFF0074CC),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: context.watch<AuthViewModel>().isLoading
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
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
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
