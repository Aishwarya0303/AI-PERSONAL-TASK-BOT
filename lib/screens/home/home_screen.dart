import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/task_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive.dart';
import '../../models/task_model.dart';
import '../tasks/add_task_screen.dart';
import '../tasks/task_list_screen.dart';
import '../reminders/reminders_screen.dart';
import '../profile/profile_screen.dart';
import '../ai/ai_assistant_screen.dart';
import '../../widgets/task_card.dart';
import '../../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TaskService _taskService = TaskService();
  final User? user = FirebaseAuth.instance.currentUser;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getFirstName() {
    final name = user?.displayName ?? 'User';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _currentIndex == 0
          ? _buildHomeContent()
          : _currentIndex == 1
              ? const TaskListScreen()
              : _currentIndex == 2
                  ? const AIAssistantScreen()
                  : _currentIndex == 3
                      ? const RemindersScreen()
                      : ProfileScreen(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0 || _currentIndex == 1
          ? _buildFAB()
          : null,
    );
  }

  Widget _buildHomeContent() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildStatsRow()),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              Responsive.padding(context),
              Responsive.spacing(context, 24),
              Responsive.padding(context),
              12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FadeInLeft(
                  child: Text(
                    "Today's Tasks",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: Responsive.fontSize(context, 20),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                FadeInRight(
                  child: TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: Text(
                      'See all',
                      style: GoogleFonts.lato(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.fontSize(context, 13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildTodayTasks()),
        SliverToBoxAdapter(child: _buildAIBanner()),
        SliverToBoxAdapter(child: _buildUpcomingSection()),
        SliverToBoxAdapter(
            child: SizedBox(height: Responsive.spacing(context, 100))),
      ],
    );
  }

  Widget _buildHeader() {
    final p = Responsive.padding(context);
    final topPad = MediaQuery.of(context).padding.top + 16;
    return Container(
      padding: EdgeInsets.only(
        top: topPad,
        left: p,
        right: p,
        bottom: Responsive.spacing(context, 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FadeInLeft(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}! 👋',
                      style: GoogleFonts.lato(
                        fontSize: Responsive.fontSize(context, 14),
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFirstName(),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: Responsive.fontSize(context, 28),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              FadeInRight(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = 4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2),
                    ),
                    child: CircleAvatar(
                      radius: Responsive.isTablet(context) ? 30 : 24,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      backgroundColor: AppColors.primaryLight,
                      child: user?.photoURL == null
                          ? Text(
                              _getFirstName()[0],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    Responsive.fontSize(context, 20),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(context, 20)),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.spacing(context, 16),
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: Responsive.iconSize(context, 20)),
                  const SizedBox(width: 10),
                  Text(
                    'Search tasks...',
                    style: GoogleFonts.lato(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: Responsive.fontSize(context, 15),
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

  Widget _buildAIBanner() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = 2),
        child: Container(
          margin: EdgeInsets.fromLTRB(
            Responsive.padding(context),
            Responsive.spacing(context, 24),
            Responsive.padding(context),
            0,
          ),
          padding: EdgeInsets.all(Responsive.spacing(context, 16)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6B3A2A), Color(0xFFA0785A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius:
                BorderRadius.circular(Responsive.radius(context, 18)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(Responsive.spacing(context, 10)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome,
                    color: Colors.white,
                    size: Responsive.iconSize(context, 24)),
              ),
              SizedBox(width: Responsive.spacing(context, 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aria AI Assistant ✨',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: Responsive.fontSize(context, 16),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Ask me anything or add a task!',
                      style: GoogleFonts.lato(
                        fontSize: Responsive.fontSize(context, 12),
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return FutureBuilder<Map<String, int>>(
      future: _taskService.getTaskStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ??
            {'total': 0, 'completed': 0, 'pending': 0, 'today': 0};
        return Padding(
          padding: EdgeInsets.fromLTRB(
            Responsive.padding(context),
            Responsive.spacing(context, 20),
            Responsive.padding(context),
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: StatCard(
                    title: 'Total',
                    value: '${stats['total']}',
                    icon: Icons.list_alt,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 12)),
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: StatCard(
                    title: 'Done',
                    value: '${stats['completed']}',
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                ),
              ),
              SizedBox(width: Responsive.spacing(context, 12)),
              Expanded(
                child: FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: StatCard(
                    title: 'Today',
                    value: '${stats['today']}',
                    icon: Icons.today,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayTasks() {
    return StreamBuilder<List<TaskModel>>(
      stream: _taskService.getTodayTasksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                  color: AppColors.primary),
            ),
          );
        }

        final tasks = snapshot.data ?? [];

        if (tasks.isEmpty) {
          return FadeInUp(
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: Responsive.padding(context)),
              padding: EdgeInsets.all(Responsive.spacing(context, 30)),
              decoration: BoxDecoration(
                color: AppColors.surfaceBrown,
                borderRadius: BorderRadius.circular(
                    Responsive.radius(context, 20)),
              ),
              child: Column(
                children: [
                  Icon(Icons.celebration,
                      size: Responsive.iconSize(context, 48),
                      color: AppColors.primary.withValues(alpha: 0.5)),
                  SizedBox(height: Responsive.spacing(context, 12)),
                  Text(
                    'No tasks for today!',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: Responsive.fontSize(context, 18),
                      color: AppColors.textMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 6)),
                  Text(
                    'Add a task to get started',
                    style: GoogleFonts.lato(
                        fontSize: Responsive.fontSize(context, 14),
                        color: AppColors.textLight),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.padding(context)),
          itemCount: tasks.length > 3 ? 3 : tasks.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: TaskCard(
                task: tasks[index],
                onToggle: (val) => _taskService.toggleTaskComplete(
                    tasks[index].id, val),
                onDelete: () =>
                    _taskService.deleteTask(tasks[index].id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUpcomingSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.padding(context),
        Responsive.spacing(context, 24),
        Responsive.padding(context),
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInLeft(
            child: Text(
              'Upcoming Tasks',
              style: GoogleFonts.playfairDisplay(
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, 12)),
          StreamBuilder<List<TaskModel>>(
            stream: _taskService.getPendingTasksStream(),
            builder: (context, snapshot) {
              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No pending tasks 🎉',
                      style: GoogleFonts.lato(
                          color: AppColors.textLight,
                          fontSize:
                              Responsive.fontSize(context, 14)),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length > 5 ? 5 : tasks.length,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 100),
                    child: TaskCard(
                      task: tasks[index],
                      onToggle: (val) =>
                          _taskService.toggleTaskComplete(
                              tasks[index].id, val),
                      onDelete: () =>
                          _taskService.deleteTask(tasks[index].id),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.wp(context, 2),
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.task_alt_rounded, 'Tasks'),
              _buildNavItem(2, Icons.auto_awesome, 'AI'),
              _buildNavItem(
                  3, Icons.notifications_rounded, 'Reminders'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.wp(context, 3),
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textHint,
              size: Responsive.iconSize(context, 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: Responsive.isTablet(context) ? 12 : 10,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textHint,
                fontWeight: isSelected
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AddTaskScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOut)),
                child: child,
              );
            },
          ),
        );
      },
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'Add Task',
        style: GoogleFonts.lato(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: Responsive.fontSize(context, 14),
        ),
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
    );
  }
}