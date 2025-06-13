import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';
import '../services/demo_session_service.dart';
import '../models/demo_models.dart';

class CollaborationStudioImmersive extends StatefulWidget {
  final Map<String, dynamic> reportData;
  
  const CollaborationStudioImmersive({
    super.key,
    required this.reportData,
  });

  @override
  State<CollaborationStudioImmersive> createState() => _CollaborationStudioImmersiveState();
}

class _CollaborationStudioImmersiveState extends State<CollaborationStudioImmersive>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _teamController;
  late AnimationController _activityController;
  late AnimationController _shareController;
  
  late Animation<double> _heroAnimation;
  late Animation<double> _teamStagger;
  late Animation<double> _activityPulse;
  late Animation<double> _shareSlide;
  
  // Collaboration state
  bool _showTeamPanel = true;
  bool _showActivityFeed = true;
  bool _isSharing = false;
  String _selectedPermission = 'view';
  final List<String> _selectedTeamMembers = [];
  
  // Share options
  final List<String> _permissionLevels = ['view', 'comment', 'edit', 'admin'];
  final List<ShareMethod> _shareMethods = [
    ShareMethod('Email', Icons.email, const Color(0xFF3B82F6)),
    ShareMethod('Slack', Icons.chat, const Color(0xFF4A154B)),
    ShareMethod('Teams', Icons.groups, const Color(0xFF6264A7)),
    ShareMethod('Link', Icons.link, const Color(0xFF10B981)),
  ];
  
  // Team members data
  final List<TeamMember> _teamMembers = [
    TeamMember('Sarah Chen', 'Lead Analyst', 'SC', const Color(0xFF3B82F6), true),
    TeamMember('Mike Johnson', 'Data Scientist', 'MJ', const Color(0xFF10B981), true),
    TeamMember('Emily Rodriguez', 'Product Manager', 'ER', const Color(0xFFEF4444), false),
    TeamMember('David Kim', 'Engineering Lead', 'DK', const Color(0xFF8B5CF6), true),
    TeamMember('Lisa Wong', 'Marketing Director', 'LW', const Color(0xFFF59E0B), false),
    TeamMember('Alex Thompson', 'Operations Manager', 'AT', const Color(0xFF06B6D4), false),
  ];
  
  // Activity feed data
  final List<ActivityItem> _activityFeed = [];

  @override
  void initState() {
    super.initState();
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _teamController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _activityController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _shareController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    
    _teamStagger = CurvedAnimation(
      parent: _teamController,
      curve: Curves.easeOutBack,
    );
    
    _activityPulse = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _activityController,
      curve: Curves.easeInOut,
    ));
    
    _shareSlide = CurvedAnimation(
      parent: _shareController,
      curve: Curves.easeOutCubic,
    );
    
    _generateActivityFeed();
    _startAnimations();
  }

  void _generateActivityFeed() {
    final now = DateTime.now();
    _activityFeed.addAll([
      ActivityItem(
        id: '1',
        user: 'Sarah Chen',
        action: 'commented on Revenue Trends chart',
        timestamp: now.subtract(const Duration(minutes: 5)),
        type: ActivityType.comment,
      ),
      ActivityItem(
        id: '2',
        user: 'Mike Johnson',
        action: 'updated Customer Acquisition metrics',
        timestamp: now.subtract(const Duration(minutes: 12)),
        type: ActivityType.edit,
      ),
      ActivityItem(
        id: '3',
        user: 'David Kim',
        action: 'shared report with Engineering team',
        timestamp: now.subtract(const Duration(hours: 1)),
        type: ActivityType.share,
      ),
      ActivityItem(
        id: '4',
        user: 'Emily Rodriguez',
        action: 'added annotation to Market Share analysis',
        timestamp: now.subtract(const Duration(hours: 2)),
        type: ActivityType.annotation,
      ),
      ActivityItem(
        id: '5',
        user: 'Lisa Wong',
        action: 'exported report as PDF',
        timestamp: now.subtract(const Duration(hours: 3)),
        type: ActivityType.export,
      ),
    ]);
  }

  void _startAnimations() async {
    _heroController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _teamController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _teamController.dispose();
    _activityController.dispose();
    _shareController.dispose();
    super.dispose();
  }
  
  void _toggleTeamMember(String name) {
    setState(() {
      if (_selectedTeamMembers.contains(name)) {
        _selectedTeamMembers.remove(name);
      } else {
        _selectedTeamMembers.add(name);
      }
    });
    HapticFeedback.lightImpact();
  }
  
  void _shareWithTeam() async {
    if (_selectedTeamMembers.isEmpty) {
      _showErrorSnackBar('Please select team members to share with');
      return;
    }
    
    setState(() {
      _isSharing = true;
    });
    
    _shareController.forward();
    
    // Simulate sharing process
    await Future.delayed(const Duration(seconds: 2));
    
    final demoService = context.read<DemoSessionService>();
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Report Shared Successfully',
      description: 'Shared "${widget.reportData['title']}" with ${_selectedTeamMembers.length} team members.',
      impact: 'Enhanced collaboration and data-driven decision making across ${_selectedTeamMembers.length} team members.',
      discoveredAt: DateTime.now(),
      source: 'Collaboration Studio',
      confidence: 1.0,
      type: InsightType.collaboration,
    );
    
    demoService.addInsight(insight);
    demoService.incrementFeatureInteraction('team_collaboration');
    
    setState(() {
      _isSharing = false;
    });
    
    HapticFeedback.heavyImpact();
    _showSuccessDialog();
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
        ),
      ),
    );
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
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
                'Report Shared Successfully!',
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
                '${_selectedTeamMembers.length} team members have been notified and granted $_selectedPermission access.',
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
                  Navigator.of(context).pop(); // Close collaboration studio
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
                    'Continue',
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: AnimatedBuilder(
        animation: Listenable.merge([_heroAnimation, _teamStagger, _activityPulse]),
        builder: (context, child) {
          return SafeArea(
            child: Stack(
              children: [
                // Main content
                Column(
                  children: [
                    _buildCollaborationHeader(theme),
                    Expanded(
                      child: Row(
                        children: [
                          // Team selection panel
                          if (_showTeamPanel)
                            Expanded(
                              flex: 2,
                              child: _buildTeamPanel(theme),
                            ),
                          
                          // Main collaboration area
                          Expanded(
                            flex: 3,
                            child: _buildCollaborationArea(theme),
                          ),
                          
                          // Activity feed panel
                          if (_showActivityFeed)
                            Expanded(
                              flex: 2,
                              child: _buildActivityPanel(theme),
                            ),
                        ],
                      ),
                    ),
                    _buildShareActions(theme),
                  ],
                ),
                
                // Loading overlay
                if (_isSharing)
                  _buildSharingOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCollaborationHeader(ThemeData theme) {
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
        child: Row(
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
                    'Collaboration Studio',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Share insights and collaborate on "${widget.reportData['title']}"',
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
                _buildHeaderAction(
                  _showTeamPanel ? Icons.group_off : Icons.group,
                  'Team',
                  () => setState(() => _showTeamPanel = !_showTeamPanel),
                ),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                _buildHeaderAction(
                  _showActivityFeed ? Icons.timeline : Icons.timeline,
                  'Activity',
                  () => setState(() => _showActivityFeed = !_showActivityFeed),
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
  
  Widget _buildTeamPanel(ThemeData theme) {
    return Transform.translate(
      offset: Offset((1 - _teamStagger.value) * -300, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A202C),
          border: Border(
            right: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // Panel header
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
                    Icons.group,
                    color: const Color(0xFF3B82F6),
                    size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                  Expanded(
                    child: Text(
                      'Team Members',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '${_selectedTeamMembers.length}/${_teamMembers.length}',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            
            // Team members list
            Expanded(
              child: ListView.builder(
                padding: ResponsiveHelper.getContentPadding(context),
                itemCount: _teamMembers.length,
                itemBuilder: (context, index) {
                  final member = _teamMembers[index];
                  final isSelected = _selectedTeamMembers.contains(member.name);
                  
                  return GestureDetector(
                    onTap: () => _toggleTeamMember(member.name),
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
                      ),
                      padding: ResponsiveHelper.getContentPadding(context),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  const Color(0xFF3B82F6).withOpacity(0.2),
                                  const Color(0xFF1E40AF).withOpacity(0.1),
                                ],
                              )
                            : null,
                        color: isSelected ? null : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3B82F6).withOpacity(0.4)
                              : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: ResponsiveHelper.getResponsiveWidth(context, 24),
                                backgroundColor: member.color,
                                child: Text(
                                  member.initials,
                                  style: ResponsiveTheme.responsiveTextStyle(
                                    context,
                                    baseFontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (member.isOnline)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: ResponsiveHelper.getResponsiveWidth(context, 12),
                                    height: ResponsiveHelper.getResponsiveWidth(context, 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF1A202C),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          
                          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: ResponsiveTheme.responsiveTextStyle(
                                    context,
                                    baseFontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 2)),
                                Text(
                                  member.role,
                                  style: ResponsiveTheme.responsiveTextStyle(
                                    context,
                                    baseFontSize: 14,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: const Color(0xFF3B82F6),
                              size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCollaborationArea(ThemeData theme) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Column(
        children: [
          // Report preview
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E293B).withOpacity(0.8),
                    const Color(0xFF0F172A),
                  ],
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Report header
                  Container(
                    padding: ResponsiveHelper.getContentPadding(context),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                        topRight: Radius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                        ),
                        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                        Expanded(
                          child: Text(
                            widget.reportData['title']?.toString() ?? 'Business Report',
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Report content
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share,
                            size: ResponsiveHelper.getIconSize(context, baseSize: 64),
                            color: Colors.white.withOpacity(0.3),
                          ),
                          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                          Text(
                            'Ready to Share',
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                          Text(
                            'Select team members and share with the appropriate permissions',
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
          
          // Permission settings
          Expanded(
            flex: 1,
            child: _buildPermissionSettings(theme),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPermissionSettings(ThemeData theme) {
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
            'Permission Level',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          Row(
            children: _permissionLevels.map((permission) {
              final isSelected = _selectedPermission == permission;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPermission = permission;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: permission == _permissionLevels.last ? 0 : ResponsiveHelper.getAccessibleSpacing(context, 8),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                            )
                          : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      permission[0].toUpperCase() + permission.substring(1),
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityPanel(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A202C),
        border: Border(
          left: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Panel header
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
                AnimatedBuilder(
                  animation: _activityPulse,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _activityPulse.value,
                      child: Icon(
                        Icons.timeline,
                        color: const Color(0xFF10B981),
                        size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                      ),
                    );
                  },
                ),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                Expanded(
                  child: Text(
                    'Recent Activity',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Activity feed
          Expanded(
            child: ListView.builder(
              padding: ResponsiveHelper.getContentPadding(context),
              itemCount: _activityFeed.length,
              itemBuilder: (context, index) {
                final activity = _activityFeed[index];
                return _buildActivityItem(activity);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityItem(ActivityItem activity) {
    final color = _getActivityColor(activity.type);
    final icon = _getActivityIcon(activity.type);
    
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 16),
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
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 8)),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: ResponsiveHelper.getIconSize(context, baseSize: 16),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.user,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 2)),
                Text(
                  activity.action,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                Text(
                  _formatTimestamp(activity.timestamp),
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 10,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.comment:
        return const Color(0xFF3B82F6);
      case ActivityType.edit:
        return const Color(0xFF10B981);
      case ActivityType.share:
        return const Color(0xFF8B5CF6);
      case ActivityType.annotation:
        return const Color(0xFFF59E0B);
      case ActivityType.export:
        return const Color(0xFFEF4444);
    }
  }
  
  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.comment:
        return Icons.chat_bubble;
      case ActivityType.edit:
        return Icons.edit;
      case ActivityType.share:
        return Icons.share;
      case ActivityType.annotation:
        return Icons.note_add;
      case ActivityType.export:
        return Icons.file_download;
    }
  }
  
  Widget _buildShareActions(ThemeData theme) {
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
          // Share info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedTeamMembers.isNotEmpty
                      ? 'Ready to share with ${_selectedTeamMembers.length} team members'
                      : 'Select team members to share with',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                if (_selectedTeamMembers.isNotEmpty)
                  Text(
                    'Permission level: ${_selectedPermission.toUpperCase()}',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          // Share button
          GestureDetector(
            onTap: _selectedTeamMembers.isNotEmpty ? _shareWithTeam : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsiveWidth(context, 32),
                vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
              ),
              decoration: BoxDecoration(
                gradient: _selectedTeamMembers.isNotEmpty
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                      )
                    : null,
                color: _selectedTeamMembers.isEmpty 
                    ? Colors.grey.withOpacity(0.3)
                    : null,
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                boxShadow: _selectedTeamMembers.isNotEmpty ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.share,
                    color: _selectedTeamMembers.isNotEmpty 
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                  Text(
                    'Share Report',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _selectedTeamMembers.isNotEmpty 
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
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
  
  Widget _buildSharingOverlay() {
    return AnimatedBuilder(
      animation: _shareSlide,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.8 * _shareSlide.value),
          child: Center(
            child: Transform.scale(
              scale: _shareSlide.value,
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
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveWidth(context, 60),
                      height: ResponsiveHelper.getResponsiveWidth(context, 60),
                      child: const CircularProgressIndicator(
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
                    
                    Text(
                      'Sharing Report...',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                    
                    Text(
                      'Notifying ${_selectedTeamMembers.length} team members with $_selectedPermission access',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
class TeamMember {
  final String name;
  final String role;
  final String initials;
  final Color color;
  final bool isOnline;

  TeamMember(this.name, this.role, this.initials, this.color, this.isOnline);
}

class ShareMethod {
  final String name;
  final IconData icon;
  final Color color;

  ShareMethod(this.name, this.icon, this.color);
}

class ActivityItem {
  final String id;
  final String user;
  final String action;
  final DateTime timestamp;
  final ActivityType type;

  ActivityItem({
    required this.id,
    required this.user,
    required this.action,
    required this.timestamp,
    required this.type,
  });
}

enum ActivityType {
  comment,
  edit,
  share,
  annotation,
  export,
}