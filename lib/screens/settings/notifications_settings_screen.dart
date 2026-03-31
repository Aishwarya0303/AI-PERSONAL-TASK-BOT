import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../utils/app_theme.dart';
import '../../services/notification_service.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _taskReminders = true;
  bool _deadlineAlerts = true;
  bool _dailySummary = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  int _reminderMinutes = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: _buildSectionTitle('Reminder Settings'),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 150),
                  child: _buildToggleTile(
                    icon: Icons.task_alt,
                    title: 'Task Reminders',
                    subtitle: 'Get notified before task deadline',
                    value: _taskReminders,
                    onChanged: (v) => setState(() => _taskReminders = v),
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildToggleTile(
                    icon: Icons.warning_amber_outlined,
                    title: 'Deadline Alerts',
                    subtitle: 'Alert when task is overdue',
                    value: _deadlineAlerts,
                    onChanged: (v) => setState(() => _deadlineAlerts = v),
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: _buildToggleTile(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Daily Summary',
                    subtitle: 'Morning summary of your tasks',
                    value: _dailySummary,
                    onChanged: (v) => setState(() => _dailySummary = v),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: _buildSectionTitle('Alert Style'),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: _buildToggleTile(
                    icon: Icons.volume_up_outlined,
                    title: 'Sound',
                    subtitle: 'Play sound for notifications',
                    value: _soundEnabled,
                    onChanged: (v) => setState(() => _soundEnabled = v),
                  ),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildToggleTile(
                    icon: Icons.vibration,
                    title: 'Vibration',
                    subtitle: 'Vibrate for notifications',
                    value: _vibrationEnabled,
                    onChanged: (v) =>
                        setState(() => _vibrationEnabled = v),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 450),
                  child: _buildSectionTitle('Reminder Time'),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: _buildReminderTimePicker(),
                ),
                const SizedBox(height: 32),
                FadeInUp(
                  delay: const Duration(milliseconds: 550),
                  child: _buildTestButton(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B3A2A), Color(0xFF8B5E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Manage your alerts',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
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
            child: Icon(icon, color: AppColors.primary, size: 20),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTimePicker() {
    final times = [10, 15, 30, 60];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notify me before:',
            style: GoogleFonts.lato(
              fontSize: 13,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: times.map((t) {
              final isSelected = _reminderMinutes == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _reminderMinutes = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceBrown,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      t < 60 ? '${t}m' : '1h',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textMedium,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        await NotificationService().showNotification(
          id: 999,
          title: 'Test Notification',
          body: 'Your notifications are working perfectly!',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Test notification sent!',
                  style: GoogleFonts.lato(color: Colors.white)),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      icon: const Icon(Icons.notifications_active, color: Colors.white),
      label: Text('Send Test Notification',
          style: GoogleFonts.lato(
              color: Colors.white, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
