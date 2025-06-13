import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/demo_models.dart';
import '../services/demo_session_service.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';
import 'main_layout.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentStep = 0;
  UserRole? _selectedRole;
  BusinessScenario? _selectedScenario;
  
  final List<OnboardingStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _initializeSteps();
    _startAnimations();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeSteps() {
    _steps.addAll([
      OnboardingStep(
        title: 'Welcome to DreamFlow',
        subtitle: 'The Future of Analytics',
        description: 'Experience next-generation business intelligence with AI-powered insights, real-time analytics, and collaborative decision-making.',
        icon: Icons.rocket_launch,
        color: const Color(0xFF007AFF),
        builder: _buildWelcomeStep,
      ),
      OnboardingStep(
        title: 'Choose Your Role',
        subtitle: 'Personalized Experience',
        description: 'Select your role to customize the dashboard and insights specifically for your needs and responsibilities.',
        icon: Icons.person,
        color: const Color(0xFF34C759),
        builder: _buildRoleSelectionStep,
      ),
      OnboardingStep(
        title: 'Select Your Scenario',
        subtitle: 'Industry-Specific Demo',
        description: 'Choose a business scenario to see how DreamFlow transforms analytics for your industry with realistic data and insights.',
        icon: Icons.business,
        color: const Color(0xFFFF9500),
        builder: _buildScenarioSelectionStep,
      ),
      OnboardingStep(
        title: 'Ready to Explore',
        subtitle: 'Interactive Demo Awaits',
        description: 'Your personalized analytics environment is ready. Explore real-time dashboards, AI insights, and collaborative tools.',
        icon: Icons.explore,
        color: const Color(0xFFAF52DE),
        builder: _buildReadyStep,
      ),
    ]);
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _restartAnimations();
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      _restartAnimations();
    }
  }

  void _restartAnimations() {
    _fadeController.reset();
    _slideController.reset();
    Future.delayed(const Duration(milliseconds: 100), () {
      _startAnimations();
    });
  }

  Future<void> _completeOnboarding() async {
    if (_selectedRole != null && _selectedScenario != null) {
      final demoService = context.read<DemoSessionService>();
      await demoService.startNewSession(_selectedRole!, _selectedScenario!);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainLayout(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  itemCount: _steps.length,
                  itemBuilder: (context, index) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _steps[index].builder(context, _nextStep),
                      ),
                    );
                  },
                ),
              ),
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                ),
                child: Icon(
                  Icons.analytics,
                  color: theme.colorScheme.primary,
                  size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                ),
              ),
              SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
              Text(
                'DreamFlow',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          _buildProgressIndicator(theme),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Row(
      children: List.generate(_steps.length, (index) {
        final isActive = index <= _currentStep;
        final isCurrent = index == _currentStep;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveWidth(context, 4),
          ),
          width: isCurrent 
              ? ResponsiveHelper.getResponsiveWidth(context, 32)
              : ResponsiveHelper.getResponsiveWidth(context, 8),
          height: ResponsiveHelper.getResponsiveHeight(context, 8),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 4)),
          ),
        );
      }),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: _previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            )
          else
            const SizedBox(),
          
          ElevatedButton.icon(
            onPressed: _canProceed() ? _nextStep : null,
            icon: Icon(_currentStep == _steps.length - 1 ? Icons.rocket_launch : Icons.arrow_forward),
            label: Text(_currentStep == _steps.length - 1 ? 'Launch Demo' : 'Continue'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsiveWidth(context, 24),
                vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
      case 3:
        return true;
      case 1:
        return _selectedRole != null;
      case 2:
        return _selectedScenario != null;
      default:
        return false;
    }
  }

  Widget _buildWelcomeStep(BuildContext context, VoidCallback onNext) {
    final theme = Theme.of(context);
    
    return Center(
      child: ResponsiveTheme.responsiveContainer(
        context: context,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 32)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.rocket_launch,
                      size: ResponsiveHelper.getIconSize(context, baseSize: 64),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
            
            Text(
              _steps[0].title,
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            
            Text(
              _steps[0].subtitle,
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 18,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
            
            Text(
              _steps[0].description,
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelectionStep(BuildContext context, VoidCallback onNext) {
    final theme = Theme.of(context);
    
    return Center(
      child: ResponsiveTheme.responsiveContainer(
        context: context,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _steps[1].title,
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            
            Text(
              _steps[1].description,
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
            
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                  childAspectRatio: ResponsiveHelper.isMobile(context) ? 3.5 : 2.5,
                  crossAxisSpacing: ResponsiveHelper.getCardSpacing(context),
                  mainAxisSpacing: ResponsiveHelper.getCardSpacing(context),
                ),
                itemCount: UserRole.values.length,
                itemBuilder: (context, index) {
                  final role = UserRole.values[index];
                  final isSelected = _selectedRole == role;
                  
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: _buildRoleCard(role, isSelected, theme),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(UserRole role, bool isSelected, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected 
            ? role.color.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
        border: Border.all(
          color: isSelected 
              ? role.color
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: role.color.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedRole = role;
            });
          },
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
          child: Padding(
            padding: ResponsiveHelper.getContentPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
                      decoration: BoxDecoration(
                        color: role.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                      ),
                      child: Icon(
                        role.icon,
                        color: role.color,
                        size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: role.color,
                        size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                      ),
                  ],
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                
                Text(
                  role.title,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                
                Expanded(
                  child: Text(
                    role.description,
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScenarioSelectionStep(BuildContext context, VoidCallback onNext) {
    final theme = Theme.of(context);
    
    return Center(
      child: ResponsiveTheme.responsiveContainer(
        context: context,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _steps[2].title,
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            
            Text(
              _steps[2].description,
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
            
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
                  childAspectRatio: ResponsiveHelper.isMobile(context) ? 2.5 : 1.8,
                  crossAxisSpacing: ResponsiveHelper.getCardSpacing(context),
                  mainAxisSpacing: ResponsiveHelper.getCardSpacing(context),
                ),
                itemCount: BusinessScenario.values.length,
                itemBuilder: (context, index) {
                  final scenario = BusinessScenario.values[index];
                  final isSelected = _selectedScenario == scenario;
                  
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: _buildScenarioCard(scenario, isSelected, theme),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioCard(BusinessScenario scenario, bool isSelected, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected 
            ? scenario.color.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
        border: Border.all(
          color: isSelected 
              ? scenario.color
              : theme.colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: scenario.color.withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedScenario = scenario;
            });
          },
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
          child: Padding(
            padding: ResponsiveHelper.getContentPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
                      decoration: BoxDecoration(
                        color: scenario.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                      ),
                      child: Icon(
                        scenario.icon,
                        color: scenario.color,
                        size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: scenario.color,
                        size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                      ),
                  ],
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                
                Text(
                  scenario.title,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                
                Text(
                  scenario.subtitle,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                
                Wrap(
                  spacing: ResponsiveHelper.getAccessibleSpacing(context, 8),
                  runSpacing: ResponsiveHelper.getAccessibleSpacing(context, 4),
                  children: scenario.keyFeatures.take(3).map((feature) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getResponsiveWidth(context, 8),
                        vertical: ResponsiveHelper.getResponsiveHeight(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: scenario.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
                      ),
                      child: Text(
                        feature,
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 12,
                          color: scenario.color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadyStep(BuildContext context, VoidCallback onNext) {
    final theme = Theme.of(context);
    
    return Center(
      child: ResponsiveTheme.responsiveContainer(
        context: context,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 24)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _selectedRole?.color ?? theme.colorScheme.primary,
                          _selectedScenario?.color ?? theme.colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.explore,
                      size: ResponsiveHelper.getIconSize(context, baseSize: 48),
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
            
            Text(
              'Your Demo is Ready!',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            
            if (_selectedRole != null && _selectedScenario != null)
              Container(
                padding: ResponsiveHelper.getContentPadding(context),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedRole!.icon,
                          color: _selectedRole!.color,
                          size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                        ),
                        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                        Expanded(
                          child: Text(
                            _selectedRole!.title,
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                    
                    Row(
                      children: [
                        Icon(
                          _selectedScenario!.icon,
                          color: _selectedScenario!.color,
                          size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                        ),
                        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                        Expanded(
                          child: Text(
                            _selectedScenario!.title,
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
            
            Text(
              'Experience AI-powered analytics, real-time insights, and collaborative features tailored for your role and industry.',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}