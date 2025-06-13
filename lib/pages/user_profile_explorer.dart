import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';
import '../services/demo_session_service.dart';
import '../models/demo_models.dart';

class UserProfileExplorer extends StatefulWidget {
  final Map<String, dynamic> userData;
  
  const UserProfileExplorer({
    super.key,
    required this.userData,
  });

  @override
  State<UserProfileExplorer> createState() => _UserProfileExplorerState();
}

class _UserProfileExplorerState extends State<UserProfileExplorer>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _tabController;
  late AnimationController _statsController;
  
  late Animation<double> _heroAnimation;
  late Animation<double> _tabSlideAnimation;
  late Animation<double> _statsAnimation;
  
  final PageController _pageController = PageController();
  int _currentTab = 0;
  final List<String> _tabs = ['Overview', 'Activity', 'Analytics', 'Settings'];
  
  bool _isEditing = false;
  late Map<String, dynamic> _editableData;

  @override
  void initState() {
    super.initState();
    
    _editableData = Map<String, dynamic>.from(widget.userData);
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _tabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    
    _tabSlideAnimation = CurvedAnimation(
      parent: _tabController,
      curve: Curves.easeOutBack,
    );
    
    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutCubic,
    );
    
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _tabController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _statsController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _tabController.dispose();
    _statsController.dispose();
    _pageController.dispose();
    super.dispose();
  }
  
  void _switchTab(int index) {
    setState(() {
      _currentTab = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    HapticFeedback.lightImpact();
  }
  
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
    HapticFeedback.mediumImpact();
  }
  
  void _saveChanges() async {
    final demoService = context.read<DemoSessionService>();
    
    // Save updated user data
    await demoService.saveUserData(_editableData);
    
    // Add insight for profile update
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Profile Updated',
      description: '${_editableData['name']} updated their profile information.',
      impact: 'Enhanced team collaboration and communication efficiency.',
      discoveredAt: DateTime.now(),
      source: 'User Management System',
      confidence: 0.90,
      type: InsightType.optimization,
    );
    
    demoService.addInsight(insight);
    demoService.incrementFeatureInteraction('profile_update');
    
    setState(() {
      _isEditing = false;
    });
    
    HapticFeedback.heavyImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            const Text('Profile updated successfully!'),
          ],
        ),
        backgroundColor: const Color(0xFF2ECC71),
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
      backgroundColor: const Color(0xFF0A0E1A),
      body: AnimatedBuilder(
        animation: Listenable.merge([_heroAnimation, _tabSlideAnimation]),
        builder: (context, child) {
          return SafeArea(
            child: Column(
              children: [
                _buildHeroHeader(theme),
                _buildTabNavigation(theme),
                Expanded(
                  child: _buildTabContent(theme),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHeroHeader(ThemeData theme) {
    return Transform.translate(
      offset: Offset(0, (1 - _heroAnimation.value) * -100),
      child: Opacity(
        opacity: _heroAnimation.value,
        child: Container(
          padding: ResponsiveHelper.getContentPadding(context),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E3A8A).withOpacity(0.8),
                const Color(0xFF3B82F6).withOpacity(0.6),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            children: [
              // Top navigation
              Row(
                children: [
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
                  
                  const Spacer(),
                  
                  GestureDetector(
                    onTap: _toggleEditMode,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
                        vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
                      ),
                      decoration: BoxDecoration(
                        gradient: _isEditing
                            ? const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                        border: Border.all(
                          color: _isEditing 
                              ? Colors.transparent 
                              : Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isEditing ? Icons.save : Icons.edit,
                            color: Colors.white,
                            size: ResponsiveHelper.getIconSize(context, baseSize: 18),
                          ),
                          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                          Text(
                            _isEditing ? 'Save' : 'Edit',
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_isEditing) ...[
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                    GestureDetector(
                      onTap: _saveChanges,
                      child: Container(
                        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                          ),
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
              
              // Profile hero section
              Row(
                children: [
                  // Avatar with glow effect
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: ResponsiveHelper.getResponsiveWidth(context, 50),
                      backgroundColor: const Color(0xFF3B82F6),
                      child: Text(
                        _getInitials(_editableData['name']?.toString() ?? 'UN'),
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 20)),
                  
                  // Basic info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isEditing
                            ? _buildEditableField(
                                'name',
                                _editableData['name']?.toString() ?? '',
                                'Full Name',
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              )
                            : Text(
                                _editableData['name']?.toString() ?? 'Unknown User',
                                style: ResponsiveTheme.responsiveTextStyle(
                                  context,
                                  baseFontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                        
                        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                        
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
                                vertical: ResponsiveHelper.getResponsiveHeight(context, 6),
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                                ),
                                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                              ),
                              child: Text(
                                _editableData['role']?.toString() ?? 'Unknown Role',
                                style: ResponsiveTheme.responsiveTextStyle(
                                  context,
                                  baseFontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            
                            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                            
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
                                vertical: ResponsiveHelper.getResponsiveHeight(context, 6),
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                                ),
                                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                              ),
                              child: Text(
                                _editableData['department']?.toString() ?? 'Unknown Dept',
                                style: ResponsiveTheme.responsiveTextStyle(
                                  context,
                                  baseFontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                        
                        _isEditing
                            ? _buildEditableField(
                                'email',
                                _editableData['email']?.toString() ?? '',
                                'Email Address',
                                fontSize: 16,
                                opacity: 0.8,
                              )
                            : Text(
                                _editableData['email']?.toString() ?? 'no-email@company.com',
                                style: ResponsiveTheme.responsiveTextStyle(
                                  context,
                                  baseFontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
              
              // Quick stats
              _buildQuickStats(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildQuickStats() {
    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _statsAnimation.value) * 50),
          child: Opacity(
            opacity: _statsAnimation.value,
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Projects',
                    '${(math.Random().nextInt(15) + 5)}',
                    Icons.assignment,
                    const Color(0xFF10B981),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                Expanded(
                  child: _buildStatCard(
                    'Tasks Done',
                    '${(math.Random().nextInt(50) + 20)}',
                    Icons.check_circle,
                    const Color(0xFF3B82F6),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                Expanded(
                  child: _buildStatCard(
                    'Team Score',
                    '${(math.Random().nextInt(20) + 80)}%',
                    Icons.trending_up,
                    const Color(0xFF8B5CF6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
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
  
  Widget _buildTabNavigation(ThemeData theme) {
    return Transform.translate(
      offset: Offset(0, (1 - _tabSlideAnimation.value) * 100),
      child: Container(
        margin: ResponsiveHelper.getContentPadding(context),
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 8)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: _tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isActive = _currentTab == index;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => _switchTab(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
                  ),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                    boxShadow: isActive ? [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: Text(
                    tab,
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildTabContent(ThemeData theme) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentTab = index;
        });
      },
      children: [
        _buildOverviewTab(),
        _buildActivityTab(),
        _buildAnalyticsTab(),
        _buildSettingsTab(),
      ],
    );
  }
  
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About section
          _buildSectionCard(
            'About',
            Icons.info,
            const Color(0xFF3B82F6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Join Date', _formatDate(_editableData['startDate'])),
                _buildInfoRow('Employee ID', 'EMP${DateTime.now().millisecondsSinceEpoch % 10000}'),
                _buildInfoRow('Status', _editableData['isActive'] == true ? 'Active' : 'Inactive'),
                _buildInfoRow('Manager', 'Sarah Chen'),
                _buildInfoRow('Location', 'San Francisco, CA'),
              ],
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
          
          // Skills section
          _buildSectionCard(
            'Skills & Expertise',
            Icons.star,
            const Color(0xFF8B5CF6),
            Wrap(
              spacing: ResponsiveHelper.getAccessibleSpacing(context, 8),
              runSpacing: ResponsiveHelper.getAccessibleSpacing(context, 8),
              children: [
                'Data Analysis', 'Python', 'SQL', 'Tableau', 'Machine Learning',
                'Statistics', 'R', 'Excel', 'Power BI'
              ].map((skill) => Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
                  vertical: ResponsiveHelper.getResponsiveHeight(context, 6),
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                ),
                child: Text(
                  skill,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              )).toList(),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
          
          // Recent achievements
          _buildSectionCard(
            'Recent Achievements',
            Icons.military_tech,
            const Color(0xFF10B981),
            Column(
              children: [
                _buildAchievementItem(
                  'Q3 Analytics Champion',
                  'Delivered exceptional insights for revenue optimization',
                  const Color(0xFF10B981),
                ),
                _buildAchievementItem(
                  'Team Collaboration Award',
                  'Outstanding cross-department collaboration',
                  const Color(0xFF3B82F6),
                ),
                _buildAchievementItem(
                  'Innovation Spotlight',
                  'Implemented ML model improving efficiency by 25%',
                  const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Column(
        children: [
          // Activity timeline
          _buildSectionCard(
            'Recent Activity',
            Icons.timeline,
            const Color(0xFF06B6D4),
            Column(
              children: [
                _buildActivityItem(
                  'Updated Revenue Dashboard',
                  '2 hours ago',
                  Icons.dashboard,
                  const Color(0xFF3B82F6),
                ),
                _buildActivityItem(
                  'Completed Data Analysis Report',
                  '5 hours ago',
                  Icons.analytics,
                  const Color(0xFF10B981),
                ),
                _buildActivityItem(
                  'Team Meeting - Q4 Planning',
                  '1 day ago',
                  Icons.group,
                  const Color(0xFF8B5CF6),
                ),
                _buildActivityItem(
                  'Submitted Expense Report',
                  '2 days ago',
                  Icons.receipt,
                  const Color(0xFFF59E0B),
                ),
                _buildActivityItem(
                  'Joined Machine Learning Workshop',
                  '3 days ago',
                  Icons.school,
                  const Color(0xFFEF4444),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Column(
        children: [
          // Performance metrics
          _buildSectionCard(
            'Performance Analytics',
            Icons.trending_up,
            const Color(0xFF10B981),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard('Productivity', '94%', const Color(0xFF10B981)),
                    ),
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                    Expanded(
                      child: _buildMetricCard('Quality Score', '4.8/5', const Color(0xFF3B82F6)),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard('Team Rating', '4.9/5', const Color(0xFF8B5CF6)),
                    ),
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                    Expanded(
                      child: _buildMetricCard('On-time Delivery', '98%', const Color(0xFFF59E0B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
          
          // Goals tracking
          _buildSectionCard(
            'Goals & Objectives',
            Icons.track_changes,
            const Color(0xFF8B5CF6),
            Column(
              children: [
                _buildGoalItem('Complete Data Science Certification', 85),
                _buildGoalItem('Lead Cross-team Analytics Project', 60),
                _buildGoalItem('Mentor 2 Junior Analysts', 100),
                _buildGoalItem('Implement ML Pipeline', 45),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Column(
        children: [
          // Account settings
          _buildSectionCard(
            'Account Settings',
            Icons.settings,
            const Color(0xFF6B7280),
            Column(
              children: [
                _buildSettingItem('Email Notifications', true),
                _buildSettingItem('Desktop Notifications', false),
                _buildSettingItem('Team Updates', true),
                _buildSettingItem('Weekly Reports', true),
                _buildSettingItem('Mobile Alerts', false),
              ],
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
          
          // Privacy settings
          _buildSectionCard(
            'Privacy & Security',
            Icons.security,
            const Color(0xFFEF4444),
            Column(
              children: [
                _buildActionItem('Change Password', Icons.lock, () {}),
                _buildActionItem('Two-Factor Authentication', Icons.security, () {}),
                _buildActionItem('Privacy Settings', Icons.privacy_tip, () {}),
                _buildActionItem('Download Data', Icons.download, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionCard(String title, IconData icon, Color color, Widget content) {
    return Container(
      width: double.infinity,
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
              Text(
                title,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          content,
        ],
      ),
    );
  }
  
  Widget _buildEditableField(
    String key,
    String value,
    String hint, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    double opacity = 1.0,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      onChanged: (newValue) {
        setState(() {
          _editableData[key] = newValue;
        });
      },
      style: ResponsiveTheme.responsiveTextStyle(
        context,
        baseFontSize: fontSize,
        fontWeight: fontWeight,
        color: Colors.white.withOpacity(opacity),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: ResponsiveTheme.responsiveTextStyle(
          context,
          baseFontSize: fontSize,
          color: Colors.white.withOpacity(0.5),
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF3B82F6),
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementItem(String title, String description, Color color) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
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
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
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
                  title,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                Text(
                  description,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 12,
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
  
  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
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
              size: ResponsiveHelper.getIconSize(context, baseSize: 16),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                Text(
                  time,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 12,
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
  
  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 24,
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
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalItem(String goal, int progress) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goal,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '$progress%',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 4)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingItem(String title, bool value) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 14,
              color: Colors.white,
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.lightImpact();
              // Handle setting change
            },
            activeColor: const Color(0xFF10B981),
            inactiveThumbColor: Colors.white.withOpacity(0.6),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionItem(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
        ),
        padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: ResponsiveHelper.getIconSize(context, baseSize: 20),
            ),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
            Expanded(
              child: Text(
                title,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.4),
              size: ResponsiveHelper.getIconSize(context, baseSize: 16),
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
  
  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return date.toString();
  }
}