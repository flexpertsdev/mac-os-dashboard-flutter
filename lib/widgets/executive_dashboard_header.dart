import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/demo_models.dart';
import '../services/demo_session_service.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';

class ExecutiveDashboardHeader extends StatefulWidget {
  const ExecutiveDashboardHeader({super.key});

  @override
  State<ExecutiveDashboardHeader> createState() => _ExecutiveDashboardHeaderState();
}

class _ExecutiveDashboardHeaderState extends State<ExecutiveDashboardHeader>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _startAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<DemoSessionService>(
      builder: (context, demoService, child) {
        final session = demoService.currentSession;
        if (session == null) return const SizedBox();
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              padding: ResponsiveHelper.getContentPadding(context),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    session.selectedRole.color.withOpacity(0.1),
                    session.selectedScenario.color.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(theme, session),
                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
                  _buildQuickStats(theme, demoService),
                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                  _buildActionButtons(theme, session),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, DemoSession session) {
    final timeOfDay = DateTime.now().hour;
    String greeting;
    
    if (timeOfDay < 12) {
      greeting = 'Good Morning';
    } else if (timeOfDay < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${session.selectedRole.title.split(' ')[0]}!',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
              Text(
                'Welcome to your ${session.selectedScenario.title} analytics dashboard',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                session.selectedRole.color,
                session.selectedScenario.color,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: session.selectedRole.color.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(
            session.selectedScenario.icon,
            color: Colors.white,
            size: ResponsiveHelper.getIconSize(context, baseSize: 32),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(ThemeData theme, DemoSessionService demoService) {
    final completionPercentage = demoService.completionPercentage;
    final insightCount = demoService.insights.length;
    final featuresExplored = demoService.features.where((f) => f.interactionCount > 0).length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            theme,
            'Demo Progress',
            '${(completionPercentage * 100).toInt()}%',
            Icons.trending_up,
            const Color(0xFF34C759),
          ),
        ),
        
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        Expanded(
          child: _buildStatItem(
            theme,
            'Insights Found',
            insightCount.toString(),
            Icons.lightbulb,
            const Color(0xFFFF9500),
          ),
        ),
        
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        Expanded(
          child: _buildStatItem(
            theme,
            'Features Explored',
            featuresExplored.toString(),
            Icons.explore,
            const Color(0xFF007AFF),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getIconSize(context, baseSize: 24),
          ),
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
          Text(
            value,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
          Text(
            label,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, DemoSession session) {
    return Wrap(
      spacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
      runSpacing: ResponsiveHelper.getAccessibleSpacing(context, 8),
      children: [
        _buildActionChip(
          theme,
          'Generate Report',
          Icons.description,
          session.selectedRole.color,
          () => _generateReport(),
        ),
        _buildActionChip(
          theme,
          'AI Insights',
          Icons.psychology,
          const Color(0xFFFF9500),
          () => _showAIInsights(),
        ),
        _buildActionChip(
          theme,
          'Live Data',
          Icons.stream,
          const Color(0xFF34C759),
          () => _toggleLiveData(),
        ),
        _buildActionChip(
          theme,
          'Share Dashboard',
          Icons.share,
          const Color(0xFFAF52DE),
          () => _shareDashboard(),
        ),
      ],
    );
  }

  Widget _buildActionChip(ThemeData theme, String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
            vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: ResponsiveHelper.getIconSize(context, baseSize: 16),
              ),
              SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
              Text(
                label,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateReport() {
    final demoService = context.read<DemoSessionService>();
    demoService.incrementFeatureInteraction('dashboard_overview');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.description, color: Colors.white),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            const Text('Generating comprehensive business report...'),
          ],
        ),
        backgroundColor: const Color(0xFF007AFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
        ),
      ),
    );
  }

  void _showAIInsights() {
    final demoService = context.read<DemoSessionService>();
    demoService.incrementFeatureInteraction('ai_insights');
    
    // Add a demo insight
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Revenue Opportunity Detected',
      description: 'AI analysis suggests a 15% revenue increase potential through customer retention optimization.',
      impact: 'High impact - potential \$250K additional revenue',
      discoveredAt: DateTime.now(),
      source: 'AI Analytics Engine',
      confidence: 0.87,
      type: InsightType.opportunity,
    );
    
    demoService.addInsight(insight);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.white),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            const Expanded(child: Text('New AI insight discovered! Check your insights panel.')),
          ],
        ),
        backgroundColor: const Color(0xFFFF9500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
        ),
      ),
    );
  }

  void _toggleLiveData() {
    final demoService = context.read<DemoSessionService>();
    demoService.incrementFeatureInteraction('real_time_monitoring');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stream, color: Colors.white),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            const Text('Live data streaming enabled - Real-time updates active'),
          ],
        ),
        backgroundColor: const Color(0xFF34C759),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
        ),
      ),
    );
  }

  void _shareDashboard() {
    final demoService = context.read<DemoSessionService>();
    demoService.incrementFeatureInteraction('collaborative_workspace');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.share, color: Color(0xFFAF52DE)),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            const Text('Share Dashboard'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this live dashboard with your team members for collaborative analysis.'),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            Container(
              padding: ResponsiveHelper.getContentPadding(context),
              decoration: BoxDecoration(
                color: const Color(0xFFAF52DE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://dreamflow.ai/dashboard/shared/demo-123',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAF52DE),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dashboard link copied to clipboard!')),
                      );
                    },
                    icon: const Icon(Icons.copy, color: Color(0xFFAF52DE)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dashboard shared successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFAF52DE)),
            child: const Text('Share', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}