import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/task_service.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';
import '../settings/notifications_settings_screen.dart';
import '../settings/appearance_settings_screen.dart';
import '../settings/email_automation_screen.dart';
import '../settings/privacy_security_screen.dart';
import '../settings/help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final TaskService _taskService = TaskService();
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.lato(color: AppColors.textMedium)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.lato(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Sign Out',
                style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 32,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B3A2A), Color(0xFF8B5E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  FadeInDown(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 44,
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        backgroundColor: AppColors.primaryLight,
                        child: user?.photoURL == null
                            ? Text(
                                (user?.displayName ?? 'U')[0],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 36),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      user?.displayName ?? 'User',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      user?.email ?? '',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Stats
          SliverToBoxAdapter(
            child: FutureBuilder<Map<String, int>>(
              future: _taskService.getTaskStats(),
              builder: (context, snapshot) {
                final stats = snapshot.data ??
                    {'total': 0, 'completed': 0, 'pending': 0};
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildStatItem(
                          '${stats['total']}', 'Total Tasks'),
                      _buildDivider(),
                      _buildStatItem(
                          '${stats['completed']}', 'Completed'),
                      _buildDivider(),
                      _buildStatItem(
                          '${stats['pending']}', 'Pending'),
                    ],
                  ),
                );
              },
            ),
          ),

          // Settings
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Notifications
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: _buildSettingTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage reminder settings',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const NotificationsSettingsScreen(),
                        ),
                      ),
                    ),
                  ),

                  // Appearance
                  FadeInUp(
                    delay: const Duration(milliseconds: 150),
                    child: _buildSettingTile(
                      icon: Icons.palette_outlined,
                      title: 'Appearance',
                      subtitle: 'Theme and display options',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AppearanceSettingsScreen(),
                        ),
                      ),
                    ),
                  ),

                  // Email Automation
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildSettingTile(
                      icon: Icons.email_outlined,
                      title: 'Email Automation',
                      subtitle: 'Configure email reminders',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const EmailAutomationScreen(),
                        ),
                      ),
                    ),
                  ),

                  // Privacy & Security
                  FadeInUp(
                    delay: const Duration(milliseconds: 250),
                    child: _buildSettingTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy & Security',
                      subtitle: 'Data and account security',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PrivacySecurityScreen(),
                        ),
                      ),
                    ),
                  ),

                  // Help & Support
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: _buildSettingTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'FAQs and contact us',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Out Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout,
                            color: AppColors.error),
                        label: Text(
                          'Sign Out',
                          style: GoogleFonts.lato(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          side: const BorderSide(
                              color: AppColors.error),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      'AI Task Bot v1.0.0',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceBrown,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 11,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => const SizedBox(width: 10);

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryPale,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}