

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'utils/responsive_theme.dart';
import 'services/dashboard_service.dart';
import 'services/navigation_service.dart';
import 'services/users_service.dart';
import 'pages/main_layout.dart';

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
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          title: 'Analytics Dashboard',
          theme: ResponsiveTheme.lightTheme(context),
          darkTheme: ResponsiveTheme.darkTheme(context),
          themeMode: ThemeMode.system,
          home: const MainLayout(),
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