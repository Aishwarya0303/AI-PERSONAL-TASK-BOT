import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../utils/app_theme.dart';
import '../../services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final TaskService _taskService = TaskService();

  Priority _selectedPriority = Priority.medium;
  TaskCategory _selectedCategory = TaskCategory.personal;
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  bool _hasReminder = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
              ),
            ),
            child: child!,
          );
        },
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
              date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final task = TaskModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _selectedDate,
        priority: _selectedPriority,
        category: _selectedCategory,
        hasReminder: _hasReminder,
        userId: FirebaseAuth.instance.currentUser!.uid,
        createdAt: DateTime.now(),
      );

      await _taskService.addTask(task);

      if (_hasReminder) {
  final notificationTime = _selectedDate
      .subtract(const Duration(minutes: 30));
  if (notificationTime.isAfter(DateTime.now())) {
    await NotificationService().scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: 'Task Reminder 🔔',
      body: _titleController.text.trim(),
      scheduledTime: notificationTime,
    );
  }
}


      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task added successfully! ✅',
                style: GoogleFonts.lato(color: Colors.white)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add New Task',
            style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold, color: AppColors.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _buildSectionLabel('Task Title'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: TextFormField(
                controller: _titleController,
                style: GoogleFonts.lato(color: AppColors.textDark, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  prefixIcon: const Icon(Icons.edit_outlined,
                      color: AppColors.primaryLight),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Please enter a title' : null,
              ),
            ),

            const SizedBox(height: 20),

            // Description
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildSectionLabel('Description (Optional)'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 250),
              child: TextFormField(
                controller: _descController,
                maxLines: 3,
                style: GoogleFonts.lato(color: AppColors.textDark, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Add more details...',
                  prefixIcon: Icon(Icons.notes_outlined,
                      color: AppColors.primaryLight),
                  alignLabelWithHint: true,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Priority
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildSectionLabel('Priority'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 350),
              child: _buildPrioritySelector(),
            ),

            const SizedBox(height: 20),

            // Category
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildSectionLabel('Category'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 450),
              child: _buildCategorySelector(),
            ),

            const SizedBox(height: 20),

            // Due Date
            FadeInUp(
              delay: const Duration(milliseconds: 500),
              child: _buildSectionLabel('Due Date & Time'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 550),
              child: GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBrown,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEE, MMM dd yyyy • hh:mm a')
                            .format(_selectedDate),
                        style: GoogleFonts.lato(
                          color: AppColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textLight),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Reminder toggle
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBrown,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_outlined,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Reminder',
                          style: GoogleFonts.lato(
                            color: AppColors.textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Get notified before due time',
                          style: GoogleFonts.lato(
                            color: AppColors.textLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Switch(
                      value: _hasReminder,
                      onChanged: (v) => setState(() => _hasReminder = v),
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            FadeInUp(
              delay: const Duration(milliseconds: 700),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Save Task',
                        style: GoogleFonts.lato(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textMedium,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: Priority.values.map((p) {
        final isSelected = _selectedPriority == p;
        final color = p == Priority.high
            ? AppColors.priorityHigh
            : p == Priority.medium
                ? AppColors.priorityMedium
                : AppColors.priorityLow;
        final label =
            p == Priority.high ? 'High' : p == Priority.medium ? 'Medium' : 'Low';

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPriority = p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: p != Priority.low ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.2),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'cat': TaskCategory.work, 'icon': Icons.work_outline, 'label': 'Work'},
      {'cat': TaskCategory.personal, 'icon': Icons.person_outline, 'label': 'Personal'},
      {'cat': TaskCategory.health, 'icon': Icons.favorite_outline, 'label': 'Health'},
      {'cat': TaskCategory.shopping, 'icon': Icons.shopping_bag_outlined, 'label': 'Shopping'},
      {'cat': TaskCategory.other, 'icon': Icons.category_outlined, 'label': 'Other'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((c) {
        final cat = c['cat'] as TaskCategory;
        final isSelected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceBrown,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.primaryPale,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(c['icon'] as IconData,
                    size: 15,
                    color: isSelected ? Colors.white : AppColors.textMedium),
                const SizedBox(width: 6),
                Text(
                  c['label'] as String,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
