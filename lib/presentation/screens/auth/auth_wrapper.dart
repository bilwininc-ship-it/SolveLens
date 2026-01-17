import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import '../../providers/user_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder for reactive auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF000000),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              ),
            ),
          );
        }

        // Get UserProvider instance
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Redirect immediately based on auth state
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in - start listening to user document
          final userId = snapshot.data!.uid;
          userProvider.startListening(userId);
          
          // Go to Dashboard
          return const HomeScreen();
        } else {
          // User is not logged in - stop listening
          userProvider.stopListening();
          
          // Show login
          return const LoginScreen();
        }
      },
    );
  }
}