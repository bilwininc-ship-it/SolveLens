// Main Dashboard Screen - Premium Elite Academic Interface
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../camera/camera_screen.dart';
import '../notes/notes_screen.dart';
import '../chat/super_chat_screen.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_drawer.dart';
import '../../theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/usecases/get_question_history_usecase.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../solution/ai_solution_screen.dart';
import '../../providers/solution_provider.dart';
import '../../providers/user_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GetQuestionHistoryUseCase _getHistoryUseCase = getIt<GetQuestionHistoryUseCase>();
  int _solvedQuestionsCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final result = await _getHistoryUseCase(userId: user.uid);
        result.fold(
          (failure) => setState(() => _solvedQuestionsCount = 0),
          (questions) => setState(() => _solvedQuestionsCount = questions.length),
        );
      }
    } catch (e) {
      debugPrint('Stats loading error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Student';
    final firstName = userName.split(' ').first;

    return Scaffold(
      backgroundColor: AppTheme.lightGrey, // Premium light grey background #F8FAFC
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          color: AppTheme.primaryNavy,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20), // Reduced padding for better fit
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium Header with Menu
                _buildPremiumHeader(firstName),
                const SizedBox(height: 28), // Reduced from 32

                // Elegant Dashboard Title
                _buildDashboardTitle(),
                const SizedBox(height: 20), // Reduced from 24

                // Premium Stats Card
                _buildPremiumStatsCard(),
                const SizedBox(height: 28), // Reduced from 32

                // Features Section Title
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: AppTheme.primaryNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 18), // Reduced from 20

                // Premium Feature Cards
                _buildPremiumFeatureCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(String firstName) {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 18) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Row(
      children: [
        // SolveLens Logo
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cleanWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 2),
                blurRadius: 8,
                color: const Color(0x0A000000),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: const Icon(
            Icons.school_rounded,
            color: AppTheme.primaryNavy,
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        
        // Menu button - Premium Navy
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cleanWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 2),
                blurRadius: 8,
                color: const Color(0x0A000000),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.menu_rounded, color: AppTheme.primaryNavy, size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        const SizedBox(width: 16),
        
        // Welcome text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: AppTheme.mediumGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    firstName,
                    style: const TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '👋',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Credits Chip - Elite Glassmorphism Design
        _buildCreditsChip(),
      ],
    );
  }

  Widget _buildCreditsChip() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final credits = userProvider.remainingCredits;
        final isLoading = userProvider.isLoading;

        return LayoutBuilder(
          builder: (context, constraints) {
            // Use compact design for smaller screens
            final isCompact = constraints.maxWidth < 400;
            
            return Container(
              constraints: const BoxConstraints(
                maxWidth: 110, // Prevent overflow
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 10 : 12, 
                vertical: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryNavy.withOpacity(0.95),
                    AppTheme.primaryNavy.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 3),
                    blurRadius: 10,
                    color: AppTheme.primaryNavy.withOpacity(0.2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppTheme.premiumGold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.diamond_rounded,
                      color: AppTheme.premiumGold,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLoading ? '...' : '$credits',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            height: 1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1.5),
                        const Text(
                          'Credits',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.4,
                            height: 1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDashboardTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.cleanWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 15,
            color: const Color(0x0D000000),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Dashboard',
            style: TextStyle(
              color: AppTheme.primaryNavy,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Reduced from 24
      decoration: BoxDecoration(
        color: AppTheme.cleanWhite, // Premium white background
        borderRadius: BorderRadius.circular(20), // Reduced from 24
        boxShadow: [
          // Airy Shadow
          BoxShadow(
            offset: const Offset(0, 3),
            blurRadius: 12,
            color: const Color(0x0D000000),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPremiumStatItem(
            icon: Icons.check_circle_rounded,
            value: _isLoading ? '...' : '$_solvedQuestionsCount',
            label: 'Solved',
            color: AppTheme.primaryNavy,
          ),
          Container(
            height: 45,
            width: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.mediumGrey.withOpacity(0.0),
                  AppTheme.mediumGrey.withOpacity(0.15),
                  AppTheme.mediumGrey.withOpacity(0.0),
                ],
              ),
            ),
          ),
          _buildPremiumStatItem(
            icon: Icons.local_fire_department_rounded,
            value: '0',
            label: 'Streak',
            color: AppTheme.warningOrange,
          ),
          Container(
            height: 45,
            width: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.mediumGrey.withOpacity(0.0),
                  AppTheme.mediumGrey.withOpacity(0.15),
                  AppTheme.mediumGrey.withOpacity(0.0),
                ],
              ),
            ),
          ),
          _buildPremiumStatItem(
            icon: Icons.star_rounded,
            value: '0',
            label: 'Notes',
            color: AppTheme.premiumGold,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(9), // Reduced from 10
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(11), // Reduced from 12
          ),
          child: Icon(icon, color: color, size: 22), // Reduced from 26
        ),
        const SizedBox(height: 10), // Reduced from 12
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.primaryNavy,
            fontSize: 22, // Reduced from 24
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 3), // Reduced from 4
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.mediumGrey,
            fontSize: 11, // Reduced from 12
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumFeatureCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card 1: Scan & Solve
        DashboardCard(
          icon: Icons.camera_alt_rounded,
          title: '📸 Scan & Solve',
          subtitle: 'Take a photo of your question, get instant AI mentor help',
          iconColor: AppTheme.primaryNavy,
          onTap: () async {
            // Navigate to camera and get the captured image
            final File? capturedImage = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraScreen()),
            );

            // If image was captured, navigate to AI Solution Screen
            if (capturedImage != null && mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => getIt<SolutionProvider>(),
                    child: AISolutionScreen(imageFile: capturedImage),
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 18), // Reduced from 24

        // Card 2: Super Chat (Unified Interface)
        DashboardCard(
          icon: Icons.chat_bubble_rounded,
          title: '💬 Super Chat',
          subtitle: 'Text, voice, or photos - chat with your AI Professor',
          iconColor: AppTheme.primaryNavy,
          badge: 'NEW',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SuperChatScreen()),
            );
          },
        ),
        const SizedBox(height: 18), // Reduced from 24

        // Card 3: My Smart Notes
        DashboardCard(
          icon: Icons.bookmark_rounded,
          title: '📝 My Smart Notes',
          subtitle: 'Quickly access your starred important solutions',
          iconColor: AppTheme.primaryNavy,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotesScreen()),
            );
          },
        ),
      ],
    );
  }
}
