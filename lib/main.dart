import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/screens/auth/auth_wrapper.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'core/di/service_locator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for Navy & White theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // Dark icons for white background
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Service Locator (DI)
  await setupServiceLocator();
  
  runApp(const SolveLensApp());
}

class SolveLensApp extends StatelessWidget {
  const SolveLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'SolveLens - Elite Professor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // Premium Navy & White Theme
        home: const AuthWrapper(),
      ),
    );
  }
}
