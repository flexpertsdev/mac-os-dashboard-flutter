import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';

class CinematicIntro extends StatefulWidget {
  final VoidCallback onComplete;
  
  const CinematicIntro({
    super.key,
    required this.onComplete,
  });

  @override
  State<CinematicIntro> createState() => _CinematicIntroState();
}

class _CinematicIntroState extends State<CinematicIntro>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _particleAnimation;
  late Animation<Color?> _colorAnimation;
  
  final List<DataParticle> _particles = [];
  final List<String> _aiQuotes = [
    "Analytics aren't just numbers...",
    "They're the language of opportunity.",
    "Every data point tells a story.",
    "Every insight unlocks potential.",
    "Welcome to the future of intelligence.",
  ];
  
  int _currentQuoteIndex = 0;
  bool _showSkipButton = false;

  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _setupAnimations();
    _generateParticles();
    _startSequence();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));
    
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    );
    
    _colorAnimation = ColorTween(
      begin: const Color(0xFF1a1a2e),
      end: const Color(0xFF16213e),
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(DataParticle(
        position: Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 800,
        ),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 100,
          (random.nextDouble() - 0.5) * 100,
        ),
        size: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.8 + 0.2,
        color: _getRandomDataColor(),
        type: DataType.values[random.nextInt(DataType.values.length)],
      ));
    }
  }

  Color _getRandomDataColor() {
    final colors = [
      const Color(0xFF00D4FF), // Cyan
      const Color(0xFF7B68EE), // Purple
      const Color(0xFF32CD32), // Green
      const Color(0xFFFF6B6B), // Red
      const Color(0xFFFFD700), // Gold
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _startSequence() async {
    // Enable skip button after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showSkipButton = true;
        });
      }
    });
    
    // Start background animation
    _backgroundController.repeat(reverse: true);
    
    // Start particle animation
    _particleController.repeat();
    
    // Sequence 1: Fade in background (0-1s)
    await Future.delayed(const Duration(milliseconds: 500));
    _mainController.forward();
    
    // Sequence 2: Show logo with dramatic entrance (1-2s)
    await Future.delayed(const Duration(milliseconds: 800));
    _logoController.forward();
    HapticFeedback.heavyImpact();
    
    // Sequence 3: Start text sequence (2-5s)
    await Future.delayed(const Duration(milliseconds: 1000));
    _startTextSequence();
    
    // Sequence 4: Complete intro (6s)
    await Future.delayed(const Duration(milliseconds: 3500));
    _completeIntro();
  }

  void _startTextSequence() async {
    for (int i = 0; i < _aiQuotes.length && mounted; i++) {
      setState(() {
        _currentQuoteIndex = i;
      });
      
      _textController.forward();
      HapticFeedback.lightImpact();
      
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (i < _aiQuotes.length - 1) {
        _textController.reverse();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  void _completeIntro() {
    HapticFeedback.heavyImpact();
    
    // Dramatic fade out
    _mainController.animateTo(0.0, 
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInCubic,
    ).then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  void _skipIntro() {
    HapticFeedback.mediumImpact();
    _completeIntro();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _particleController,
          _textController,
          _logoController,
          _backgroundController,
        ]),
        builder: (context, child) {
          return Stack(
            children: [
              // Animated background
              Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      _colorAnimation.value ?? const Color(0xFF1a1a2e),
                      const Color(0xFF0f0f1e),
                      Colors.black,
                    ],
                  ),
                ),
              ),
              
              // Particle system
              CustomPaint(
                painter: DataParticlePainter(
                  particles: _particles,
                  animation: _particleAnimation,
                  screenSize: size,
                ),
                size: Size.infinite,
              ),
              
              // Grid overlay effect
              CustomPaint(
                painter: GridOverlayPainter(
                  animation: _mainController,
                  color: Colors.cyan.withOpacity(0.1),
                ),
                size: Size.infinite,
              ),
              
              // Main content
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo section
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 40)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.cyan.withOpacity(0.3),
                                Colors.blue.withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.cyan,
                                  Colors.blue,
                                  Colors.purple,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ).createShader(bounds);
                            },
                            child: Icon(
                              Icons.analytics,
                              size: ResponsiveHelper.getIconSize(context, baseSize: 120),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 40)),
                      
                      // App name with gradient
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                Colors.cyan,
                                Colors.blue,
                                Colors.purple,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'DreamFlow',
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
                      
                      // Animated tagline
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _textController,
                          child: Container(
                            height: ResponsiveHelper.getResponsiveHeight(context, 80),
                            alignment: Alignment.center,
                            child: Text(
                              _currentQuoteIndex < _aiQuotes.length 
                                  ? _aiQuotes[_currentQuoteIndex]
                                  : '',
                              style: ResponsiveTheme.responsiveTextStyle(
                                context,
                                baseFontSize: 18,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 60)),
                      
                      // Loading indicator
                      Transform.scale(
                        scale: _scaleAnimation.value,
                        child: SizedBox(
                          width: ResponsiveHelper.getResponsiveWidth(context, 200),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(seconds: 5),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.cyan,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                minHeight: 4,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Skip button
              if (_showSkipButton)
                Positioned(
                  top: ResponsiveHelper.getResponsiveHeight(context, 60),
                  right: ResponsiveHelper.getResponsiveWidth(context, 30),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: TextButton.icon(
                      onPressed: _skipIntro,
                      icon: const Icon(Icons.skip_next, color: Colors.white70),
                      label: Text(
                        'Skip',
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.3),
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
                          vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            ResponsiveHelper.getResponsiveWidth(context, 20),
                          ),
                        ),
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
}

// Data particle class for the cinematic effect
class DataParticle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  Color color;
  DataType type;
  
  DataParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
    required this.type,
  });
}

