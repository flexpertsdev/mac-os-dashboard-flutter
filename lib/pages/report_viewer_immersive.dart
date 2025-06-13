import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';
import '../services/demo_session_service.dart';
import '../models/demo_models.dart';
import '../pages/analytics_explorer_immersive.dart';
import '../pages/export_studio_immersive.dart';

class ReportViewerImmersive extends StatefulWidget {
  final Map<String, dynamic> reportData;
  
  const ReportViewerImmersive({
    super.key,
    required this.reportData,
  });

  @override
  State<ReportViewerImmersive> createState() => _ReportViewerImmersiveState();
}

class _ReportViewerImmersiveState extends State<ReportViewerImmersive>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _chartController;
  late AnimationController _interactionController;
  late AnimationController _annotationController;
  
  late Animation<double> _heroAnimation;
  late Animation<double> _chartStagger;
  late Animation<double> _interactionPulse;
  late Animation<double> _annotationSlide;
  
  // Viewer state
  bool _showAnnotations = false;
  bool _showFilters = false;
  bool _isFullscreen = false;
  bool _showComments = false;
  String _selectedVisualization = 'all';
  
  // Interactive state
  final List<ReportAnnotation> _annotations = [];
  final List<ReportComment> _comments = [];
  final Map<String, bool> _appliedFilters = {};
  
  // Export options
  final List<ExportFormat> _exportFormats = [
    ExportFormat('PDF', Icons.picture_as_pdf, const Color(0xFFEF4444)),
    ExportFormat('Excel', Icons.table_chart, const Color(0xFF10B981)),
    ExportFormat('PowerPoint', Icons.slideshow, const Color(0xFFF59E0B)),
    ExportFormat('Image', Icons.image, const Color(0xFF8B5CF6)),
  ];

  @override
  void initState() {
    super.initState();
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _interactionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _annotationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    
    _chartStagger = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutBack,
    );
    
    _interactionPulse = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _interactionController,
      curve: Curves.easeInOut,
    ));
    
    _annotationSlide = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _annotationController,
      curve: Curves.easeOutCubic,
    ));
    
    _initializeReportData();
    _startAnimations();
  }

  void _initializeReportData() {
    // Generate sample annotations and comments
    _annotations.addAll([
      ReportAnnotation(
        id: '1',
        position: const Offset(0.3, 0.4),
        title: 'Revenue Spike',
        description: 'Q3 shows 23% growth in recurring revenue',
        type: AnnotationType.insight,
        author: 'Sarah Chen',
      ),
      ReportAnnotation(
        id: '2',
        position: const Offset(0.7, 0.6),
        title: 'Customer Acquisition',
        description: 'New marketing campaign driving 15% more leads',
        type: AnnotationType.highlight,
        author: 'Mike Johnson',
      ),
    ]);
    
    _comments.addAll([
      ReportComment(
        id: '1',
        author: 'David Kim',
        content: 'Excellent insights on the revenue trends. Should we drill down into the regional breakdown?',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        avatar: 'DK',
      ),
      ReportComment(
        id: '2',
        author: 'Lisa Wong',
        content: 'The customer acquisition data is very promising. Let\'s discuss this in tomorrow\'s strategy meeting.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        avatar: 'LW',
      ),
    ]);
  }

  void _startAnimations() async {
    _heroController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _chartController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _chartController.dispose();
    _interactionController.dispose();
    _annotationController.dispose();
    super.dispose();
  }
  
  void _toggleAnnotations() {
    setState(() {
      _showAnnotations = !_showAnnotations;
    });
    
    if (_showAnnotations) {
      _annotationController.forward();
    } else {
      _annotationController.reverse();
    }
    
    HapticFeedback.mediumImpact();
  }
  
  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    HapticFeedback.mediumImpact();
  }
  
  void _shareReport() async {
    final demoService = context.read<DemoSessionService>();
    
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Report Shared',
      description: 'Shared "${widget.reportData['title']}" with team members.',
      impact: 'Enhanced collaboration and data-driven decision making across teams.',
      discoveredAt: DateTime.now(),
      source: 'Report Viewer',
      confidence: 0.95,
      type: InsightType.collaboration,
    );
    
    demoService.addInsight(insight);
    demoService.incrementFeatureInteraction('report_sharing');
    
    HapticFeedback.heavyImpact();
    
    showDialog(
      context: context,
      builder: (context) => _buildShareDialog(),
    );
  }
  
  void _exportReport(ExportFormat format) async {
    final demoService = context.read<DemoSessionService>();
    
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Report Exported',
      description: 'Exported "${widget.reportData['title']}" as ${format.name}.',
      impact: 'Data insights distributed for stakeholder presentation and analysis.',
      discoveredAt: DateTime.now(),
      source: 'Report Viewer',
      confidence: 1.0,
      type: InsightType.optimization,
    );
    
    demoService.addInsight(insight);
    demoService.incrementFeatureInteraction('report_export');
    
    HapticFeedback.heavyImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(format.icon, color: Colors.white),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            Expanded(child: Text('Report exported as ${format.name}')),
          ],
        ),
        backgroundColor: format.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D1A),
      body: AnimatedBuilder(
        animation: Listenable.merge([_heroAnimation, _chartStagger, _interactionPulse]),
        builder: (context, child) {
          return Stack(
            children: [
              // Main content
              Column(
                children: [
                  _buildReportHeader(theme),
                  if (_showFilters) _buildFilterBar(theme),
                  Expanded(
                    child: _buildReportContent(theme),
                  ),
                  _buildInteractionToolbar(theme),
                ],
              ),
              
              // Annotations overlay
              if (_showAnnotations) _buildAnnotationsOverlay(theme),
              
              // Comments panel
              if (_showComments) _buildCommentsPanel(theme),
              
              // Fullscreen overlay
              if (_isFullscreen) _buildFullscreenOverlay(theme),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildReportHeader(ThemeData theme) {
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
                
                // Report info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.reportData['title']?.toString() ?? 'Business Report',
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                      Text(
                        widget.reportData['description']?.toString() ?? 'Interactive business intelligence dashboard',
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
                    _buildHeaderAction(Icons.fullscreen, 'Fullscreen', _toggleFullscreen),
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                    _buildHeaderAction(Icons.share, 'Share', _shareReport),
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                    _buildHeaderAction(Icons.download, 'Export', () => _showExportOptions()),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            
            // Report metadata
            Row(
              children: [
                _buildMetadataChip('Updated', '2 hours ago', Icons.schedule, const Color(0xFF10B981)),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                _buildMetadataChip('Data Points', '2.4M', Icons.storage, const Color(0xFF3B82F6)),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                _buildMetadataChip('Shared With', '8 people', Icons.group, const Color(0xFF8B5CF6)),
                
                const Spacer(),
                
                // View options
                _buildViewSelector(),
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
  
  Widget _buildMetadataChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
        vertical: ResponsiveHelper.getResponsiveHeight(context, 6),
      ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getIconSize(context, baseSize: 16),
          ),
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 6)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 10,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildViewSelector() {
    final views = ['All', 'Charts', 'Tables', 'KPIs'];
    
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 4)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: views.map((view) {
          final isSelected = _selectedVisualization == view.toLowerCase();
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedVisualization = view.toLowerCase();
              });
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
                vertical: ResponsiveHelper.getResponsiveHeight(context, 6),
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
              ),
              child: Text(
                view,
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
    );
  }
  
  Widget _buildFilterBar(ThemeData theme) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        color: const Color(0xFF1A202C),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: const Color(0xFF3B82F6),
            size: ResponsiveHelper.getIconSize(context, baseSize: 20),
          ),
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
          Expanded(
            child: Wrap(
              spacing: ResponsiveHelper.getAccessibleSpacing(context, 8),
              children: [
                _buildFilterChip('Date Range', 'Last 30 days'),
                _buildFilterChip('Department', 'All'),
                _buildFilterChip('Region', 'North America'),
                _buildFilterChip('Metric Type', 'Revenue'),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showFilters = false;
              });
            },
            child: Icon(
              Icons.close,
              color: Colors.white.withOpacity(0.6),
              size: ResponsiveHelper.getIconSize(context, baseSize: 20),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
        vertical: ResponsiveHelper.getResponsiveHeight(context, 6),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildReportContent(ThemeData theme) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      child: AnimatedBuilder(
        animation: _chartStagger,
        builder: (context, child) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
              childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.2 : 1.5,
              crossAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 16),
              mainAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 16),
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final delay = index * 0.1;
              final animationValue = math.max(0.0, (_chartStagger.value - delay) * (1.0 / (1.0 - delay)));
              
              return Transform.scale(
                scale: animationValue,
                child: _buildVisualizationCard(index, theme),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildVisualizationCard(int index, ThemeData theme) {
    final visualizations = [
      VisualizationData(
        'Revenue Trends',
        'Monthly recurring revenue growth',
        Icons.show_chart,
        const Color(0xFF10B981),
        '\$2.4M',
        '+23%',
      ),
      VisualizationData(
        'Customer Acquisition',
        'New customer sign-ups',
        Icons.person_add,
        const Color(0xFF3B82F6),
        '1,247',
        '+15%',
      ),
      VisualizationData(
        'Market Share',
        'Competitive positioning',
        Icons.pie_chart,
        const Color(0xFF8B5CF6),
        '34.2%',
        '+2.1%',
      ),
      VisualizationData(
        'User Engagement',
        'Daily active users',
        Icons.trending_up,
        const Color(0xFFF59E0B),
        '45.2K',
        '+8%',
      ),
      VisualizationData(
        'Conversion Rate',
        'Lead to customer conversion',
        Icons.trending_up,
        const Color(0xFFEF4444),
        '12.4%',
        '+1.2%',
      ),
      VisualizationData(
        'Support Tickets',
        'Customer support metrics',
        Icons.support_agent,
        const Color(0xFF06B6D4),
        '89',
        '-12%',
      ),
    ];
    
    final viz = visualizations[index % visualizations.length];
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showVisualizationDetails(viz);
      },
      child: AnimatedBuilder(
        animation: _interactionPulse,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0, // Removed pulsing for better UX
            child: Container(
              padding: ResponsiveHelper.getContentPadding(context),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    viz.color.withOpacity(0.1),
                    viz.color.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                border: Border.all(
                  color: viz.color.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: viz.color.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [viz.color, viz.color.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                        ),
                        child: Icon(
                          viz.icon,
                          color: Colors.white,
                          size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                        ),
                      ),
                      
                      SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viz.title,
                              style: ResponsiveTheme.responsiveTextStyle(
                                context,
                                baseFontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              viz.subtitle,
                              style: ResponsiveTheme.responsiveTextStyle(
                                context,
                                baseFontSize: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Icon(
                        Icons.more_vert,
                        color: Colors.white.withOpacity(0.6),
                        size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
                  
                  // Chart placeholder
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            viz.color.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                        border: Border.all(
                          color: viz.color.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: CustomPaint(
                        painter: ChartPreviewPainter(color: viz.color),
                        child: Container(),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                  
                  // Metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current',
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 12,
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            viz.value,
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsiveWidth(context, 8),
                          vertical: ResponsiveHelper.getResponsiveHeight(context, 4),
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [viz.color, viz.color.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                        ),
                        child: Text(
                          viz.change,
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInteractionToolbar(ThemeData theme) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildToolbarAction(
            Icons.note_add,
            'Annotations',
            _showAnnotations,
            _toggleAnnotations,
          ),
          
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          _buildToolbarAction(
            Icons.filter_list,
            'Filters',
            _showFilters,
            () {
              setState(() {
                _showFilters = !_showFilters;
              });
              HapticFeedback.lightImpact();
            },
          ),
          
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          _buildToolbarAction(
            Icons.chat_bubble,
            'Comments',
            _showComments,
            () {
              setState(() {
                _showComments = !_showComments;
              });
              HapticFeedback.lightImpact();
            },
          ),
          
          const Spacer(),
          
          // Export button
          GestureDetector(
            onTap: _showExportOptions,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
                vertical: ResponsiveHelper.getResponsiveHeight(context, 10),
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.file_download,
                    color: Colors.white,
                    size: ResponsiveHelper.getIconSize(context, baseSize: 18),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                  Text(
                    'Export',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 14,
                      fontWeight: FontWeight.bold,
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
  
  Widget _buildToolbarAction(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
          vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
        ),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                )
              : null,
          color: isActive ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: ResponsiveHelper.getIconSize(context, baseSize: 18),
            ),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            Text(
              label,
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnnotationsOverlay(ThemeData theme) {
    return AnimatedBuilder(
      animation: _annotationSlide,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_annotationSlide.value * MediaQuery.of(context).size.width, 0),
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Stack(
              children: _annotations.map((annotation) {
                return Positioned(
                  left: annotation.position.dx * MediaQuery.of(context).size.width,
                  top: annotation.position.dy * MediaQuery.of(context).size.height,
                  child: _buildAnnotationPin(annotation),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildAnnotationPin(ReportAnnotation annotation) {
    return GestureDetector(
      onTap: () => _showAnnotationDetails(annotation),
      child: Container(
        width: ResponsiveHelper.getResponsiveWidth(context, 32),
        height: ResponsiveHelper.getResponsiveWidth(context, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: annotation.type == AnnotationType.insight
                ? [const Color(0xFF10B981), const Color(0xFF059669)]
                : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (annotation.type == AnnotationType.insight
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B))
                  .withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          annotation.type == AnnotationType.insight ? Icons.lightbulb : Icons.highlight,
          color: Colors.white,
          size: ResponsiveHelper.getIconSize(context, baseSize: 16),
        ),
      ),
    );
  }
  
  Widget _buildCommentsPanel(ThemeData theme) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: const Color(0xFF1A202C),
          border: Border(
            left: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(-5, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Comments header
            Container(
              padding: ResponsiveHelper.getContentPadding(context),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble,
                    color: const Color(0xFF8B5CF6),
                    size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                  Expanded(
                    child: Text(
                      'Comments (${_comments.length})',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showComments = false;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.6),
                      size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            // Comments list
            Expanded(
              child: ListView.builder(
                padding: ResponsiveHelper.getContentPadding(context),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  return _buildCommentItem(_comments[index]);
                },
              ),
            ),
            
            // Add comment
            Container(
              padding: ResponsiveHelper.getContentPadding(context),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 14,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                          borderSide: const BorderSide(
                            color: Color(0xFF8B5CF6),
                            width: 2,
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
                          vertical: ResponsiveHelper.getResponsiveHeight(context, 10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      // Add comment logic
                    },
                    child: Container(
                      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 10)),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                      ),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: ResponsiveHelper.getIconSize(context, baseSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommentItem(ReportComment comment) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: ResponsiveHelper.getResponsiveWidth(context, 20),
            backgroundColor: const Color(0xFF8B5CF6),
            child: Text(
              comment.avatar,
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author,
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                    Text(
                      _formatTimestamp(comment.timestamp),
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                Text(
                  comment.content,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFullscreenOverlay(ThemeData theme) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fullscreen_exit,
              size: ResponsiveHelper.getIconSize(context, baseSize: 64),
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            Text(
              'Fullscreen Mode',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            Text(
              'Enhanced report viewing experience',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
            GestureDetector(
              onTap: _toggleFullscreen,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveWidth(context, 24),
                  vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                ),
                child: Text(
                  'Exit Fullscreen',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showVisualizationDetails(VisualizationData viz) {
    // Navigate to immersive analytics explorer instead of modal
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnalyticsExplorerImmersive(
          metricData: {
            'title': viz.title,
            'subtitle': viz.subtitle,
            'value': viz.value,
            'change': viz.change,
            'color': viz.color,
            'icon': viz.icon,
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }
  
  void _showVisualizationDetailsOld(VisualizationData viz) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: ResponsiveHelper.getContentPadding(context),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                viz.color.withOpacity(0.1),
                viz.color.withOpacity(0.05),
                Colors.black.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 24)),
            border: Border.all(
              color: viz.color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [viz.color, viz.color.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                    ),
                    child: Icon(
                      viz.icon,
                      color: Colors.white,
                      size: ResponsiveHelper.getIconSize(context, baseSize: 32),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viz.title,
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          viz.subtitle,
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
              
              // Detailed chart area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        viz.color.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                    border: Border.all(
                      color: viz.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          viz.value,
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: viz.color,
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
                            vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [viz.color, viz.color.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                          ),
                          child: Text(
                            '${viz.change} vs last period',
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showAnnotationDetails(ReportAnnotation annotation) {
    // Navigate to immersive analytics explorer for annotation analysis
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AnalyticsExplorerImmersive(
          metricData: {
            'title': annotation.title,
            'subtitle': 'Annotation Analysis',
            'description': annotation.description,
            'author': annotation.author,
            'type': annotation.type.toString(),
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }
  
  void _showAnnotationDetailsOld(ReportAnnotation annotation) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: ResponsiveHelper.getContentPadding(context),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1A202C),
                const Color(0xFF2D3748),
              ],
            ),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
            border: Border.all(
              color: annotation.type == AnnotationType.insight
                  ? const Color(0xFF10B981).withOpacity(0.5)
                  : const Color(0xFFF59E0B).withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: annotation.type == AnnotationType.insight
                            ? [const Color(0xFF10B981), const Color(0xFF059669)]
                            : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                    ),
                    child: Icon(
                      annotation.type == AnnotationType.insight ? Icons.lightbulb : Icons.highlight,
                      color: Colors.white,
                      size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          annotation.title,
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'by ${annotation.author}',
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.6),
                      size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
              
              Text(
                annotation.description,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 16,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showExportOptions() {
    // Navigate to immersive export studio instead of bottom sheet
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ExportStudioImmersive(
          reportData: widget.reportData,
          exportFormats: _exportFormats,
        ),
        fullscreenDialog: true,
      ),
    );
  }
  
  void _showExportOptionsOld() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: ResponsiveHelper.getContentPadding(context),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A202C), Color(0xFF2D3748)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ResponsiveHelper.getResponsiveWidth(context, 24)),
            topRight: Radius.circular(ResponsiveHelper.getResponsiveWidth(context, 24)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ResponsiveHelper.getResponsiveWidth(context, 40),
              height: ResponsiveHelper.getResponsiveHeight(context, 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveHeight(context, 2)),
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
            
            Text(
              'Export Report',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
                mainAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
              ),
              itemCount: _exportFormats.length,
              itemBuilder: (context, index) {
                final format = _exportFormats[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _exportReport(format);
                  },
                  child: Container(
                    padding: ResponsiveHelper.getContentPadding(context),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          format.color.withOpacity(0.2),
                          format.color.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                      border: Border.all(
                        color: format.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          format.icon,
                          color: format.color,
                          size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                        ),
                        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                        Text(
                          format.name,
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShareDialog() {
    // Navigate to immersive collaboration studio instead of dialog
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CollaborationStudioImmersive(
          reportData: widget.reportData,
        ),
        fullscreenDialog: true,
      ),
    );
    
    return const SizedBox.shrink(); // Return empty widget
  }
  
  Widget _buildShareDialogOld() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: ResponsiveHelper.getContentPadding(context),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.share,
              size: ResponsiveHelper.getIconSize(context, baseSize: 48),
              color: Colors.white,
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            Text(
              'Report Shared Successfully!',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            Text(
              'Team members will receive notifications with access to the latest insights.',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveWidth(context, 24),
                  vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                ),
                child: Text(
                  'Continue',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Data models
class VisualizationData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String value;
  final String change;

  VisualizationData(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.value,
    this.change,
  );
}

class ReportAnnotation {
  final String id;
  final Offset position;
  final String title;
  final String description;
  final AnnotationType type;
  final String author;

  ReportAnnotation({
    required this.id,
    required this.position,
    required this.title,
    required this.description,
    required this.type,
    required this.author,
  });
}

enum AnnotationType { insight, highlight }

class ReportComment {
  final String id;
  final String author;
  final String content;
  final DateTime timestamp;
  final String avatar;

  ReportComment({
    required this.id,
    required this.author,
    required this.content,
    required this.timestamp,
    required this.avatar,
  });
}

class ExportFormat {
  final String name;
  final IconData icon;
  final Color color;

  ExportFormat(this.name, this.icon, this.color);
}

// Custom painter for chart preview
class ChartPreviewPainter extends CustomPainter {
  final Color color;

  ChartPreviewPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width * 0.9, size.height * 0.2),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw points
    paint.style = PaintingStyle.fill;
    for (final point in points) {
      canvas.drawCircle(point, 3, paint);
    }
  }

  @override
  bool shouldRepaint(ChartPreviewPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}