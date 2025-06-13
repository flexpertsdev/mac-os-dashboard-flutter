

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
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
      child: MaterialApp(
        title: 'Analytics Dashboard',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const MainLayout(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}