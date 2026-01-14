// Premium Elite Profile Screen - Ultra-Clean Design
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../subscription/subscription_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: AppTheme.lightGrey, // Premium light grey #F8FAFC
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.primaryNavy,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppTheme.primaryNavy,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // User Avatar & Name Section
              _buildUserHeader(user),
              const SizedBox(height: 32),

              // Subscription Section
              _buildSubscriptionCard(context),
              const SizedBox(height: 20),

              // Account Settings
              _buildSettingsSection(context),
              const SizedBox(height: 20),

              // Logout Button
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(User? user) {
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? 'email@example.com';
    final photoUrl = user?.photoURL;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.cleanWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 15,
            color: const Color(0x0D000000),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryNavy.withOpacity(0.15),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  color: const Color(0x08000000),
                ),
              ],
            ),
            child: ClipOval(
              child: photoUrl != null
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultAvatar(displayName),
                    )
                  : _buildDefaultAvatar(displayName),
            ),
          ),
          const SizedBox(height: 20),

          // Name
          Text(
            displayName,
            style: const TextStyle(
              color: AppTheme.primaryNavy,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Email
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              email,
              style: const TextStyle(
                color: AppTheme.mediumGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryNavy.withOpacity(0.15),
            AppTheme.primaryNavy.withOpacity(0.05),
          ],
        ),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: AppTheme.primaryNavy,
            fontSize: 40,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cleanWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 15,
            color: const Color(0x0D000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.premiumGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppTheme.premiumGold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription Status',
                      style: TextStyle(
                        color: AppTheme.primaryNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Free Plan',
                      style: TextStyle(
                        color: AppTheme.premiumGold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Premium Features Info
          const Text(
            'Upgrade to Premium for unlimited questions, voice assistant, and exclusive features.',
            style: TextStyle(
              color: AppTheme.mediumGrey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Upgrade Button - 50px height, 24px corners
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: AppTheme.cleanWhite,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upgrade_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cleanWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 15,
            color: const Color(0x0D000000),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Coming soon!'),
                  backgroundColor: AppTheme.primaryNavy,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          Divider(
            color: AppTheme.mediumGrey.withOpacity(0.1),
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
          _buildSettingsTile(
            icon: Icons.language_outlined,
            title: 'Language Settings',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Coming soon!'),
                  backgroundColor: AppTheme.primaryNavy,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          Divider(
            color: AppTheme.mediumGrey.withOpacity(0.1),
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Coming soon!'),
                  backgroundColor: AppTheme.primaryNavy,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryNavy.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryNavy,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryNavy,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: AppTheme.mediumGrey.withOpacity(0.5),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50, // Professional height
      child: OutlinedButton(
        onPressed: () => _handleLogout(context),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTheme.cleanWhite,
          side: BorderSide(
            color: AppTheme.errorRed.withOpacity(0.3),
            width: 1.5,
          ),
          foregroundColor: AppTheme.errorRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24), // 24px corners
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cleanWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppTheme.primaryNavy,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: AppTheme.mediumGrey,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.mediumGrey,
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.cleanWhite,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
