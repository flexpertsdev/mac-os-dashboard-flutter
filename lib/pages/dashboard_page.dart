import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/top_navigation.dart';
import '../widgets/analytics_grid.dart';
import '../utils/responsive_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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

    // Initialize dashboard data
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
    
    return Consumer<DashboardService>(
      builder: (context, dashboardService, child) {
        final state = dashboardService.state;
        
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          drawer: isMobile ? _buildMobileDrawer(context, state) : null,
          body: Row(
            children: [
              if (!isMobile)
                SidebarNavigation(
                  isCollapsed: state.isSidebarCollapsed,
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
                        child: _buildMainContent(context, state),
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

  Widget _buildMobileDrawer(BuildContext context, DashboardState state) {
    return SlideTransition(
      position: _slideAnimation,
      child: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: SidebarNavigation(
          isCollapsed: false,
          onToggle: () {
            Navigator.of(context).pop();
            Provider.of<DashboardService>(context, listen: false).toggleSidebar();
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, DashboardState state) {
    final theme = Theme.of(context);
    
    if (state.isLoading && state.metrics.isEmpty) {
      return _buildInitialLoadingState(theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<DashboardService>(context, listen: false).refreshData();
      },
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      child: AnalyticsGrid(
        metrics: state.metrics,
        charts: state.charts,
        isLoading: state.isLoading,
      ),
    );
  }

  Widget _buildInitialLoadingState(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Icon(
                      Icons.analytics,
                      color: theme.colorScheme.primary,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Dashboard',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fetching your analytics data...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1500),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return LinearProgressIndicator(
                    value: value,
                    backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearch(String query) {
    // Implement search functionality
    if (query.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Searching for: $query'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}