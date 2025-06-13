import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';

class NavigationService extends ChangeNotifier {
  String _currentRoute = '/dashboard';
  final List<NavigationItem> _navigationItems = [
    const NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
    ),
    const NavigationItem(
      label: 'Analytics',
      icon: Icons.analytics,
      route: '/analytics',
    ),
    const NavigationItem(
      label: 'Users',
      icon: Icons.people_outline,
      route: '/users',
      badgeCount: 3,
    ),
    const NavigationItem(
      label: 'Reports',
      icon: Icons.assessment,
      route: '/reports',
    ),
    const NavigationItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      route: '/settings',
    ),
  ];

  String get currentRoute => _currentRoute;
  
  List<NavigationItem> get navigationItems => _navigationItems.map((item) {
    return item.copyWith(isSelected: item.route == _currentRoute);
  }).toList();

  NavigationItem get currentNavItem => 
    _navigationItems.firstWhere((item) => item.route == _currentRoute);

  void navigateTo(String route) {
    if (_currentRoute != route) {
      _currentRoute = route;
      notifyListeners();
    }
  }

  void updateBadgeCount(String route, int? count) {
    final index = _navigationItems.indexWhere((item) => item.route == route);
    if (index != -1) {
      _navigationItems[index] = _navigationItems[index].copyWith(badgeCount: count);
      notifyListeners();
    }
  }

  String getPageTitle(String route) {
    switch (route) {
      case '/dashboard':
        return 'Dashboard Overview';
      case '/analytics':
        return 'Advanced Analytics';
      case '/users':
        return 'User Management';
      case '/reports':
        return 'Reports & Insights';
      case '/settings':
        return 'Settings & Preferences';
      default:
        return 'Dashboard';
    }
  }

  IconData getPageIcon(String route) {
    switch (route) {
      case '/dashboard':
        return Icons.dashboard;
      case '/analytics':
        return Icons.analytics;
      case '/users':
        return Icons.people_outline;
      case '/reports':
        return Icons.assessment;
      case '/settings':
        return Icons.settings_outlined;
      default:
        return Icons.dashboard;
    }
  }
}