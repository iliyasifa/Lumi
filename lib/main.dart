import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lumi/firebase_options.dart';
import 'package:lumi/utils/mobile_screen_layout.dart';
import 'package:lumi/utils/responsive_layout_screen.dart';
import 'package:lumi/utils/web_screen_layout.dart';
import 'package:lumi/screens/auth/login_screen.dart';
import 'package:lumi/utils/colors.dart';
import 'package:lumi/resources/notification_service.dart';
import 'package:lumi/view_models/auth/auth_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Lumi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // User is logged in
            if (snapshot.hasData) {
              final uid = snapshot.data!.uid;
              Future.microtask(() {
                ref.read(authViewModelProvider.notifier).refreshUser();
                NotificationService().onUserLogin(uid);
              });
              return const ReponsiveLayout(
                mobileScreenLayout: MobileScreenLayout(),
                webScreenLayout: WebScreenLayout(),
              );
            } else {
              NotificationService().onUserLogout();
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            }
          }

          // Connection is still waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }

          // Otherwise, show login screen
          return const LoginScreen();
        },
      ),
    );
  }
}
