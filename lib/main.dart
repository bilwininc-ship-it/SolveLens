import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  
  // Set system UI overlay style only for mobile platforms
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    // Set preferred orientations only for mobile
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
  }
  
  // Initialize Service Locator (DI)
  try {
    await setupServiceLocator();
    print('✅ Service Locator initialized successfully');
  } catch (e) {
    print('❌ Service Locator initialization error: $e');
  }
  
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
