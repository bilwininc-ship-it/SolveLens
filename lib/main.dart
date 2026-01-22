import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Core imports
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';

// Feature imports
import 'features/auth/logic/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

// Service imports
import 'services/firebase/firebase_service.dart';
import 'services/ads/ads_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase Initialize
  await FirebaseService.initialize();
  
  // Ads Initialize (Only for Mobile)
  if (!kIsWeb) {
    await AdsService.initialize();
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
      ],
      child: MaterialApp(
        title: 'SolveLens - AI Sports Analyst',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const ResponsiveLayout(),
      ),
    );
  }
}

/// Responsive Layout with LayoutBuilder
/// Prevents overflow on both Chrome Web and Android
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get screen dimensions
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        // Determine if it's a mobile or web layout
        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;
        
        // Debug info (optional, can be removed in production)
        debugPrint('SolveLens Layout: width=$width, height=$height, '
            'isMobile=$isMobile, isTablet=$isTablet, isDesktop=$isDesktop, kIsWeb=$kIsWeb');
        
        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Main content with SingleChildScrollView to prevent overflow
            final content = authProvider.isAuthenticated
                ? const DashboardScreen()
                : const LoginScreen();
            
            // Wrap in SafeArea and Scaffold for proper layout handling
            return Scaffold(
              backgroundColor: AppColors.navy,
              body: SafeArea(
                child: SizedBox(
                  width: width,
                  height: height,
                  child: content,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Layout Configuration Helper
class LayoutConfig {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final double width;
  final double height;
  
  const LayoutConfig({
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.width,
    required this.height,
  });
  
  factory LayoutConfig.fromConstraints(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;
    
    return LayoutConfig(
      isMobile: width < 600,
      isTablet: width >= 600 && width < 1024,
      isDesktop: width >= 1024,
      width: width,
      height: height,
    );
  }
  
  /// Get responsive padding based on device type
  EdgeInsets get horizontalPadding {
    if (isDesktop) return const EdgeInsets.symmetric(horizontal: 48);
    if (isTablet) return const EdgeInsets.symmetric(horizontal: 32);
    return const EdgeInsets.symmetric(horizontal: 16);
  }
  
  /// Get responsive font size multiplier
  double get fontSizeMultiplier {
    if (isDesktop) return 1.1;
    if (isTablet) return 1.05;
    return 1.0;
  }
  
  /// Get max content width for centered layouts on large screens
  double get maxContentWidth {
    if (isDesktop) return 1200;
    if (isTablet) return 800;
    return width;
  }
}