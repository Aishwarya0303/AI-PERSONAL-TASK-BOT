import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'utils/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar color
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF6B3A2A),
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase and Notifications in parallel
  await Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
  ]);

  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'AI Task Bot',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme,
  // Add this:
  builder: (context, child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(1.0), // Prevent system font scaling breaking UI
      ),
      child: child!,
    );
  },
  home: const SplashScreen(),
);
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation =
        Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(
          parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            user != null ? const HomeScreen() : const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6B3A2A),
              Color(0xFF8B5E3C),
              Color(0xFFA0785A),
              Color(0xFFE8D5C4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: size.width * 0.28,
                          height: size.width * 0.28,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(
                                alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white
                                  .withValues(alpha: 0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: 0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            size: size.width * 0.12,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),

                      // App Name
                      Text(
                        'AI Task Bot',
                        style: TextStyle(
                          fontSize: size.width * 0.09,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          fontFamily: 'serif',
                        ),
                      ),

                      SizedBox(height: size.height * 0.01),

                      Text(
                        'Your intelligent daily planner',
                        style: TextStyle(
                          fontSize: size.width * 0.038,
                          color:
                              Colors.white.withValues(alpha: 0.8),
                        ),
                      ),

                      SizedBox(height: size.height * 0.08),

                      // Loading
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          color:
                              Colors.white.withValues(alpha: 0.8),
                          strokeWidth: 2.5,
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          color:
                              Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}