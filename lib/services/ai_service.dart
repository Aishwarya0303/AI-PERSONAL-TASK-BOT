import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'task_service.dart';
import '../models/task_model.dart';

class AIService {
  static const String _apiKey = 'YOUR_GROQ_API_KEY'; // Replace with your key
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  final TaskService _taskService = TaskService();
  final List<Map<String, String>> _conversationHistory = [];

  // ─── Call Groq API ──────────────────────────────────────────────────────────

  Future<String> _callGroq({
    required String systemPrompt,
    required String userMessage,
    double temperature = 0.7,
    int maxTokens = 500,
  }) async {
    try {
      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ..._conversationHistory
            .take(_conversationHistory.length > 6
                ? _conversationHistory.length - 1
                : _conversationHistory.length)
            .toList(),
        {'role': 'user', 'content': userMessage},
      ];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama3-8b-8192',
          'messages': messages,
          'temperature': temperature,
          'max_tokens': maxTokens,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']
            .toString()
            .trim();
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  // ─── Main Entry Point ───────────────────────────────────────────────────────

  Future<AIResponse> sendMessage(String message) async {
    try {
      // Add to conversation history
      _conversationHistory.add({
        'role': 'user',
        'content': message,
      });

      // Keep history to last 10 messages
      if (_conversationHistory.length > 10) {
        _conversationHistory.removeAt(0);
      }

      final lower = message.toLowerCase().trim();

      // Detect if task creation is needed
      if (_isTaskRequest(lower)) {
        return await _handleTaskCreation(message, lower);
      }

      // Handle everything else with Groq
      return await _handleGeneralChat(message);
    } catch (e) {
      return AIResponse(
        message:
            'Oops! Something went wrong. Try again? 😊',
        taskCreated: false,
        action: 'error',
      );
    }
  }

  // ─── Intent Detection ───────────────────────────────────────────────────────

  bool _isTaskRequest(String msg) {
    // Pure chat — skip task creation
    final chatOnly = [
      'hi', 'hello', 'hey', 'how are you', 'what can you do',
      'help', 'thanks', 'thank you', 'bye', 'good morning',
      'good night', 'good evening', 'who are you', 'what are you',
    ];
    if (chatOnly.any((c) => msg == c || msg == '$c!')) return false;

    // Skip task creation for general questions
    final generalQuestions = [
      'give me', 'create a', 'make a', 'generate', 'write',
      'suggest', 'what is', 'how to', 'explain', 'tell me',
      'show me', 'can you', 'timetable', 'schedule for me',
      'plan for', 'tips', 'advice', 'recommend', 'best way',
      'how do i', 'what should', 'study', 'workout', 'diet',
      'recipe', 'ideas', 'help me with',
    ];

    // If it's a general question, don't create task
    if (generalQuestions.any((q) => msg.contains(q))) {
      // BUT if it also has task keywords, create task
      final taskSpecific = [
        'add a task', 'add task', 'create task', 'remind me to',
        'set a reminder', 'schedule a task', 'new task',
      ];
      return taskSpecific.any((t) => msg.contains(t));
    }

    // Task trigger patterns
    final taskPatterns = [
      RegExp(r'\badd\s+a?\s*task\b'),
      RegExp(r'\bcreate\s+a?\s*task\b'),
      RegExp(r'\bremind\s+me\s+to\b'),
      RegExp(r'\bset\s+a?\s*reminder\b'),
      RegExp(r'\bschedule\s+a?\s*task\b'),
      RegExp(r'\bnew\s+task\b'),
      RegExp(r'\btask\s+to\b'),
      RegExp(r'\bat\s+\d+(am|pm)\b'),
      RegExp(r'\btomorrow\s+at\b'),
      RegExp(r'\btoday\s+at\b'),
      RegExp(r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\s+at\b'),
    ];

    return taskPatterns.any((p) => p.hasMatch(msg));
  }

  // ─── Task Creation ──────────────────────────────────────────────────────────

  Future<AIResponse> _handleTaskCreation(
      String original, String lower) async {
    try {
      final now = DateTime.now();

      // Extract title
      final title = await _extractTitle(original);

      // Extract date/time
      final dueDate = _extractDateTime(lower, now);

      // Extract priority & category
      final priority = _extractPriority(lower);
      final category = _extractCategory(lower);

      // Save to Firestore
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final task = TaskModel(
        id: '',
        title: title,
        description: '',
        dueDate: dueDate,
        priority: priority,
        category: category,
        hasReminder: true,
        userId: userId,
        createdAt: DateTime.now(),
      );

      await _taskService.addTask(task);

      final day =
          '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}';
      final time =
          '${dueDate.hour.toString().padLeft(2, '0')}:${dueDate.minute.toString().padLeft(2, '0')}';

      final reply =
          'Done! ✅ Task created!\n\n📋 $title\n📅 $day at $time\n⚡ ${_priorityLabel(priority)}\n📁 ${_categoryLabel(category)}\n\nAnything else I can help with? 😊';

      _conversationHistory
          .add({'role': 'assistant', 'content': reply});

      return AIResponse(
        message: reply,
        taskCreated: true,
        action: 'create_task',
      );
    } catch (e) {
      return AIResponse(
        message:
            'Hmm, I had trouble creating that task. Try saying "Add task to call mom tomorrow at 5pm" 😊',
        taskCreated: false,
        action: 'error',
      );
    }
  }

  // ─── General Chat with Groq ─────────────────────────────────────────────────

  Future<AIResponse> _handleGeneralChat(String message) async {
    const systemPrompt = '''
You are Aria, a friendly and smart AI assistant inside the AI Task Bot app.
You help users with tasks, planning, timetables, advice, and general questions.

Your personality:
- Super friendly, casual and warm 😊
- Use emojis naturally but not too many
- Give helpful, practical responses
- Keep responses concise but complete
- Always end with an offer to help more or create a task

You can help with:
- Creating study timetables and schedules
- Workout and fitness plans
- Daily routines and habits
- Productivity tips
- General advice and questions
- Recipes and meal plans
- Travel planning
- And much more!

For task creation, tell users to say "Add task to [what] at [time]"
Always be encouraging and positive!
''';

    final reply = await _callGroq(
      systemPrompt: systemPrompt,
      userMessage: message,
      temperature: 0.8,
      maxTokens: 600,
    );

    final finalReply = reply.isNotEmpty
        ? reply
        : _fallbackResponse(message.toLowerCase());

    _conversationHistory
        .add({'role': 'assistant', 'content': finalReply});

    return AIResponse(
      message: finalReply,
      taskCreated: false,
      action: 'chat',
    );
  }

  // ─── Fallback Responses ────────────────────────────────────────────────────

  String _fallbackResponse(String msg) {
    if (msg.contains('study') || msg.contains('timetable')) {
      return 'Here\'s a simple study timetable! 📚\n\n'
          '🌅 6:00 AM - Wake up & freshen up\n'
          '📖 7:00 AM - Study Session 1 (2 hrs)\n'
          '🍳 9:00 AM - Breakfast break\n'
          '📖 10:00 AM - Study Session 2 (2 hrs)\n'
          '🍱 12:00 PM - Lunch break\n'
          '😴 1:00 PM - Power nap (30 min)\n'
          '📖 2:00 PM - Study Session 3 (2 hrs)\n'
          '🏃 4:00 PM - Exercise/break\n'
          '📖 5:00 PM - Study Session 4 (2 hrs)\n'
          '🍽️ 7:00 PM - Dinner\n'
          '📖 8:00 PM - Revision (1 hr)\n'
          '😴 10:00 PM - Sleep!\n\n'
          'Want me to add study sessions as tasks? 😊';
    }

    if (msg.contains('workout') || msg.contains('fitness')) {
      return 'Here\'s a beginner workout plan! 💪\n\n'
          '🏃 Monday - Cardio (30 min run)\n'
          '💪 Tuesday - Upper body\n'
          '🧘 Wednesday - Yoga/Rest\n'
          '🦵 Thursday - Lower body\n'
          '🏃 Friday - Cardio (30 min)\n'
          '💪 Saturday - Full body\n'
          '😴 Sunday - Rest\n\n'
          'Want me to add these as weekly reminders? 😊';
    }

    if (msg.contains('hi') || msg.contains('hello') || msg.contains('hey')) {
      return 'Hey there! 👋 I\'m Aria, your AI assistant!\n\n'
          'I can help you with:\n'
          '📋 Creating tasks & reminders\n'
          '📚 Study timetables\n'
          '💪 Workout plans\n'
          '💡 Tips & advice\n'
          '🗓️ Daily planning\n\n'
          'What can I help you with today? 😊';
    }

    return 'I\'m here to help! 😊 You can ask me anything — '
        'study plans, workout routines, daily schedules, or just say '
        '"Add task to [something] at [time]" to create a task!';
  }

  // ─── Title Extraction ──────────────────────────────────────────────────────

  Future<String> _extractTitle(String message) async {
    try {
      final prompt =
          'Extract a short task title (2-5 words) from: "$message"\n'
          'Reply with ONLY the title. No punctuation.\n'
          'Examples:\n'
          '"remind me to call mom tomorrow" → Call mom\n'
          '"add task to buy groceries today" → Buy groceries\n'
          '"meeting with team friday at 3pm" → Meeting with team\n'
          'Title:';

      final response = await _callGroq(
        systemPrompt: 'You extract short task titles.',
        userMessage: prompt,
        temperature: 0.1,
        maxTokens: 20,
      );

      String title = response
          .replaceAll('"', '')
          .replaceAll("'", '')
          .replaceAll('\n', '')
          .trim();

      if (title.isEmpty || title.length > 60) {
        return _capitalize(_fallbackTitle(message));
      }
      return _capitalize(title);
    } catch (e) {
      return _capitalize(_fallbackTitle(message));
    }
  }

  // ─── DateTime Extraction ───────────────────────────────────────────────────

  DateTime _extractDateTime(String msg, DateTime now) {
    DateTime base = now.add(const Duration(days: 1));
    int hour = 9;
    int minute = 0;

    if (msg.contains('today')) {
      base = now;
    } else if (msg.contains('tomorrow')) {
      base = now.add(const Duration(days: 1));
    } else if (msg.contains('monday')) {
      base = _nextWeekday(now, DateTime.monday);
    } else if (msg.contains('tuesday')) {
      base = _nextWeekday(now, DateTime.tuesday);
    } else if (msg.contains('wednesday')) {
      base = _nextWeekday(now, DateTime.wednesday);
    } else if (msg.contains('thursday')) {
      base = _nextWeekday(now, DateTime.thursday);
    } else if (msg.contains('friday')) {
      base = _nextWeekday(now, DateTime.friday);
    } else if (msg.contains('saturday')) {
      base = _nextWeekday(now, DateTime.saturday);
    } else if (msg.contains('sunday')) {
      base = _nextWeekday(now, DateTime.sunday);
    }

    if (msg.contains('morning')) {
      hour = 9;
      minute = 0;
    } else if (msg.contains('afternoon')) {
      hour = 14;
      minute = 0;
    } else if (msg.contains('evening')) {
      hour = 18;
      minute = 0;
    } else if (msg.contains('night')) {
      hour = 20;
      minute = 0;
    }

    final amPm = RegExp(
        r'(\d{1,2})(?::(\d{2}))?\s*(am|pm)',
        caseSensitive: false);
    final amPmMatch = amPm.firstMatch(msg);
    if (amPmMatch != null) {
      hour = int.parse(amPmMatch.group(1)!);
      minute = int.parse(amPmMatch.group(2) ?? '0');
      final period = amPmMatch.group(3)!.toLowerCase();
      if (period == 'pm' && hour != 12) hour += 12;
      if (period == 'am' && hour == 12) hour = 0;
    } else {
      final atTime = RegExp(r'\bat\s+(\d{1,2})(?::(\d{2}))?');
      final atMatch = atTime.firstMatch(msg);
      if (atMatch != null) {
        hour = int.parse(atMatch.group(1)!);
        minute = int.parse(atMatch.group(2) ?? '0');
        if (hour >= 1 && hour <= 7) hour += 12;
      }
    }

    return DateTime(base.year, base.month, base.day, hour, minute);
  }

  // ─── Priority & Category ───────────────────────────────────────────────────

  Priority _extractPriority(String msg) {
    if (RegExp(r'\b(urgent|important|high priority|asap|critical)\b')
        .hasMatch(msg)) {
      return Priority.high;
    }
    if (RegExp(r'\b(low priority|whenever|not urgent|someday)\b')
        .hasMatch(msg)) {
      return Priority.low;
    }
    return Priority.medium;
  }

  TaskCategory _extractCategory(String msg) {
    if (RegExp(
            r'\b(work|meeting|office|report|project|client|team|deadline)\b')
        .hasMatch(msg)) {
      return TaskCategory.work;
    }
    if (RegExp(
            r'\b(doctor|gym|exercise|workout|health|medicine|hospital|yoga)\b')
        .hasMatch(msg)) {
      return TaskCategory.health;
    }
    if (RegExp(
            r'\b(buy|shop|purchase|grocery|groceries|store|market)\b')
        .hasMatch(msg)) {
      return TaskCategory.shopping;
    }
    return TaskCategory.personal;
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _fallbackTitle(String message) {
    String title = message
        .replaceAll(
            RegExp(
                r'\b(add|a|task|to|the|an|remind me|set|create|new|make)\b',
                caseSensitive: false),
            '')
        .replaceAll(
            RegExp(
                r'\b(today|tomorrow|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b',
                caseSensitive: false),
            '')
        .replaceAll(
            RegExp(r'\b(at|on|by|for|in|this)\b',
                caseSensitive: false),
            '')
        .replaceAll(
            RegExp(r'\d+\s*(am|pm)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (title.isEmpty) title = message;
    if (title.length > 50) title = title.substring(0, 50);
    return title;
  }

  DateTime _nextWeekday(DateTime from, int weekday) {
    int days = weekday - from.weekday;
    if (days <= 0) days += 7;
    return from.add(Duration(days: days));
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _priorityLabel(Priority p) {
    if (p == Priority.high) return 'High Priority';
    if (p == Priority.low) return 'Low Priority';
    return 'Medium Priority';
  }

  String _categoryLabel(TaskCategory c) {
    if (c == TaskCategory.work) return 'Work';
    if (c == TaskCategory.health) return 'Health';
    if (c == TaskCategory.shopping) return 'Shopping';
    return 'Personal';
  }
}

class AIResponse {
  final String message;
  final bool taskCreated;
  final String action;

  AIResponse({
    required this.message,
    required this.taskCreated,
    required this.action,
  });
}