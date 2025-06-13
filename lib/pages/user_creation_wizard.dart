import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';
import '../services/demo_session_service.dart';
import '../models/demo_models.dart';

class UserCreationWizard extends StatefulWidget {
  const UserCreationWizard({super.key});

  @override
  State<UserCreationWizard> createState() => _UserCreationWizardState();
}

class _UserCreationWizardState extends State<UserCreationWizard>
    with TickerProviderStateMixin {
  late AnimationController _pageController;
  late AnimationController _particleController;
  late AnimationController _progressController;
  
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  
  final PageController _stepController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;
  
  // User data
  final Map<String, dynamic> _userData = {
    'name': '',
    'email': '',
    'role': 'Analyst',
    'department': 'Analytics',
    'avatar': '',
    'permissions': <String>[],
    'startDate': DateTime.now(),
    'isActive': true,
  };
  
  final List<String> _availableRoles = [
    'Executive', 'Manager', 'Analyst', 'Specialist', 'Intern'
  ];
  
  final List<String> _availableDepartments = [
    'Analytics', 'Sales', 'Marketing', 'Operations', 'Finance', 'HR', 'IT'
  ];
  
  final List<String> _availablePermissions = [
    'View Dashboards', 'Edit Reports', 'Manage Users', 'Export Data',
    'Admin Access', 'API Access', 'Billing Access'
  ];

  @override
  void initState() {
    super.initState();
    
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeIn,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    
    _pageController.forward();
    _updateProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _particleController.dispose();
    _progressController.dispose();
    _stepController.dispose();
    super.dispose();
  }
  
  void _updateProgress() {
    _progressController.reset();
    _progressController.forward();
  }
  
  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _stepController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
      HapticFeedback.lightImpact();
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _stepController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
      HapticFeedback.lightImpact();
    }
  }
  
  void _completeWizard() async {
    final demoService = context.read<DemoSessionService>();
    
    // Add insights for user creation
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Team Member Added',
      description: 'Successfully onboarded ${_userData['name']} to the ${_userData['department']} team.',
      impact: 'Team capacity increased by 15%. Expected productivity boost in ${_userData['department']} analytics.',
      discoveredAt: DateTime.now(),
      source: 'User Management System',
      confidence: 0.95,
      type: InsightType.achievement,
    );
    
    demoService.addInsight(insight);
    demoService.incrementFeatureInteraction('user_creation');
    
    // Save user data to local storage via demo service
    await demoService.saveUserData(_userData);
    
    HapticFeedback.heavyImpact();
    
    // Show success animation then navigate back
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
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_slideAnimation, _fadeAnimation]),
        builder: (context, child) {
          return Stack(
            children: [
              // Animated background with particles
              _buildAnimatedBackground(),
              
              // Main content
              Transform.translate(
                offset: Offset(_slideAnimation.value * MediaQuery.of(context).size.width, 0),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: SafeArea(
                    child: Column(
                      children: [
                        _buildHeader(theme),
                        _buildProgressIndicator(theme),
                        Expanded(
                          child: _buildStepContent(theme),
                        ),
                        _buildNavigationButtons(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticleBackgroundPainter(
            animation: _particleController,
            color: const Color(0xFF00D4FF),
          ),
          size: Size.infinite,
        );
      },
    );
  }
  
  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Row(
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
          
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Team Member',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Building the future of analytics together',
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
                colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
            ),
            child: Text(
              'Step ${_currentStep + 1} of $_totalSteps',
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
    );
  }
  
  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      margin: ResponsiveHelper.getContentPadding(context),
      height: ResponsiveHelper.getResponsiveHeight(context, 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveHeight(context, 4)),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          final progress = (_currentStep + _progressAnimation.value) / _totalSteps;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00D4FF),
                  const Color(0xFF0099CC),
                  const Color(0xFF00D4FF),
                ],
                stops: [0.0, progress * 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveHeight(context, 4)),
            ),
            width: MediaQuery.of(context).size.width * progress,
          );
        },
      ),
    );
  }
  
  Widget _buildStepContent(ThemeData theme) {
    return PageView(
      controller: _stepController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildPersonalInfoStep(theme),
        _buildRoleSelectionStep(theme),
        _buildPermissionsStep(theme),
        _buildConfirmationStep(theme),
      ],
    );
  }
  
  Widget _buildPersonalInfoStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
          
          Text(
            'Personal Information',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
          
          Text(
            'Let\'s start with the basics. We\'ll create a beautiful profile.',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 40)),
          
          // Avatar selection
          Center(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                // Avatar selection logic here
              },
              child: Container(
                width: ResponsiveHelper.getResponsiveWidth(context, 120),
                height: ResponsiveHelper.getResponsiveWidth(context, 120),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                  size: ResponsiveHelper.getIconSize(context, baseSize: 48),
                ),
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 40)),
          
          // Name field
          _buildGlowingTextField(
            'Full Name',
            'Enter team member\'s full name',
            Icons.person,
            (value) => _userData['name'] = value,
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
          
          // Email field
          _buildGlowingTextField(
            'Email Address',
            'Enter professional email address',
            Icons.email,
            (value) => _userData['email'] = value,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
  
  Widget _buildRoleSelectionStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
          
          Text(
            'Role & Department',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
          
          Text(
            'Define their position and team alignment for optimal collaboration.',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 40)),
          
          // Role selection
          Text(
            'Role',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          Wrap(
            spacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
            runSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
            children: _availableRoles.map((role) {
              final isSelected = _userData['role'] == role;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _userData['role'] = role;
                  });
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsiveWidth(context, 20),
                    vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 25)),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent 
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: Text(
                    role,
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
          
          // Department selection
          Text(
            'Department',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          Wrap(
            spacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
            runSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
            children: _availableDepartments.map((department) {
              final isSelected = _userData['department'] == department;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _userData['department'] = department;
                  });
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getResponsiveWidth(context, 20),
                    vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 25)),
                    border: Border.all(
                      color: isSelected 
                          ? Colors.transparent 
                          : Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: Text(
                    department,
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
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
  
  Widget _buildPermissionsStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
          
          Text(
            'Access Permissions',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
          
          Text(
            'Configure what this team member can access and manage.',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 40)),
          
          ..._availablePermissions.map((permission) {
            final isSelected = (_userData['permissions'] as List<String>).contains(permission);
            return Container(
              margin: EdgeInsets.only(
                bottom: ResponsiveHelper.getAccessibleSpacing(context, 16),
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    final permissions = _userData['permissions'] as List<String>;
                    if (isSelected) {
                      permissions.remove(permission);
                    } else {
                      permissions.add(permission);
                    }
                  });
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: ResponsiveHelper.getContentPadding(context),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              const Color(0xFF00D4FF).withOpacity(0.2),
                              const Color(0xFF0099CC).withOpacity(0.1),
                            ],
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF00D4FF).withOpacity(0.5)
                          : Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: ResponsiveHelper.getResponsiveWidth(context, 24),
                        height: ResponsiveHelper.getResponsiveWidth(context, 24),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                                )
                              : null,
                          color: isSelected ? null : Colors.transparent,
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 4)),
                          border: Border.all(
                            color: isSelected 
                                ? Colors.transparent 
                                : Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: ResponsiveHelper.getIconSize(context, baseSize: 16),
                              )
                            : null,
                      ),
                      
                      SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                      
                      Expanded(
                        child: Text(
                          permission,
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 16,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildConfirmationStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
          
          Text(
            'Review & Confirm',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
          
          Text(
            'Everything looks good? Let\'s welcome your new team member!',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 40)),
          
          // Summary card
          Container(
            padding: ResponsiveHelper.getContentPadding(context),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
              border: Border.all(
                color: const Color(0xFF00D4FF).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Avatar and basic info
                Row(
                  children: [
                    Container(
                      width: ResponsiveHelper.getResponsiveWidth(context, 80),
                      height: ResponsiveHelper.getResponsiveWidth(context, 80),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: ResponsiveHelper.getIconSize(context, baseSize: 40),
                      ),
                    ),
                    
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userData['name'].toString().isEmpty 
                                ? 'New Team Member' 
                                : _userData['name'].toString(),
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                          Text(
                            _userData['email'].toString().isEmpty 
                                ? 'email@company.com' 
                                : _userData['email'].toString(),
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
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
                
                // Role and department
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoTile('Role', _userData['role'].toString()),
                    ),
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                    Expanded(
                      child: _buildInfoTile('Department', _userData['department'].toString()),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                
                // Permissions count
                _buildInfoTile(
                  'Permissions', 
                  '${(_userData['permissions'] as List<String>).length} access levels granted',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoTile(String label, String value) {
    return Container(
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
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
  
  Widget _buildGlowingTextField(
    String label,
    String hint,
    IconData icon,
    ValueChanged<String> onChanged, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: TextField(
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 16,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 16,
                color: Colors.white.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                icon,
                color: const Color(0xFF00D4FF),
                size: ResponsiveHelper.getIconSize(context, baseSize: 24),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                borderSide: const BorderSide(
                  color: Color(0xFF00D4FF),
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsiveWidth(context, 20),
                vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNavigationButtons(ThemeData theme) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: GestureDetector(
                onTap: _previousStep,
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
                        Icons.arrow_back,
                        color: Colors.white,
                        size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                      ),
                      SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                      Text(
                        'Previous',
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
          
          if (_currentStep > 0)
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _currentStep == _totalSteps - 1 ? _completeWizard : _nextStep,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep == _totalSteps - 1 ? 'Create Team Member' : 'Continue',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                    Icon(
                      _currentStep == _totalSteps - 1 ? Icons.check : Icons.arrow_forward,
                      color: Colors.white,
                      size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: ResponsiveHelper.getContentPadding(context),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
          ),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D4FF).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.celebration,
              size: ResponsiveHelper.getIconSize(context, baseSize: 64),
              color: Colors.white,
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            Text(
              'Welcome to the Team!',
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
              '${_userData['name']} has been successfully added to the ${_userData['department']} team.',
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
                Navigator.of(context).pop(); // Close wizard
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
                  'Continue to Dashboard',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00D4FF),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticleBackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  
  ParticleBackgroundPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 50; i++) {
      final progress = (animation.value + i * 0.02) % 1.0;
      final x = (math.sin(i * 0.5 + animation.value * 2) * 0.3 + 0.5) * size.width;
      final y = progress * size.height;
      final radius = math.sin(i * 0.7 + animation.value * 3) * 2 + 3;
      
      paint.color = color.withOpacity(0.1 * (1 - progress));
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(ParticleBackgroundPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}