enum DataType {
  number,
  chart,
  trend,
  insight,
}

// Custom painter for the data particle system
class DataParticlePainter extends CustomPainter {
  final List<DataParticle> particles;
  final Animation<double> animation;
  final Size screenSize;
  
  DataParticlePainter({
    required this.particles,
    required this.animation,
    required this.screenSize,
  }) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      
      // Update particle position
      particle.position = Offset(
        (particle.position.dx + particle.velocity.dx * 0.02) % screenSize.width,
        (particle.position.dy + particle.velocity.dy * 0.02) % screenSize.height,
      );
      
      // Breathing effect
      final breathing = 0.7 + 0.3 * math.sin(animation.value * 4 * math.pi + i);
      final currentSize = particle.size * breathing;
      final currentOpacity = particle.opacity * breathing * 0.6;
      
      paint.color = particle.color.withOpacity(currentOpacity);
      paint.style = PaintingStyle.fill;
      
      // Draw based on data type
      switch (particle.type) {
        case DataType.number:
          _drawNumber(canvas, paint, particle.position, currentSize);
          break;
        case DataType.chart:
          _drawChart(canvas, paint, particle.position, currentSize);
          break;
        case DataType.trend:
          _drawTrend(canvas, paint, particle.position, currentSize);
          break;
        case DataType.insight:
          _drawInsight(canvas, paint, particle.position, currentSize);
          break;
      }
      
      // Add glow effect
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      paint.color = particle.color.withOpacity(currentOpacity * 0.3);
      canvas.drawCircle(particle.position, currentSize * 2, paint);
      paint.maskFilter = null;
    }
    
    // Draw connection lines between nearby particles
    _drawConnections(canvas);
  }
  
  void _drawNumber(Canvas canvas, Paint paint, Offset position, double size) {
    final rect = Rect.fromCenter(center: position, width: size * 2, height: size * 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size * 0.3)),
      paint,
    );
  }
  
  void _drawChart(Canvas canvas, Paint paint, Offset position, double size) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size * 0.3;
    
    final path = Path();
    path.moveTo(position.dx - size, position.dy + size * 0.5);
    path.lineTo(position.dx - size * 0.3, position.dy - size * 0.2);
    path.lineTo(position.dx + size * 0.3, position.dy + size * 0.3);
    path.lineTo(position.dx + size, position.dy - size * 0.5);
    
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
  }
  
  void _drawTrend(Canvas canvas, Paint paint, Offset position, double size) {
    final path = Path();
    path.moveTo(position.dx - size, position.dy);
    path.lineTo(position.dx, position.dy - size);
    path.lineTo(position.dx + size, position.dy + size * 0.5);
    
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size * 0.4;
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
  }
  
  void _drawInsight(Canvas canvas, Paint paint, Offset position, double size) {
    // Draw lightbulb shape
    canvas.drawCircle(position, size, paint);
    
    final rect = Rect.fromCenter(
      center: Offset(position.dx, position.dy + size * 0.8),
      width: size * 0.6,
      height: size * 0.4,
    );
    canvas.drawRect(rect, paint);
  }
  
  void _drawConnections(Canvas canvas) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final distance = (particles[i].position - particles[j].position).distance;
        if (distance < 80) {
          final opacity = (1 - distance / 80) * 0.2;
          paint.color = Colors.cyan.withOpacity(opacity);
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
  bool shouldRepaint(DataParticlePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

// Grid overlay painter for tech aesthetic
class GridOverlayPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  
  GridOverlayPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1 * animation.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    const gridSize = 50.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(GridOverlayPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}