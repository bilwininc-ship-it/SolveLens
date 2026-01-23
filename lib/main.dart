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
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/maintenance/presentation/screens/maintenance_screen.dart';
import 'features/maintenance/presentation/screens/update_required_screen.dart';

// Service imports
import 'services/firebase/firebase_service.dart';
import 'services/ads/ads_service.dart';
import 'services/analytics/analytics_service.dart';
import 'services/remote_config/remote_config_service.dart';
import 'core/utils/logger.dart';

// App version - Update this with each release
const String currentAppVersion = '1.0.0';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase Initialize
  await FirebaseService.initialize();
  
  // Initialize Remote Config (PHASE 8: Maintenance & Version Control)
  await RemoteConfigService.initialize();
  
  // Initialize Logger with Firebase services
  Logger.initialize(
    analytics: FirebaseService.analytics,
    crashlytics: FirebaseService.crashlytics,
  );
  
  // Initialize Analytics Service (Marketing Engine)
  AnalyticsService.initialize(
    analytics: FirebaseService.analytics,
    crashlytics: FirebaseService.crashlytics,
  );
  
  // Ads Initialize (Only for Mobile - Skip on Web)
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
/// PHASE 8: Includes Maintenance & Version Guard Logic
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
        
        // ==================== PHASE 8: APP GUARDS ====================
        
        // Guard 1: Check Maintenance Mode
        if (RemoteConfigService.isMaintenanceMode) {
          return const MaintenanceScreen();
        }
        
        // Guard 2: Check Version Requirement
        if (RemoteConfigService.isUpdateRequired(currentAppVersion)) {
          return UpdateRequiredScreen(
            currentVersion: currentAppVersion,
            minimumVersion: RemoteConfigService.minimumVersion,
          );
        }
        
        // ==================== NORMAL APP FLOW ====================
        
        return Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            // Determine which screen to show
            Widget content;
            
            if (!authProvider.isAuthenticated) {
              // Not logged in - show login screen
              content = const LoginScreen();
            } else if (authProvider.isFirstTime) {
              // First time user - show onboarding
              content = const OnboardingScreen();
            } else {
              // Regular user - show dashboard
              content = const DashboardScreen();
            }
            
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