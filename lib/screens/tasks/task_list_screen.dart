import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: Text(
                      'My Tasks',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search
                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: Colors.white.withOpacity(0.7), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              style: GoogleFonts.lato(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search tasks...',
                                hintStyle: GoogleFonts.lato(
                                    color: Colors.white.withOpacity(0.5)),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                fillColor: Colors.transparent,
                                filled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.lato(fontWeight: FontWeight.w700),
                    unselectedLabelStyle:
                        GoogleFonts.lato(fontWeight: FontWeight.w400),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.5),
                    tabs: const [
                      Tab(text: 'All'),
                      Tab(text: 'Pending'),
                      Tab(text: 'Done'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(_taskService.getTasksStream()),
                _buildTaskList(_taskService.getPendingTasksStream()),
                _buildCompletedList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(Stream<List<TaskModel>> stream) {
    return StreamBuilder<List<TaskModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        var tasks = snapshot.data ?? [];

        if (_searchQuery.isNotEmpty) {
          tasks = tasks
              .where((t) =>
                  t.title
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  t.description
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()))
              .toList();
        }

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt,
                    size: 60, color: AppColors.primary.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'No tasks found',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              delay: Duration(milliseconds: index * 80),
              child: TaskCard(
                task: tasks[index],
                onToggle: (val) =>
                    _taskService.toggleTaskComplete(tasks[index].id, val),
                onDelete: () => _taskService.deleteTask(tasks[index].id),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedList() {
    return StreamBuilder<List<TaskModel>>(
      stream: _taskService.getTasksStream(),
      builder: (context, snapshot) {
        final tasks =
            (snapshot.data ?? []).where((t) => t.isCompleted).toList();

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 60, color: AppColors.success.withOpacity(0.4)),
                const SizedBox(height: 16),
                Text(
                  'No completed tasks yet',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              delay: Duration(milliseconds: index * 80),
              child: TaskCard(
                task: tasks[index],
                onToggle: (val) =>
                    _taskService.toggleTaskComplete(tasks[index].id, val),
                onDelete: () => _taskService.deleteTask(tasks[index].id),
              ),
            );
          },
        );
      },
    );
  }
}
