// Academic Research Station Dashboard - Elite Premium Interface
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../camera/camera_screen.dart';
import '../notes/notes_screen.dart';
import '../chat/super_chat_screen.dart';
import '../../widgets/active_task_card.dart';
import '../../widgets/grid_menu_card.dart';
import '../../widgets/recent_activity_card.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_provider.dart';
import '../../providers/solution_provider.dart';
import '../solution/ai_solution_screen.dart';
import '../../../core/di/service_locator.dart';
import '../../../domain/usecases/get_question_history_usecase.dart';
import 'dart:io';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final GetQuestionHistoryUseCase _getHistoryUseCase = getIt<GetQuestionHistoryUseCase>();
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  DateTime? _lastUpdateTime;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.forward();
    _loadRecentActivities();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentActivities() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final result = await _getHistoryUseCase(userId: user.uid);
        result.fold(
          (failure) {
            setState(() {
              _recentActivities = [];
              _lastUpdateTime = null;
            });
          },
          (questions) {
            setState(() {
              _recentActivities = questions.take(5).map((q) {
                return {
                  'query': q.question ?? 'No question',
                  'tag': _getTagFromQuestion(q.question ?? ''),
                  'time': _getTimeAgo(q.createdAt),
                  'timestamp': q.createdAt,
                };
              }).toList();
              
              // Set last update time to most recent activity
              if (_recentActivities.isNotEmpty && _recentActivities[0]['timestamp'] != null) {
                _lastUpdateTime = _recentActivities[0]['timestamp'] as DateTime;
              } else {
                _lastUpdateTime = DateTime.now();
              }
            });
          },
        );
      }
    } catch (e) {
      debugPrint('Recent activities loading error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getTagFromQuestion(String question) {
    final lowercaseQ = question.toLowerCase();
    if (lowercaseQ.contains('physics') || lowercaseQ.contains('quantum') || lowercaseQ.contains('mechanics')) {
      return '#Physics';
    } else if (lowercaseQ.contains('math') || lowercaseQ.contains('calculus') || lowercaseQ.contains('algebra')) {
      return '#Mathematics';
    } else if (lowercaseQ.contains('chemistry') || lowercaseQ.contains('molecule')) {
      return '#Chemistry';
    } else if (lowercaseQ.contains('biology') || lowercaseQ.contains('cell')) {
      return '#Biology';
    }
    return '#General';
  }

  String _getTimeAgo(DateTime? timestamp) {
    if (timestamp == null) return 'Just now';
    final diff = DateTime.now().difference(timestamp);
    if (diff.inDays > 1) return '${diff.inDays} days ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
    return 'Just now';
  }

  String _getLastUpdateText() {
    if (_lastUpdateTime == null) return 'No recent updates';
    return 'Last Update: ${_getTimeAgo(_lastUpdateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? 'Researcher';
    final firstName = userName.split(' ').first;

    return Scaffold(
      backgroundColor: AppTheme.ivory,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRecentActivities,
          color: AppTheme.cyanNeon,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Header with Greeting & Credits
                  _buildPremiumHeader(firstName),
                  const SizedBox(height: 48),

                  // Active Task Card (Hero Section)
                  FadeTransition(
                    opacity: _animationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOut,
                      )),
                      child: ActiveTaskCard(
                        onTap: () => _navigateToSuperChat(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Grid Menu - The 4 Pillars
                  _buildGridMenu(),
                  const SizedBox(height: 64),

                  // Recent Scholarly Activity
                  _buildRecentActivity(),
                ],
              ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _animationController,
                child: Text(
                  '$greeting,',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryNavy,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FadeTransition(
                opacity: _animationController,
                child: Text(
                  firstName,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.primaryNavy.withOpacity(0.7),
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Glassmorphism Credits Chip
        _buildGlassmorphismCreditsChip(),
      ],
    );
  }

  Widget _buildGlassmorphismCreditsChip() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final credits = userProvider.remainingCredits;
        final isLoading = userProvider.isLoading;

        return FadeTransition(
          opacity: _animationController,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 0),
                  blurRadius: 20,
                  color: AppTheme.cyanNeon.withOpacity(0.3),
                ),
                BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                  color: AppTheme.primaryNavy.withOpacity(0.08),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLoading ? '...' : '$credits',
                      style: const TextStyle(
                        color: AppTheme.primaryNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '/ 15',
                      style: TextStyle(
                        color: AppTheme.primaryNavy.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Credits',
                      style: TextStyle(
                        color: AppTheme.primaryNavy,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridMenu() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: GridMenuCard(
                  icon: Icons.chat_bubble_rounded,
                  title: 'New Inquiry',
                  description: 'Start a deep research conversation',
                  onTap: () => _navigateToSuperChat(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: GridMenuCard(
                  icon: Icons.camera_alt_rounded,
                  title: 'Document Scan',
                  description: 'Camera & OCR analysis',
                  onTap: () => _navigateToDocumentScan(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: GridMenuCard(
                  icon: Icons.folder_rounded,
                  title: 'Research Vault',
                  description: 'History & saved notes',
                  onTap: () => _navigateToResearchVault(),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: GridMenuCard(
                  icon: Icons.insights_rounded,
                  title: 'Academic Insights',
                  description: 'AI-generated statistics',
                  onTap: () => _showAcademicInsights(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Scholarly Activity',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryNavy,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => _navigateToResearchVault(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View all',
                    style: TextStyle(
                      color: AppTheme.primaryNavy.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.primaryNavy.withOpacity(0.6),
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(
                color: AppTheme.cyanNeon,
              ),
            ),
          )
        else if (_recentActivities.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryNavy.withOpacity(0.08),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 48,
                    color: AppTheme.primaryNavy.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recent activity yet',
                    style: TextStyle(
                      color: AppTheme.primaryNavy.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your first inquiry above',
                    style: TextStyle(
                      color: AppTheme.primaryNavy.withOpacity(0.4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              ...List.generate(
                _recentActivities.length,
                (index) {
                  final activity = _recentActivities[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 80)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(-20 * (1 - value), 0),
                          child: child,
                        ),
                      );
                    },
                    child: RecentActivityCard(
                      query: activity['query']!,
                      tag: activity['tag']!,
                      time: activity['time']!,
                      onTap: () => _navigateToResearchVault(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Dynamic Last Update - Wrapped to prevent overflow
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 40,
                ),
                child: Text(
                  _getLastUpdateText(),
                  style: TextStyle(
                    color: AppTheme.primaryNavy.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Navigation Methods
  void _navigateToSuperChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SuperChatScreen()),
    );
  }

  Future<void> _navigateToDocumentScan() async {
    final File? capturedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );

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
  }

  void _navigateToResearchVault() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotesScreen()),
    );
  }

  void _showAcademicInsights() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(
              Icons.insights_rounded,
              size: 64,
              color: AppTheme.cyanNeon,
            ),
            const SizedBox(height: 16),
            const Text(
              'Academic Insights',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'AI-generated statistics and performance analytics coming soon!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.primaryNavy.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}