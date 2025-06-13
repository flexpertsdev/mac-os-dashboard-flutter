

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'utils/responsive_theme.dart';
import 'services/dashboard_service.dart';
import 'services/navigation_service.dart';
import 'services/users_service.dart';
import 'services/demo_session_service.dart';
import 'pages/main_layout.dart';
import 'pages/onboarding_page.dart';
import 'widgets/cinematic_intro.dart';

void main() {
  
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationService()),
        ChangeNotifierProvider(create: (_) => DashboardService()),
        ChangeNotifierProvider(create: (_) => UsersService()),
        ChangeNotifierProvider(create: (_) => DemoSessionService()),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          title: 'Analytics Dashboard',
          theme: ResponsiveTheme.lightTheme(context),
          darkTheme: ResponsiveTheme.darkTheme(context),
          themeMode: ThemeMode.system,
          home: const DemoApp(),
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            // Rebuild theme when MediaQuery changes (orientation, font scale, etc.)
            return MediaQuery(
              data: MediaQuery.of(context),
              child: Theme(
                data: Theme.of(context).brightness == Brightness.light
                    ? ResponsiveTheme.lightTheme(context)
                    : ResponsiveTheme.darkTheme(context),
                child: child!,
              ),
            );
          },
        ),
      ),
    );
  }
}

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  bool _showIntro = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeDemoSession();
  }

  Future<void> _initializeDemoSession() async {
    final demoService = context.read<DemoSessionService>();
    await demoService.initializeSession();
    
    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  void _completeIntro() {
    setState(() {
      _showIntro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while initializing
    if (!_initialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
          ),
        ),
      );
    }

    // Show cinematic intro first
    if (_showIntro) {
      return CinematicIntro(onComplete: _completeIntro);
    }

    return Consumer<DemoSessionService>(
      builder: (context, demoService, child) {
        // Show onboarding if no session exists or onboarding not complete
        if (!demoService.isOnboardingComplete || demoService.currentSession == null) {
          return const OnboardingPage();
        }
        
        // Show main app if session exists and onboarding is complete
        return const MainLayout();
      },
    );
  }
}