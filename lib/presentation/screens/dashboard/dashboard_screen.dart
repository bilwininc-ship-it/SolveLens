// Main Dashboard Screen - Personalized Learning Hub
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../camera/camera_screen.dart';
import '../notes/notes_screen.dart';
import '../voice/voice_chat_screen.dart';
import '../../widgets/dashboard_card.dart';
import '../../theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/usecases/get_question_history_usecase.dart';

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
    final userName = user?.displayName ?? 'Öğrenci';
    final firstName = userName.split(' ').first;

    return Scaffold(
      backgroundColor: AppTheme.deepBlack,
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
      greeting = 'Günaydın';
    } else if (hour < 18) {
      greeting = 'İyi günler';
    } else {
      greeting = 'İyi akşamlar';
    }

    return Column(
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
           'Bugün ne öğrenmek istersin?',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 16,
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
            label: 'Çözülen Soru',
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
            label: 'Günlük Seri',
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
            label: 'Kayıtlı Not',
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
          'Özellikler',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Card 1: Photo & Solve
        DashboardCard(
          icon: Icons.camera_alt,
          title: 'Fotoğraf Çek ve Çöz',
          subtitle: 'Sorunun fotoğrafını çek, AI mentor anında çözsün',
          iconColor: AppTheme.primaryPurple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraScreen()),
            );
          },
        ),
        const SizedBox(height: 16),

        // Card 2: Voice Mentor
        DashboardCard(
          icon: Icons.mic,
          title: 'Sesli Mentor',
          subtitle: 'Sorunu sesle sor, cevabı dinle veya oku',
          iconColor: Colors.blue,
          badge: 'YENİ',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VoiceChatScreen()),
            );
          },
        ),
        const SizedBox(height: 16),

        // Card 3: Important Notes
        DashboardCard(
          icon: Icons.bookmark,
          title: 'Önemli Notlarım',
          subtitle: 'Kaydettiğin önemli çözümlere hızlıca eriş',
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
