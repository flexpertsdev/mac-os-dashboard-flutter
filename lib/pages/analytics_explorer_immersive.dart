import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';
import '../services/demo_session_service.dart';
import '../models/demo_models.dart';

class AnalyticsExplorerImmersive extends StatefulWidget {
  final Map<String, dynamic> metricData;
  
  const AnalyticsExplorerImmersive({
    super.key,
    required this.metricData,
  });

  @override
  State<AnalyticsExplorerImmersive> createState() => _AnalyticsExplorerImmersiveState();
}

class _AnalyticsExplorerImmersiveState extends State<AnalyticsExplorerImmersive>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _dataController;
  late AnimationController _interactionController;
  late AnimationController _drillController;
  
  late Animation<double> _heroAnimation;
  late Animation<double> _dataStagger;
  late Animation<double> _interactionPulse;
  late Animation<double> _drillDepth;
  
  // Explorer state
  String _selectedTimeframe = '30d';
  String _selectedDimension = 'overview';
  String _selectedComparison = 'previous_period';
  bool _showAdvancedAnalytics = false;
  bool _isZoomedMode = false;
  
  // Data exploration
  int _currentDepth = 0;
  final List<String> _breadcrumb = ['Overview'];
  final Map<String, dynamic> _drillData = {};
  
  // Time ranges
  final List<TimeRange> _timeRanges = [
    TimeRange('7d', '7 Days', const Color(0xFF3B82F6)),
    TimeRange('30d', '30 Days', const Color(0xFF10B981)),
    TimeRange('90d', '90 Days', const Color(0xFF8B5CF6)),
    TimeRange('1y', '1 Year', const Color(0xFFF59E0B)),
    TimeRange('custom', 'Custom', const Color(0xFFEF4444)),
  ];
  
  // Analysis dimensions
  final List<AnalysisDimension> _dimensions = [
    AnalysisDimension('overview', 'Overview', Icons.dashboard, const Color(0xFF3B82F6)),
    AnalysisDimension('trends', 'Trends', Icons.trending_up, const Color(0xFF10B981)),
    AnalysisDimension('segments', 'Segments', Icons.pie_chart, const Color(0xFF8B5CF6)),
    AnalysisDimension('cohorts', 'Cohorts', Icons.groups, const Color(0xFFF59E0B)),
    AnalysisDimension('funnels', 'Funnels', Icons.filter_alt, const Color(0xFFEF4444)),
    AnalysisDimension('attribution', 'Attribution', Icons.account_tree, const Color(0xFF06B6D4)),
  ];

  @override
  void initState() {
    super.initState();
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _dataController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    
    _interactionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _drillController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    
    _dataStagger = CurvedAnimation(
      parent: _dataController,
      curve: Curves.easeOutBack,
    );
    
    _interactionPulse = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _interactionController,
      curve: Curves.easeInOut,
    ));
    
    _drillDepth = CurvedAnimation(
      parent: _drillController,
      curve: Curves.easeOutCubic,
    );
    
    _generateDrillData();
    _startAnimations();
  }

  void _generateDrillData() {
    final random = math.Random();
    _drillData.addAll({
      'overview': _generateOverviewData(random),
      'trends': _generateTrendsData(random),
      'segments': _generateSegmentsData(random),
      'cohorts': _generateCohortsData(random),
      'funnels': _generateFunnelsData(random),
      'attribution': _generateAttributionData(random),
    });
  }

  Map<String, dynamic> _generateOverviewData(math.Random random) {
    return {
      'primaryMetric': {
        'value': 2.45 + random.nextDouble() * 1.5,
        'change': (random.nextDouble() - 0.3) * 50,
        'trend': 'up',
      },
      'secondaryMetrics': List.generate(5, (i) => {
        'name': ['Revenue', 'Users', 'Conversion', 'Retention', 'Growth'][i],
        'value': 100 + random.nextDouble() * 500,
        'change': (random.nextDouble() - 0.5) * 40,
        'icon': [Icons.attach_money, Icons.people, Icons.trending_up, Icons.favorite, Icons.rocket_launch][i],
        'color': [const Color(0xFF10B981), const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFFF59E0B), const Color(0xFFEF4444)][i],
      }),
      'distributions': List.generate(4, (i) => {
        'category': ['Mobile', 'Desktop', 'Tablet', 'Other'][i],
        'value': 20 + random.nextDouble() * 60,
        'color': [const Color(0xFF3B82F6), const Color(0xFF10B981), const Color(0xFF8B5CF6), const Color(0xFFF59E0B)][i],
      }),
    };
  }

  Map<String, dynamic> _generateTrendsData(math.Random random) {
    return {
      'timeSeries': List.generate(30, (i) => {
        'date': DateTime.now().subtract(Duration(days: 29 - i)),
        'value': 100 + random.nextDouble() * 200 + math.sin(i * 0.2) * 50,
        'predicted': i > 25 ? 100 + random.nextDouble() * 250 : null,
      }),
      'seasonality': {
        'pattern': 'weekly',
        'strength': 0.65 + random.nextDouble() * 0.3,
        'peak_day': 'friday',
      },
      'anomalies': List.generate(3, (i) => {
        'date': DateTime.now().subtract(Duration(days: random.nextInt(25) + 2)),
        'severity': random.nextDouble(),
        'type': ['spike', 'drop', 'outlier'][i],
      }),
    };
  }

  Map<String, dynamic> _generateSegmentsData(math.Random random) {
    return {
      'userSegments': List.generate(6, (i) => {
        'name': ['Power Users', 'Casual Users', 'New Users', 'Churned Users', 'Enterprise', 'SMB'][i],
        'size': random.nextInt(5000) + 500,
        'value': random.nextDouble() * 1000 + 100,
        'growth': (random.nextDouble() - 0.4) * 30,
        'color': [
          const Color(0xFF10B981), const Color(0xFF3B82F6), const Color(0xFF8B5CF6), 
          const Color(0xFFEF4444), const Color(0xFFF59E0B), const Color(0xFF06B6D4)
        ][i],
      }),
      'behavioral': {
        'engagement_score': random.nextDouble() * 100,
        'retention_rate': 60 + random.nextDouble() * 35,
        'lifetime_value': 150 + random.nextDouble() * 500,
      },
    };
  }

  Map<String, dynamic> _generateCohortsData(math.Random random) {
    return {
      'cohortAnalysis': List.generate(12, (monthAgo) => {
        'cohort': DateTime.now().subtract(Duration(days: monthAgo * 30)),
        'size': 1000 + random.nextInt(2000),
        'retention': List.generate(12 - monthAgo, (week) => 
          math.max(0.1, 1.0 - (week * 0.15) - random.nextDouble() * 0.1)
        ),
      }),
      'insights': [
        'Month 3 shows strongest retention patterns',
        'Holiday cohorts demonstrate 25% higher LTV',
        'Mobile-first cohorts retain 18% better',
      ],
    };
  }

  Map<String, dynamic> _generateFunnelsData(math.Random random) {
    return {
      'conversionFunnel': [
        {'stage': 'Awareness', 'users': 10000, 'rate': 1.0, 'color': const Color(0xFF3B82F6)},
        {'stage': 'Interest', 'users': 7500, 'rate': 0.75, 'color': const Color(0xFF10B981)},
        {'stage': 'Consideration', 'users': 4200, 'rate': 0.56, 'color': const Color(0xFF8B5CF6)},
        {'stage': 'Intent', 'users': 2100, 'rate': 0.50, 'color': const Color(0xFFF59E0B)},
        {'stage': 'Purchase', 'users': 1260, 'rate': 0.60, 'color': const Color(0xFFEF4444)},
      ],
      'dropoffAnalysis': {
        'biggest_dropoff': 'Interest → Consideration',
        'improvement_potential': '23% increase possible',
        'recommended_actions': [
          'Optimize consideration stage messaging',
          'Add social proof elements',
          'Implement retargeting campaigns',
        ],
      },
    };
  }

  Map<String, dynamic> _generateAttributionData(math.Random random) {
    return {
      'channels': List.generate(8, (i) => {
        'name': ['Organic Search', 'Paid Search', 'Social Media', 'Email', 'Direct', 'Referral', 'Display', 'Affiliate'][i],
        'firstTouch': random.nextDouble() * 100,
        'lastTouch': random.nextDouble() * 100,
        'assisted': random.nextDouble() * 100,
        'color': [
          const Color(0xFF10B981), const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFFF59E0B),
          const Color(0xFFEF4444), const Color(0xFF06B6D4), const Color(0xFF84CC16), const Color(0xFFF97316)
        ][i],
      }),
      'touchpointAnalysis': {
        'averageTouch': 3.4 + random.nextDouble() * 2,
        'maxTouch': 12 + random.nextInt(8),
        'conversionWindow': '14 days average',
      },
    };
  }

  void _startAnimations() async {
    _heroController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _dataController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _dataController.dispose();
    _interactionController.dispose();
    _drillController.dispose();
    super.dispose();
  }
  
  void _selectDimension(String dimension) {
    setState(() {
      _selectedDimension = dimension;
      _currentDepth = 0;
      _breadcrumb.clear();
      _breadcrumb.add(_dimensions.firstWhere((d) => d.id == dimension).name);
    });
    
    _drillController.forward(from: 0);
    HapticFeedback.mediumImpact();
    
    final demoService = context.read<DemoSessionService>();
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Analytics Dimension Explored',
      description: 'Deep-dive analysis into ${_dimensions.firstWhere((d) => d.id == dimension).name} metrics.',
      impact: 'Discovered patterns and insights for data-driven decision making.',
      discoveredAt: DateTime.now(),
      source: 'Analytics Explorer',
      confidence: 0.9,
      type: InsightType.discovery,
    );
    
    demoService.addInsight(insight);
    demoService.incrementFeatureInteraction('analytics_exploration');
  }
  
  void _drillDown(String category) {
    setState(() {
      _currentDepth++;
      _breadcrumb.add(category);
    });
    
    _drillController.forward(from: 0);
    HapticFeedback.lightImpact();
  }
  
  void _breadcrumbNavigate(int index) {
    setState(() {
      _currentDepth = index;
      _breadcrumb.removeRange(index + 1, _breadcrumb.length);
    });
    
    _drillController.forward(from: 0);
    HapticFeedback.lightImpact();
  }
  
  void _toggleZoom() {
    setState(() {
      _isZoomedMode = !_isZoomedMode;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: AnimatedBuilder(
        animation: Listenable.merge([_heroAnimation, _dataStagger, _interactionPulse, _drillDepth]),
        builder: (context, child) {
          return SafeArea(
            child: Column(
              children: [
                _buildAnalyticsHeader(theme),
                _buildDimensionSelector(theme),
                if (_isZoomedMode)
                  Expanded(child: _buildZoomedView(theme))
                else
                  Expanded(child: _buildMainAnalytics(theme)),
                _buildBottomControls(theme),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildAnalyticsHeader(ThemeData theme) {
    return Transform.translate(
      offset: Offset(0, (1 - _heroAnimation.value) * -100),
      child: Container(
        padding: ResponsiveHelper.getContentPadding(context),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E40AF).withOpacity(0.9),
              const Color(0xFF3B82F6).withOpacity(0.7),
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top row
            Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                    ),
                  ),
                ),
                
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.metricData['title']?.toString() ?? 'Analytics Explorer',
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Deep-dive analytics and data exploration',
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Header actions
                Row(
                  children: [
                    _buildHeaderAction(Icons.zoom_in, 'Zoom', _toggleZoom),
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                    _buildHeaderAction(Icons.settings, 'Settings', () {}),
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                    _buildHeaderAction(Icons.share, 'Share', () {}),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            
            // Breadcrumb
            if (_breadcrumb.length > 1)
              Row(
                children: [
                  Icon(
                    Icons.navigation,
                    color: const Color(0xFF3B82F6),
                    size: ResponsiveHelper.getIconSize(context, baseSize: 16),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _breadcrumb.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isLast = index == _breadcrumb.length - 1;
                          
                          return Row(
                            children: [
                              GestureDetector(
                                onTap: () => _breadcrumbNavigate(index),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
                                    vertical: ResponsiveHelper.getResponsiveHeight(context, 6),
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isLast
                                        ? const LinearGradient(
                                            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                                          )
                                        : null,
                                    color: isLast ? null : Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
                                  ),
                                  child: Text(
                                    item,
                                    style: ResponsiveTheme.responsiveTextStyle(
                                      context,
                                      baseFontSize: 12,
                                      fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              if (!isLast) ...[
                                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white.withOpacity(0.5),
                                  size: ResponsiveHelper.getIconSize(context, baseSize: 16),
                                ),
                                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                              ],
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeaderAction(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: ResponsiveHelper.getIconSize(context, baseSize: 20),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDimensionSelector(ThemeData theme) {
    return Transform.translate(
      offset: Offset((1 - _dataStagger.value) * 300, 0),
      child: Container(
        height: ResponsiveHelper.getResponsiveHeight(context, 100),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: ResponsiveHelper.getContentPadding(context),
          itemCount: _dimensions.length,
          itemBuilder: (context, index) {
            final dimension = _dimensions[index];
            final isSelected = _selectedDimension == dimension.id;
            
            return GestureDetector(
              onTap: () => _selectDimension(dimension.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  right: ResponsiveHelper.getAccessibleSpacing(context, 12),
                ),
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [dimension.color, dimension.color.withOpacity(0.8)],
                        )
                      : null,
                  color: isSelected ? null : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: dimension.color.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      dimension.icon,
                      color: isSelected ? Colors.white : dimension.color,
                      size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                    ),
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                    Text(
                      dimension.name,
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildMainAnalytics(ThemeData theme) {
    return Transform.scale(
      scale: _dataStagger.value,
      child: Opacity(
        opacity: _dataStagger.value,
        child: SingleChildScrollView(
          padding: ResponsiveHelper.getContentPadding(context),
          child: _buildAnalyticsContent(theme),
        ),
      ),
    );
  }
  
  Widget _buildAnalyticsContent(ThemeData theme) {
    final data = _drillData[_selectedDimension];
    
    switch (_selectedDimension) {
      case 'overview':
        return _buildOverviewContent(data);
      case 'trends':
        return _buildTrendsContent(data);
      case 'segments':
        return _buildSegmentsContent(data);
      case 'cohorts':
        return _buildCohortsContent(data);
      case 'funnels':
        return _buildFunnelsContent(data);
      case 'attribution':
        return _buildAttributionContent(data);
      default:
        return _buildOverviewContent(data);
    }
  }
  
  Widget _buildOverviewContent(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary metric
        _buildPrimaryMetricCard(data['primaryMetric']),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
        
        // Secondary metrics grid
        Text(
          'Key Metrics',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
            mainAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
          ),
          itemCount: data['secondaryMetrics'].length,
          itemBuilder: (context, index) {
            return _buildSecondaryMetricCard(data['secondaryMetrics'][index]);
          },
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
        
        // Distribution chart
        _buildDistributionChart(data['distributions']),
      ],
    );
  }
  
  Widget _buildPrimaryMetricCard(Map<String, dynamic> metric) {
    return AnimatedBuilder(
      animation: _interactionPulse,
      builder: (context, child) {
        return Transform.scale(
          scale: _interactionPulse.value,
          child: Container(
            padding: ResponsiveHelper.getContentPadding(context),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF1E40AF),
                  Color(0xFF1E3A8A),
                ],
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 24)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Primary Metric',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Icon(
                      metric['trend'] == 'up' ? Icons.trending_up : Icons.trending_down,
                      color: metric['trend'] == 'up' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                
                Text(
                  '${metric['value'].toStringAsFixed(2)}M',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
                    vertical: ResponsiveHelper.getResponsiveHeight(context, 6),
                  ),
                  decoration: BoxDecoration(
                    color: metric['trend'] == 'up' 
                        ? const Color(0xFF10B981).withOpacity(0.2)
                        : const Color(0xFFEF4444).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                  ),
                  child: Text(
                    '${metric['change'] > 0 ? '+' : ''}${metric['change'].toStringAsFixed(1)}%',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: metric['trend'] == 'up' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSecondaryMetricCard(Map<String, dynamic> metric) {
    return GestureDetector(
      onTap: () => _drillDown(metric['name']),
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              metric['color'].withOpacity(0.2),
              metric['color'].withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
          border: Border.all(
            color: metric['color'].withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  metric['icon'],
                  color: metric['color'],
                  size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white.withOpacity(0.5),
                  size: ResponsiveHelper.getIconSize(context, baseSize: 16),
                ),
              ],
            ),
            
            const Spacer(),
            
            Text(
              metric['value'].toStringAsFixed(metric['name'] == 'Users' ? 0 : 1),
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
            
            Text(
              metric['name'],
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
            
            Text(
              '${metric['change'] > 0 ? '+' : ''}${metric['change'].toStringAsFixed(1)}%',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 12,
                fontWeight: FontWeight.bold,
                color: metric['change'] > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDistributionChart(List<dynamic> distributions) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribution Analysis',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
          
          ...distributions.map<Widget>((item) {
            return Container(
              margin: EdgeInsets.only(
                bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['category'],
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '${item['value'].toStringAsFixed(1)}%',
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: item['color'],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                  Container(
                    height: ResponsiveHelper.getResponsiveHeight(context, 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveHeight(context, 3)),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: item['value'] / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [item['color'], item['color'].withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveHeight(context, 3)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildTrendsContent(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trend Analysis',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
        
        // Time series visualization placeholder
        Container(
          height: ResponsiveHelper.getResponsiveHeight(context, 300),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
          ),
          child: CustomPaint(
            painter: TrendChartPainter(data['timeSeries']),
            child: Container(),
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
        
        // Seasonality insights
        _buildInsightCard(
          'Seasonality Pattern',
          'Weekly pattern detected with ${(data['seasonality']['strength'] * 100).toInt()}% strength',
          Icons.calendar_today,
          const Color(0xFF8B5CF6),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        // Anomalies
        Text(
          'Anomalies Detected',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
        
        ...data['anomalies'].map<Widget>((anomaly) {
          return _buildAnomalyCard(anomaly);
        }).toList(),
      ],
    );
  }
  
  Widget _buildSegmentsContent(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Segments',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
            mainAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
          ),
          itemCount: data['userSegments'].length,
          itemBuilder: (context, index) {
            return _buildSegmentCard(data['userSegments'][index]);
          },
        ),
      ],
    );
  }
  
  Widget _buildCohortsContent(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cohort Analysis',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
        
        // Cohort heatmap placeholder
        Container(
          height: ResponsiveHelper.getResponsiveHeight(context, 400),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.grid_on,
                  color: const Color(0xFF8B5CF6),
                  size: ResponsiveHelper.getIconSize(context, baseSize: 48),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                Text(
                  'Cohort Retention Heatmap',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                Text(
                  'Interactive retention analysis by cohort',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
        
        // Insights
        Text(
          'Key Insights',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
        
        ...data['insights'].map<Widget>((insight) {
          return _buildInsightCard(
            'Cohort Insight',
            insight,
            Icons.lightbulb,
            const Color(0xFFF59E0B),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildFunnelsContent(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversion Funnel',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
        
        // Funnel stages
        ...data['conversionFunnel'].map<Widget>((stage) {
          return _buildFunnelStage(stage);
        }).toList(),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
        
        // Dropoff analysis
        _buildInsightCard(
          'Optimization Opportunity',
          data['dropoffAnalysis']['improvement_potential'],
          Icons.trending_up,
          const Color(0xFF10B981),
        ),
      ],
    );
  }
  
  Widget _buildAttributionContent(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attribution Analysis',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
        
        // Attribution channels
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
            mainAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
          ),
          itemCount: data['channels'].length,
          itemBuilder: (context, index) {
            return _buildAttributionCard(data['channels'][index]);
          },
        ),
      ],
    );
  }
  
  Widget _buildZoomedView(ThemeData theme) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.zoom_in,
              color: const Color(0xFF3B82F6),
              size: ResponsiveHelper.getIconSize(context, baseSize: 64),
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            Text(
              'Zoomed Analytics View',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            Text(
              'Enhanced focus mode for detailed analysis',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomControls(ThemeData theme) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        color: const Color(0xFF1A202C),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Time range selector
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _timeRanges.map((range) {
                  final isSelected = _selectedTimeframe == range.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeframe = range.id;
                      });
                      HapticFeedback.lightImpact();
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        right: ResponsiveHelper.getAccessibleSpacing(context, 8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
                        vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [range.color, range.color.withOpacity(0.8)],
                              )
                            : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        range.label,
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Advanced toggle
          GestureDetector(
            onTap: () {
              setState(() {
                _showAdvancedAnalytics = !_showAdvancedAnalytics;
              });
              HapticFeedback.lightImpact();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
                vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
              ),
              decoration: BoxDecoration(
                gradient: _showAdvancedAnalytics
                    ? const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                      )
                    : null,
                color: _showAdvancedAnalytics ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                border: Border.all(
                  color: _showAdvancedAnalytics ? Colors.transparent : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: ResponsiveHelper.getIconSize(context, baseSize: 16),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                  Text(
                    'Advanced',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 12,
                      fontWeight: _showAdvancedAnalytics ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightCard(String title, String description, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
      ),
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: ResponsiveHelper.getIconSize(context, baseSize: 20),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                Text(
                  description,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnomalyCard(Map<String, dynamic> anomaly) {
    final colors = {
      'spike': const Color(0xFF10B981),
      'drop': const Color(0xFFEF4444),
      'outlier': const Color(0xFFF59E0B),
    };
    
    final color = colors[anomaly['type']] ?? const Color(0xFF6B7280);
    
    return _buildInsightCard(
      '${anomaly['type'][0].toUpperCase()}${anomaly['type'].substring(1)} Detected',
      'Anomaly detected with ${(anomaly['severity'] * 100).toInt()}% severity',
      Icons.warning,
      color,
    );
  }
  
  Widget _buildSegmentCard(Map<String, dynamic> segment) {
    return GestureDetector(
      onTap: () => _drillDown(segment['name']),
      child: Container(
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              segment['color'].withOpacity(0.2),
              segment['color'].withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
          border: Border.all(
            color: segment['color'].withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  segment['name'],
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.white.withOpacity(0.5),
                  size: ResponsiveHelper.getIconSize(context, baseSize: 16),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
            
            Text(
              '${segment['size']} users',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 24,
                fontWeight: FontWeight.bold,
                color: segment['color'],
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            
            Text(
              '\$${segment['value'].toStringAsFixed(0)} avg value',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
            
            Text(
              '${segment['growth'] > 0 ? '+' : ''}${segment['growth'].toStringAsFixed(1)}% growth',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 12,
                fontWeight: FontWeight.bold,
                color: segment['growth'] > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFunnelStage(Map<String, dynamic> stage) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
      ),
      child: Row(
        children: [
          // Stage indicator
          Container(
            width: ResponsiveHelper.getResponsiveWidth(context, 60),
            height: ResponsiveHelper.getResponsiveHeight(context, 60),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [stage['color'], stage['color'].withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${(stage['rate'] * 100).toInt()}%',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          // Stage info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage['stage'],
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                Text(
                  '${stage['users']} users',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Funnel bar
          Container(
            width: ResponsiveHelper.getResponsiveWidth(context, 100),
            height: ResponsiveHelper.getResponsiveHeight(context, 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveHeight(context, 4)),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: stage['rate'],
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [stage['color'], stage['color'].withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveHeight(context, 4)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAttributionCard(Map<String, dynamic> channel) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            channel['color'].withOpacity(0.2),
            channel['color'].withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
        border: Border.all(
          color: channel['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            channel['name'],
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'First Touch',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 10,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '${channel['firstTouch'].toStringAsFixed(1)}%',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: channel['color'],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Touch',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 10,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      '${channel['lastTouch'].toStringAsFixed(1)}%',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: channel['color'],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Data models
class TimeRange {
  final String id;
  final String label;
  final Color color;

  TimeRange(this.id, this.label, this.color);
}

class AnalysisDimension {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  AnalysisDimension(this.id, this.name, this.icon, this.color);
}

// Custom painter for trend chart
class TrendChartPainter extends CustomPainter {
  final List<dynamic> data;

  TrendChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = (data[i]['value'] - 50) / 200; // Normalize to 0-1
      final y = size.height - (normalizedValue * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF10B981);
    
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = (data[i]['value'] - 50) / 200;
      final y = size.height - (normalizedValue * size.height);
      
      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(TrendChartPainter oldDelegate) {
    return data != oldDelegate.data;
  }
}