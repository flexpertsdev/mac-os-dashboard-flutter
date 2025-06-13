import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_data.dart';
import '../models/demo_models.dart';
import '../services/dashboard_service.dart';
import '../services/demo_session_service.dart';
import '../widgets/sidebar_navigation.dart';
import '../widgets/top_navigation.dart';
import '../widgets/analytics_grid.dart';
import '../widgets/executive_dashboard_header.dart';
import '../widgets/kpi_theater_card.dart';
import '../widgets/ai_insight_engine.dart';
import '../widgets/market_opportunity_visualizer.dart';
import '../widgets/revenue_model_playground.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';

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

    return Consumer<DemoSessionService>(
      builder: (context, demoService, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await Provider.of<DashboardService>(context, listen: false).refreshData();
            demoService.incrementFeatureInteraction('dashboard_overview');
          },
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          child: SingleChildScrollView(
            padding: ResponsiveHelper.getContentPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Executive Dashboard Header
                const ExecutiveDashboardHeader(),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
                
                // KPI Theater Section
                _buildKPITheaterSection(context, demoService),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
                
                // AI Insight Engine
                const AIInsightEngine(),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
                
                // Market Opportunity Visualizer
                const MarketOpportunityVisualizer(),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
                
                // Revenue Model Playground
                const RevenueModelPlayground(),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
                
                // Traditional Analytics Grid (Enhanced)
                _buildAnalyticsSection(context, state),
              ],
            ),
          ),
        );
      },
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

  Widget _buildKPITheaterSection(BuildContext context, DemoSessionService demoService) {
    final theme = Theme.of(context);
    final metrics = demoService.getScenarioMetrics();
    
    if (metrics.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
              ),
              child: Icon(
                Icons.theater_comedy,
                color: Colors.white,
                size: ResponsiveHelper.getIconSize(context, baseSize: 24),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KPI Theater',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Real-time performance metrics with immersive visualizations',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
        
        // KPI Cards Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = ResponsiveHelper.isMobile(context);
            final crossAxisCount = isMobile ? 1 : (constraints.maxWidth > 1200 ? 4 : 2);
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: isMobile ? 3.0 : 2.5,
                crossAxisSpacing: ResponsiveHelper.getCardSpacing(context),
                mainAxisSpacing: ResponsiveHelper.getCardSpacing(context),
              ),
              itemCount: metrics.take(8).length,
              itemBuilder: (context, index) {
                final metric = metrics[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 400 + (index * 150)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: KPITheaterCard(
                        metric: metric,
                        isLarge: index < 2, // First two cards are larger/featured
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, DashboardState state) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
              ),
              child: Icon(
                Icons.analytics,
                color: theme.colorScheme.tertiary,
                size: ResponsiveHelper.getIconSize(context, baseSize: 24),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advanced Analytics',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Interactive charts and deep-dive analysis tools',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
        
        // Enhanced Analytics Grid
        AnalyticsGrid(
          metrics: state.metrics,
          charts: state.charts,
          isLoading: state.isLoading,
        ),
      ],
    );
  }

  void _handleSearch(String query) {
    final demoService = context.read<DemoSessionService>();
    demoService.incrementFeatureInteraction('dashboard_overview');
    
    if (query.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.search, color: Colors.white),
              SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
              Expanded(child: Text('AI-powered search: "$query" - 127 results found')),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
          ),
        ),
      );
      
      // Add search insight
      final insight = DemoInsight(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Search Pattern Detected',
        description: 'Frequent searches for "$query" suggest this metric needs better visibility.',
        impact: 'Consider adding "$query" to your main dashboard for quick access.',
        discoveredAt: DateTime.now(),
        source: 'Search Analytics',
        confidence: 0.72,
        type: InsightType.opportunity,
      );
      
      demoService.addInsight(insight);
    }
  }
}