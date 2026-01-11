// Main Dashboard Screen - Personalized Learning Hub
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../camera/camera_screen.dart';
import '../notes/notes_screen.dart';
import '../voice/voice_chat_screen.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/app_drawer.dart';
import '../../theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/usecases/get_question_history_usecase.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../solution/ai_solution_screen.dart';
import '../../providers/solution_provider.dart';

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
      backgroundColor: AppTheme.deepBlack,
      drawer: const AppDrawer(), // Add drawer for history
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadStats,
          color: AppTheme.primaryPurple,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                _buildWelcomeHeader(firstName),
                const SizedBox(height: 24),

                // Stats Card
                _buildStatsCard(),
                const SizedBox(height: 24),

                // Main Feature Cards
                _buildFeatureCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String firstName) {
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
        // Menu button to open drawer
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 28),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        const SizedBox(width: 8),
        
        // Welcome text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    firstName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '👋',
                    style: TextStyle(fontSize: 28),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'What shall we explore today?',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withValues(alpha: 0.2),
            AppTheme.primaryPurple.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.check_circle,
            value: _isLoading ? '...' : '$_solvedQuestionsCount',
            label: 'Solved',
            color: AppTheme.primaryPurple,
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            icon: Icons.local_fire_department,
            value: '0',
            label: 'Streak',
            color: Colors.orange,
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          _buildStatItem(
            icon: Icons.star,
            value: '0',
            label: 'Notes',
            color: Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Card 1: Scan & Solve
        DashboardCard(
          icon: Icons.camera_alt,
          title: '📸 Scan & Solve',
          subtitle: 'Take a photo of your question, get instant AI mentor help',
          iconColor: AppTheme.primaryPurple,
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
        const SizedBox(height: 16),

        // Card 2: Voice Mentor
        DashboardCard(
          icon: Icons.mic,
          title: '🎤 Voice Mentor',
          subtitle: 'Ask your question by voice, listen or read the answer',
          iconColor: Colors.blue,
          badge: 'NEW',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VoiceChatScreen()),
            );
          },
        ),
        const SizedBox(height: 16),

        // Card 3: My Smart Notes
        DashboardCard(
          icon: Icons.bookmark,
          title: '📝 My Smart Notes',
          subtitle: 'Quickly access your starred important solutions',
          iconColor: Colors.amber,
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
