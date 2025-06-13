import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/navigation_service.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard_data.dart';
import '../utils/responsive_helper.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/top_navigation.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/analytics_grid.dart';
import 'analytics_page.dart';
import 'users_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    // Initialize services
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardService>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Consumer2<NavigationService, DashboardService>(
      builder: (context, navigationService, dashboardService, child) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          drawer: isMobile ? _buildMobileDrawer(context, navigationService, dashboardService) : null,
          bottomNavigationBar: isMobile ? const BottomNavigationWidget() : null,
          body: Row(
            children: [
              if (!isMobile)
                SidebarNavigation(
                  isCollapsed: dashboardService.state.isSidebarCollapsed,
                  onToggle: dashboardService.toggleSidebar,
                ),
              Expanded(
                child: Column(
                  children: [
                    TopNavigation(
                      onMenuPressed: isMobile
                          ? () => _scaffoldKey.currentState?.openDrawer()
                          : null,
                      onSearchChanged: _handleSearch,
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                        child: _buildCurrentPage(navigationService.currentRoute),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileDrawer(BuildContext context, NavigationService navigationService, DashboardService dashboardService) {
    final theme = Theme.of(context);
    
    return Drawer(
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Drawer Header
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Analytics Dashboard',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Welcome back!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: navigationService.navigationItems.map((item) {
                      return _buildDrawerItem(context, theme, item, navigationService);
                    }).toList(),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Divider(),
                      ListTile(
                        leading: Icon(
                          Icons.logout,
                          color: theme.colorScheme.error,
                        ),
                        title: Text(
                          'Sign Out',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          _showSignOutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    ThemeData theme,
    NavigationItem item,
    NavigationService navigationService,
  ) {
    final isSelected = item.isSelected;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected 
          ? theme.colorScheme.primary.withOpacity(0.1)
          : Colors.transparent,
      ),
      child: ListTile(
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              item.icon,
              color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            if (item.badgeCount != null && item.badgeCount! > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    item.badgeCount! > 99 ? '99+' : item.badgeCount.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onError,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          item.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isSelected 
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          navigationService.navigateTo(item.route);
          Navigator.of(context).pop(); // Close drawer
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCurrentPage(String route) {
    switch (route) {
      case '/dashboard':
        return const DashboardPageContent(key: ValueKey('/dashboard'));
      case '/analytics':
        return const AnalyticsPage(key: ValueKey('/analytics'));
      case '/users':
        return const UsersPage(key: ValueKey('/users'));
      case '/reports':
        return const ReportsPage(key: ValueKey('/reports'));
      case '/settings':
        return const SettingsPage(key: ValueKey('/settings'));
      default:
        return const DashboardPageContent(key: ValueKey('default'));
    }
  }

  void _handleSearch(String query) {
    // Handle search functionality
    if (query.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Searching for: \$query'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Signed out successfully'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _slideController.forward();
  }
}

// Extract the dashboard content to avoid conflicts
class DashboardPageContent extends StatelessWidget {
  const DashboardPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardService>(
      builder: (context, dashboardService, child) {
        final state = dashboardService.state;
        
        if (state.isLoading && state.metrics.isEmpty) {
          return _buildInitialLoadingState(Theme.of(context));
        }
        
        return _buildMainContent(context, state);
      },
    );
  }

  Widget _buildMainContent(BuildContext context, DashboardState state) {
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<DashboardService>(context, listen: false).refreshData();
      },
      child: SingleChildScrollView(
        padding: ResponsiveHelper.getContentPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageHeader(context),
            const SizedBox(height: 24),
            AnalyticsGrid(
              metrics: state.metrics,
              charts: state.charts,
              isLoading: state.isLoading,
            ),
            const SizedBox(height: 100), // Bottom padding for mobile
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.dashboard,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard Overview',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor your key metrics and performance indicators',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInitialLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading dashboard...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}