import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/demo_models.dart';
import '../services/demo_session_service.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';

class KPITheaterCard extends StatefulWidget {
  final ScenarioMetric metric;
  final bool isLarge;

  const KPITheaterCard({
    super.key,
    required this.metric,
    this.isLarge = false,
  });

  @override
  State<KPITheaterCard> createState() => _KPITheaterCardState();
}

class _KPITheaterCardState extends State<KPITheaterCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _countController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _countAnimation;
  late Animation<double> _glowAnimation;
  
  bool _isHovered = false;
  double _displayValue = 0;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _countController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutCubic,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    // Pulse animation (continuous)
    _pulseController.repeat(reverse: true);
    
    // Glow animation (continuous)
    _glowController.repeat(reverse: true);
    
    // Count up animation
    _countController.forward();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  Color get _primaryColor {
    // Color based on trend and metric type
    if (widget.metric.isPositiveTrend) {
      return const Color(0xFF34C759); // Green for positive
    } else {
      return const Color(0xFFFF9500); // Orange for negative
    }
  }

  Color get _backgroundColor {
    return _primaryColor.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _countAnimation, _glowAnimation]),
      builder: (context, child) {
        _displayValue = widget.metric.value * _countAnimation.value;
        
        return Transform.scale(
          scale: _isHovered ? 1.02 : _pulseAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: Container(
              height: widget.isLarge 
                  ? ResponsiveHelper.getResponsiveHeight(context, 180)
                  : ResponsiveHelper.getResponsiveHeight(context, 140),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _backgroundColor,
                    _backgroundColor.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                border: Border.all(
                  color: _primaryColor.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _primaryColor.withOpacity(0.2 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showDetailedView(context),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                  child: Container(
                    padding: ResponsiveHelper.getContentPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme),
                        const Spacer(),
                        _buildValue(theme),
                        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                        _buildTrend(theme),
                        const Spacer(),
                        _buildFooter(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 8)),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
          ),
          child: Icon(
            _getMetricIcon(),
            color: _primaryColor,
            size: ResponsiveHelper.getIconSize(context, baseSize: widget.isLarge ? 24 : 20),
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveWidth(context, 8),
            vertical: ResponsiveHelper.getResponsiveHeight(context, 4),
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
          ),
          child: Text(
            widget.metric.category,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 10,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValue(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 100),
          tween: Tween(begin: _displayValue, end: _displayValue),
          builder: (context, value, child) {
            return Text(
              _formatDisplayValue(value),
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: widget.isLarge ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
        Text(
          widget.metric.name,
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: widget.isLarge ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTrend(ThemeData theme) {
    final changePercent = widget.metric.changePercentage;
    final isPositive = changePercent > 0;
    final trendColor = isPositive ? const Color(0xFF34C759) : const Color(0xFFFF3B30);
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveWidth(context, 8),
            vertical: ResponsiveHelper.getResponsiveHeight(context, 4),
          ),
          decoration: BoxDecoration(
            color: trendColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: trendColor,
                size: ResponsiveHelper.getResponsiveWidth(context, 14),
              ),
              SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 4)),
              Text(
                '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: trendColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
        Expanded(
          child: Text(
            'vs last period',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 10,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: ResponsiveHelper.getResponsiveWidth(context, 4),
          height: ResponsiveHelper.getResponsiveWidth(context, 4),
          decoration: BoxDecoration(
            color: _primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 6)),
        Text(
          'Live data',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 10,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const Spacer(),
        Icon(
          Icons.more_horiz,
          color: theme.colorScheme.onSurface.withOpacity(0.3),
          size: ResponsiveHelper.getResponsiveWidth(context, 16),
        ),
      ],
    );
  }

  IconData _getMetricIcon() {
    final metricName = widget.metric.name.toLowerCase();
    
    if (metricName.contains('revenue') || metricName.contains('value')) {
      return Icons.monetization_on;
    } else if (metricName.contains('user') || metricName.contains('customer')) {
      return Icons.people;
    } else if (metricName.contains('conversion') || metricName.contains('rate')) {
      return Icons.trending_up;
    } else if (metricName.contains('efficiency') || metricName.contains('performance')) {
      return Icons.speed;
    } else if (metricName.contains('cost')) {
      return Icons.payments;
    } else if (metricName.contains('satisfaction') || metricName.contains('quality')) {
      return Icons.star;
    } else if (metricName.contains('time')) {
      return Icons.schedule;
    } else {
      return Icons.analytics;
    }
  }

  String _formatDisplayValue(double value) {
    if (widget.metric.unit == '%') {
      return '${value.toStringAsFixed(1)}%';
    } else if (widget.metric.unit == '\$') {
      if (value >= 1000000) {
        return '\$${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '\$${(value / 1000).toStringAsFixed(1)}K';
      } else {
        return '\$${value.toStringAsFixed(0)}';
      }
    } else if (widget.metric.unit == 'min') {
      return '${value.toStringAsFixed(1)}m';
    } else {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      } else {
        return value.toStringAsFixed(0);
      }
    }
  }

  void _showDetailedView(BuildContext context) {
    final demoService = context.read<DemoSessionService>();
    demoService.incrementFeatureInteraction('dashboard_overview');
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: ResponsiveHelper.getResponsiveWidth(context, 400),
          padding: ResponsiveHelper.getContentPadding(context),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    _getMetricIcon(),
                    color: _primaryColor,
                    size: ResponsiveHelper.getIconSize(context, baseSize: 32),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                  Expanded(
                    child: Text(
                      widget.metric.name,
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
              
              Container(
                padding: ResponsiveHelper.getContentPadding(context),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current Value',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                    Text(
                      widget.metric.formattedValue,
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                    _buildTrend(Theme.of(context)),
                  ],
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
              
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Navigate to detailed analytics
                },
                icon: const Icon(Icons.analytics),
                label: const Text('View Detailed Analytics'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Particle data class for the particle system
class ParticleData {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  Color color;
  
  ParticleData({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
  });
}

// Custom painter for particle effects
class ParticlePainter extends CustomPainter {
  final List<ParticleData> particles;
  final Animation<double> animation;
  final Color primaryColor;
  
  ParticlePainter({
    required this.particles,
    required this.animation,
    required this.primaryColor,
  }) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      
      // Update particle position
      particle.position = Offset(
        (particle.position.dx + particle.velocity.dx) % size.width,
        (particle.position.dy + particle.velocity.dy) % size.height,
      );
      
      // Fade effect based on animation
      final opacity = particle.opacity * (0.3 + 0.7 * math.sin(animation.value * 2 * math.pi + i));
      
      paint.color = particle.color.withOpacity(opacity.clamp(0.0, 1.0));
      paint.style = PaintingStyle.fill;
      
      // Draw particle with glow effect
      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );
      
      // Draw glow
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(
        particle.position,
        particle.size * 1.5,
        paint,
      );
      paint.maskFilter = null;
    }
    
    // Draw connecting lines between nearby particles
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.5;
    
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final distance = (particles[i].position - particles[j].position).distance;
        if (distance < 60) {
          final opacity = (1 - distance / 60) * 0.3;
          paint.color = primaryColor.withOpacity(opacity);
          canvas.drawLine(
            particles[i].position,
            particles[j].position,
            paint,
          );
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}