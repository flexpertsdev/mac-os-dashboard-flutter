import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';
import '../services/demo_session_service.dart';
import '../models/demo_models.dart';
import '../models/app_models.dart';

class UserImpactAnalysis extends StatefulWidget {
  final UserProfile user;
  
  const UserImpactAnalysis({
    super.key,
    required this.user,
  });

  @override
  State<UserImpactAnalysis> createState() => _UserImpactAnalysisState();
}

class _UserImpactAnalysisState extends State<UserImpactAnalysis>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _impactController;
  late AnimationController _warningController;
  
  late Animation<double> _heroAnimation;
  late Animation<double> _impactAnimation;
  late Animation<double> _warningPulse;
  
  bool _showConfirmation = false;
  bool _analysisComplete = false;
  String _selectedReason = '';
  final List<String> _deletionReasons = [
    'Employee left company',
    'Role terminated',
    'Account consolidation',
    'Security concerns',
    'Other',
  ];
  
  final Map<String, dynamic> _impactData = {};
  
  @override
  void initState() {
    super.initState();
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _impactController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _warningController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    
    _impactAnimation = CurvedAnimation(
      parent: _impactController,
      curve: Curves.easeOutBack,
    );
    
    _warningPulse = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _warningController,
      curve: Curves.easeInOut,
    ));
    
    _heroController.forward();
    _performImpactAnalysis();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _impactController.dispose();
    _warningController.dispose();
    super.dispose();
  }
  
  void _performImpactAnalysis() async {
    // Simulate analysis delay for dramatic effect
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted) return;
    
    // Generate realistic impact data
    setState(() {
      _impactData.addAll({
        'projectsInvolved': math.Random().nextInt(8) + 3,
        'activeReports': math.Random().nextInt(12) + 5,
        'teamCollaborations': math.Random().nextInt(6) + 2,
        'dataOwnership': math.Random().nextInt(20) + 10,
        'accessPermissions': math.Random().nextInt(15) + 8,
        'lastActivity': DateTime.now().subtract(Duration(hours: math.Random().nextInt(48) + 1)),
        'criticalWorkflows': math.Random().nextInt(4) + 1,
        'riskLevel': math.Random().nextDouble() * 0.4 + 0.3, // 30-70% risk
      });
      _analysisComplete = true;
    });
    
    _impactController.forward();
    
    final demoService = context.read<DemoSessionService>();
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'User Impact Analysis',
      description: 'Analyzed potential impact of removing ${widget.user.name} from the system.',
      impact: 'Found ${_impactData['projectsInvolved']} active projects and ${_impactData['activeReports']} reports that may be affected.',
      discoveredAt: DateTime.now(),
      source: 'User Management System',
      confidence: 0.95,
      type: InsightType.risk,
    );
    
    demoService.addInsight(insight);
    demoService.incrementFeatureInteraction('user_impact_analysis');
  }
  
  void _proceedWithDeletion() {
    setState(() {
      _showConfirmation = true;
    });
    HapticFeedback.mediumImpact();
  }
  
  void _confirmDeletion() async {
    final demoService = context.read<DemoSessionService>();
    
    // Add insight for user deletion
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Team Member Removed',
      description: '${widget.user.name} was removed from the system with proper impact mitigation.',
      impact: 'Data ownership transferred, ${_impactData['projectsInvolved']} projects reassigned to team leads.',
      discoveredAt: DateTime.now(),
      source: 'User Management System',
      confidence: 1.0,
      type: InsightType.optimization,
    );
    
    demoService.addInsight(insight);
    demoService.incrementFeatureInteraction('user_deletion');
    
    HapticFeedback.heavyImpact();
    
    // Show success animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0D1A),
      body: AnimatedBuilder(
        animation: Listenable.merge([_heroAnimation, _impactAnimation, _warningPulse]),
        builder: (context, child) {
          return SafeArea(
            child: _showConfirmation 
                ? _buildConfirmationView(theme)
                : _buildAnalysisView(theme),
          );
        },
      ),
    );
  }
  
  Widget _buildAnalysisView(ThemeData theme) {
    return Transform.translate(
      offset: Offset(0, (1 - _heroAnimation.value) * 50),
      child: Opacity(
        opacity: _heroAnimation.value,
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getContentPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserCard(theme),
                    
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
                    
                    if (!_analysisComplete)
                      _buildAnalysisProgress()
                    else
                      _buildImpactResults(theme),
                    
                    if (_analysisComplete) ...[
                      SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
                      _buildMitigationOptions(theme),
                      
                      SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
                      _buildActionButtons(theme),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConfirmationView(ThemeData theme) {
    return Column(
      children: [
        _buildHeader(theme, showBackButton: true),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getContentPadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Warning animation
                  AnimatedBuilder(
                    animation: _warningPulse,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _warningPulse.value,
                        child: Container(
                          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 32)),
                          decoration: BoxDecoration(
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFFEF4444),
                                Color(0xFFDC2626),
                                Color(0xFFB91C1C),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFEF4444).withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.warning,
                            color: Colors.white,
                            size: ResponsiveHelper.getIconSize(context, baseSize: 64),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
                  
                  Text(
                    'Final Confirmation',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                  
                  Text(
                    'You are about to permanently delete ${widget.user.name} from the system.',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                  
                  Text(
                    'This action cannot be undone.',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEF4444),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 40)),
                  
                  // Reason selection
                  _buildReasonSelection(theme),
                  
                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 40)),
                  
                  // Final action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showConfirmation = false;
                            });
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: ResponsiveTheme.responsiveTextStyle(
                                context,
                                baseFontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                      
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectedReason.isNotEmpty ? _confirmDeletion : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
                            ),
                            decoration: BoxDecoration(
                              gradient: _selectedReason.isNotEmpty
                                  ? const LinearGradient(
                                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                    )
                                  : null,
                              color: _selectedReason.isEmpty 
                                  ? Colors.grey.withOpacity(0.3)
                                  : null,
                              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                              boxShadow: _selectedReason.isNotEmpty ? [
                                BoxShadow(
                                  color: const Color(0xFFEF4444).withOpacity(0.4),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ] : null,
                            ),
                            child: Text(
                              'Delete Permanently',
                              style: ResponsiveTheme.responsiveTextStyle(
                                context,
                                baseFontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _selectedReason.isNotEmpty 
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildHeader(ThemeData theme, {bool showBackButton = false}) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFEF4444).withOpacity(0.8),
            const Color(0xFFDC2626).withOpacity(0.6),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (showBackButton && _showConfirmation) {
                setState(() {
                  _showConfirmation = false;
                });
              } else {
                Navigator.of(context).pop();
              }
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
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showConfirmation ? 'Confirm Deletion' : 'Impact Analysis',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _showConfirmation 
                      ? 'Final step - please confirm your action'
                      : 'Understanding the impact of user removal',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
              vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.white,
                  size: ResponsiveHelper.getIconSize(context, baseSize: 16),
                ),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                Text(
                  'High Risk',
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
        ],
      ),
    );
  }
  
  Widget _buildUserCard(ThemeData theme) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEF4444).withOpacity(0.1),
            const Color(0xFFDC2626).withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: ResponsiveHelper.getResponsiveWidth(context, 40),
            backgroundColor: const Color(0xFFEF4444),
            child: Text(
              _getInitials(widget.user.name),
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                Text(
                  '${widget.user.role} • ${widget.user.department}',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                Text(
                  widget.user.email,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisProgress() {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Column(
        children: [
          SizedBox(
            width: ResponsiveHelper.getResponsiveWidth(context, 120),
            height: ResponsiveHelper.getResponsiveWidth(context, 120),
            child: CircularProgressIndicator(
              strokeWidth: 8,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
          
          Text(
            'Analyzing Impact...',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
          
          Text(
            'Checking projects, reports, and team dependencies',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildImpactResults(ThemeData theme) {
    return Transform.translate(
      offset: Offset(0, (1 - _impactAnimation.value) * 50),
      child: Opacity(
        opacity: _impactAnimation.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impact Assessment',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
            
            // Risk level indicator
            Container(
              padding: ResponsiveHelper.getContentPadding(context),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEF4444).withOpacity(0.2),
                    const Color(0xFFDC2626).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: const Color(0xFFEF4444),
                    size: ResponsiveHelper.getIconSize(context, baseSize: 32),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'High Risk Operation',
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                        Text(
                          'This user has significant system involvement',
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(_impactData['riskLevel'] * 100).toInt()}%',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
            
            // Impact metrics grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3,
              childAspectRatio: 1.2,
              crossAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
              mainAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
              children: [
                _buildImpactMetric(
                  'Active Projects',
                  '${_impactData['projectsInvolved']}',
                  Icons.assignment,
                  const Color(0xFF3B82F6),
                ),
                _buildImpactMetric(
                  'Reports Owned',
                  '${_impactData['activeReports']}',
                  Icons.analytics,
                  const Color(0xFF10B981),
                ),
                _buildImpactMetric(
                  'Team Links',
                  '${_impactData['teamCollaborations']}',
                  Icons.group,
                  const Color(0xFF8B5CF6),
                ),
                _buildImpactMetric(
                  'Data Assets',
                  '${_impactData['dataOwnership']}',
                  Icons.storage,
                  const Color(0xFFF59E0B),
                ),
                _buildImpactMetric(
                  'Permissions',
                  '${_impactData['accessPermissions']}',
                  Icons.security,
                  const Color(0xFFEF4444),
                ),
                _buildImpactMetric(
                  'Workflows',
                  '${_impactData['criticalWorkflows']}',
                  Icons.alt_route,
                  const Color(0xFF06B6D4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImpactMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: ResponsiveHelper.getIconSize(context, baseSize: 28),
          ),
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
          Text(
            value,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
          Text(
            label,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildMitigationOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended Actions',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        _buildMitigationItem(
          'Transfer Data Ownership',
          'Reassign ${_impactData['dataOwnership']} data assets to team lead',
          Icons.swap_horiz,
          const Color(0xFF10B981),
          recommended: true,
        ),
        
        _buildMitigationItem(
          'Backup User Content',
          'Export reports and personal dashboards',
          Icons.backup,
          const Color(0xFF3B82F6),
          recommended: true,
        ),
        
        _buildMitigationItem(
          'Notify Project Teams',
          'Alert ${_impactData['teamCollaborations']} collaboration teams',
          Icons.notifications,
          const Color(0xFFF59E0B),
          recommended: false,
        ),
        
        _buildMitigationItem(
          'Revoke Access Permissions',
          'Remove ${_impactData['accessPermissions']} system permissions',
          Icons.lock,
          const Color(0xFFEF4444),
          recommended: true,
        ),
      ],
    );
  }
  
  Widget _buildMitigationItem(
    String title,
    String description,
    IconData icon,
    Color color, {
    bool recommended = false,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
      ),
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (recommended)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsiveWidth(context, 8),
                          vertical: ResponsiveHelper.getResponsiveHeight(context, 4),
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
                        ),
                        child: Text(
                          'Recommended',
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
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
  
  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                  Text(
                    'Cancel',
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
          ),
        ),
        
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: _proceedWithDeletion,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                  Text(
                    'Proceed with Deletion',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildReasonSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason for Deletion',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        ..._deletionReasons.map((reason) {
          final isSelected = _selectedReason == reason;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedReason = reason;
              });
              HapticFeedback.lightImpact();
            },
            child: Container(
              margin: EdgeInsets.only(
                bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
              ),
              padding: ResponsiveHelper.getContentPadding(context),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                border: Border.all(
                  color: isSelected 
                      ? Colors.transparent 
                      : Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: ResponsiveHelper.getResponsiveWidth(context, 20),
                    height: ResponsiveHelper.getResponsiveWidth(context, 20),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: const Color(0xFFEF4444),
                            size: ResponsiveHelper.getIconSize(context, baseSize: 14),
                          )
                        : null,
                  ),
                  
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                  
                  Expanded(
                    child: Text(
                      reason,
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
  
  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: ResponsiveHelper.getContentPadding(context),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: ResponsiveHelper.getIconSize(context, baseSize: 64),
              color: Colors.white,
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            Text(
              'User Removed Successfully',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            Text(
              '${widget.user.name} has been removed from the system with proper data migration.',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close impact analysis
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveWidth(context, 32),
                  vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                ),
                child: Text(
                  'Return to Dashboard',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}