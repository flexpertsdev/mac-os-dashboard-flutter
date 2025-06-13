import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/demo_models.dart';
import '../services/demo_session_service.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';

class AIInsightEngine extends StatefulWidget {
  const AIInsightEngine({super.key});

  @override
  State<AIInsightEngine> createState() => _AIInsightEngineState();
}

class _AIInsightEngineState extends State<AIInsightEngine>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _revealsController;
  late AnimationController _particleController;
  
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _revealsAnimation;
  late Animation<double> _particleAnimation;
  
  bool _isScanning = false;
  bool _showInsights = false;
  final List<InsightParticle> _brainParticles = [];
  
  @override
  void initState() {
    super.initState();
    
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _revealsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );
    
    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _revealsAnimation = CurvedAnimation(
      parent: _revealsController,
      curve: Curves.easeOutCubic,
    );
    
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    );
    
    _generateBrainParticles();
    _startIdleAnimation();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _revealsController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _generateBrainParticles() {
    final random = math.Random();
    for (int i = 0; i < 30; i++) {
      _brainParticles.add(InsightParticle(
        position: Offset(
          random.nextDouble() * 300,
          random.nextDouble() * 200,
        ),
        velocity: Offset(
          (random.nextDouble() - 0.5) * 0.5,
          (random.nextDouble() - 0.5) * 0.5,
        ),
        size: random.nextDouble() * 3 + 1,
        opacity: random.nextDouble() * 0.6 + 0.2,
        color: _getInsightColor(),
        type: InsightParticleType.values[random.nextInt(InsightParticleType.values.length)],
      ));
    }
  }

  Color _getInsightColor() {
    final colors = [
      const Color(0xFF9B59B6), // Purple
      const Color(0xFF3498DB), // Blue
      const Color(0xFF1ABC9C), // Teal
      const Color(0xFFE74C3C), // Red
      const Color(0xFFF39C12), // Orange
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _startIdleAnimation() {
    _pulseController.repeat(reverse: true);
    _particleController.repeat();
  }

  Future<void> _triggerAIScan() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _showInsights = false;
    });
    
    HapticFeedback.mediumImpact();
    
    // Start scanning animation
    _scanController.forward(from: 0);
    
    // Wait for scan to complete
    await Future.delayed(const Duration(milliseconds: 3000));
    
    // Generate insights
    final demoService = context.read<DemoSessionService>();
    final insights = _generateAIInsights(demoService);
    
    // Add insights to service
    for (final insight in insights) {
      demoService.addInsight(insight);
    }
    
    // Show results
    setState(() {
      _showInsights = true;
      _isScanning = false;
    });
    
    _revealsController.forward(from: 0);
    HapticFeedback.heavyImpact();
    
    // Increment interaction
    demoService.incrementFeatureInteraction('ai_insights');
  }

  List<DemoInsight> _generateAIInsights(DemoSessionService demoService) {
    final scenario = demoService.currentSession?.selectedScenario;
    final role = demoService.currentSession?.selectedRole;
    final insights = <DemoInsight>[];
    
    // Generate role and scenario-specific insights
    final insightTemplates = _getInsightTemplates(scenario, role);
    final random = math.Random();
    
    for (int i = 0; i < 3; i++) {
      final template = insightTemplates[random.nextInt(insightTemplates.length)];
      insights.add(DemoInsight(
        id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
        title: template['title']!,
        description: template['description']!,
        impact: template['impact']!,
        discoveredAt: DateTime.now(),
        source: 'AI Insight Engine',
        confidence: 0.75 + random.nextDouble() * 0.2,
        type: template['type'] as InsightType,
      ));
    }
    
    return insights;
  }

  List<Map<String, dynamic>> _getInsightTemplates(BusinessScenario? scenario, UserRole? role) {
    if (scenario == null || role == null) return [];
    
    final templates = <Map<String, dynamic>>[];
    
    // Scenario-specific insights
    switch (scenario) {
      case BusinessScenario.ecommerce:
        templates.addAll([
          {
            'title': 'Cart Abandonment Optimization Opportunity',
            'description': 'AI detected a 23% reduction potential in cart abandonment through personalized exit-intent campaigns targeting users who spend >3 minutes on checkout.',
            'impact': 'Potential revenue increase of \$180K monthly',
            'type': InsightType.opportunity,
          },
          {
            'title': 'Seasonal Inventory Prediction',
            'description': 'Predictive models show 34% higher demand for premium products in Q4. Current inventory levels suggest potential stockouts.',
            'impact': 'Risk of \$420K in lost sales without inventory adjustment',
            'type': InsightType.risk,
          },
          {
            'title': 'Customer Lifetime Value Correlation',
            'description': 'Strong correlation (0.89) found between first-purchase discount percentage and long-term customer value. Optimal discount: 15-20%.',
            'impact': '28% improvement in customer retention',
            'type': InsightType.correlation,
          },
        ]);
        break;
        
      case BusinessScenario.saasGrowth:
        templates.addAll([
          {
            'title': 'Churn Prediction Model Alert',
            'description': 'AI identified 127 customers at high risk of churning (probability >85%) based on decreased feature usage and support ticket patterns.',
            'impact': 'Preventing churn could save \$890K in annual revenue',
            'type': InsightType.risk,
          },
          {
            'title': 'Feature Adoption Acceleration',
            'description': 'Users who engage with the new collaboration feature within 7 days show 67% higher retention. Onboarding optimization recommended.',
            'impact': '45% reduction in customer acquisition cost',
            'type': InsightType.opportunity,
          },
          {
            'title': 'Pricing Elasticity Discovery',
            'description': 'Market analysis reveals 23% price increase tolerance for premium tier without significant churn impact.',
            'impact': 'Potential ARR increase of \$2.1M',
            'type': InsightType.opportunity,
          },
        ]);
        break;
        
      case BusinessScenario.fintech:
        templates.addAll([
          {
            'title': 'Fraud Pattern Recognition',
            'description': 'Advanced ML detected new fraud pattern with 94% accuracy. 12 suspicious transactions flagged for review in last hour.',
            'impact': 'Prevented potential losses of \$45K',
            'type': InsightType.anomaly,
          },
          {
            'title': 'Portfolio Optimization Signal',
            'description': 'Quantitative analysis suggests reallocating 8% from growth to value stocks based on current market volatility indicators.',
            'impact': 'Potential 12% risk reduction with similar returns',
            'type': InsightType.opportunity,
          },
          {
            'title': 'Regulatory Compliance Trend',
            'description': 'New regulatory patterns detected. 23 similar firms received warnings for similar activities in past 30 days.',
            'impact': 'Proactive compliance adjustment recommended',
            'type': InsightType.trend,
          },
        ]);
        break;
        
      default:
        templates.addAll([
          {
            'title': 'Performance Optimization',
            'description': 'AI analysis reveals optimization opportunities in current operations.',
            'impact': 'Significant improvement potential identified',
            'type': InsightType.opportunity,
          },
        ]);
    }
    
    // Role-specific insights
    switch (role) {
      case UserRole.ceo:
        templates.addAll([
          {
            'title': 'Strategic Growth Vector',
            'description': 'Market expansion analysis shows 67% success probability for entering adjacent market segments with current capabilities.',
            'impact': 'Potential 3x revenue growth over 24 months',
            'type': InsightType.opportunity,
          },
          {
            'title': 'Competitive Intelligence Alert',
            'description': 'Competitor analysis indicates market share vulnerability in key demographics. Immediate strategic response recommended.',
            'impact': 'Risk of 15% market share loss without action',
            'type': InsightType.risk,
          },
        ]);
        break;
        
      case UserRole.dataAnalyst:
        templates.addAll([
          {
            'title': 'Data Quality Anomaly Detected',
            'description': 'Statistical analysis reveals data quality issues in Customer_ID field affecting 3.2% of records. Pattern suggests system integration bug.',
            'impact': 'Could affect accuracy of customer analytics',
            'type': InsightType.anomaly,
          },
          {
            'title': 'Correlation Discovery',
            'description': 'Unexpected correlation (r=0.73) found between weather patterns and user engagement. Geographic segmentation recommended.',
            'impact': 'Potential 18% improvement in engagement predictions',
            'type': InsightType.correlation,
          },
        ]);
        break;
        
      case UserRole.investor:
        templates.addAll([
          {
            'title': 'Investment Performance Projection',
            'description': 'Current trajectory analysis indicates 127% ROI potential over 18 months based on market validation metrics.',
            'impact': 'Strong investment thesis validation',
            'type': InsightType.opportunity,
          },
          {
            'title': 'Market Timing Analysis',
            'description': 'Competitive landscape and adoption curve analysis suggests optimal market entry window closing in Q2.',
            'impact': 'Strategic timing advantage diminishing',
            'type': InsightType.trend,
          },
        ]);
        break;
        
      default:
        break;
    }
    
    return templates;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<DemoSessionService>(
      builder: (context, demoService, child) {
        final insights = demoService.insights.take(3).toList();
        
        return Container(
          padding: ResponsiveHelper.getContentPadding(context),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF9B59B6).withOpacity(0.1),
                const Color(0xFF3498DB).withOpacity(0.05),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
            border: Border.all(
              color: const Color(0xFF9B59B6).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
              
              if (_isScanning) _buildScanningInterface(),
              
              if (_showInsights && insights.isNotEmpty) 
                _buildInsightsList(insights, theme),
              
              if (!_isScanning && !_showInsights)
                _buildIdleState(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9B59B6), Color(0xFF3498DB)],
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9B59B6).withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: ResponsiveHelper.getIconSize(context, baseSize: 32),
                ),
              ),
            );
          },
        ),
        
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Insight Engine',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Discovering patterns and opportunities in real-time',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        
        ElevatedButton.icon(
          onPressed: _isScanning ? null : _triggerAIScan,
          icon: _isScanning 
              ? SizedBox(
                  width: ResponsiveHelper.getIconSize(context, baseSize: 16),
                  height: ResponsiveHelper.getIconSize(context, baseSize: 16),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.auto_fix_high),
          label: Text(_isScanning ? 'Scanning...' : 'Generate Insights'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9B59B6),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveWidth(context, 20),
              vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningInterface() {
    return AnimatedBuilder(
      animation: Listenable.merge([_scanAnimation, _particleAnimation]),
      builder: (context, child) {
        return Container(
          height: ResponsiveHelper.getResponsiveHeight(context, 200),
          child: Stack(
            children: [
              // Background particle system
              CustomPaint(
                painter: BrainParticlePainter(
                  particles: _brainParticles,
                  animation: _particleAnimation,
                  primaryColor: const Color(0xFF9B59B6),
                ),
                size: Size.infinite,
              ),
              
              // Scanning overlay
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Scanning circles
                        for (int i = 0; i < 3; i++)
                          Transform.scale(
                            scale: 1 + i * 0.3 + _scanAnimation.value * 0.5,
                            child: Container(
                              width: ResponsiveHelper.getResponsiveWidth(context, 60),
                              height: ResponsiveHelper.getResponsiveWidth(context, 60),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF9B59B6).withOpacity(0.3 - i * 0.1),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        
                        // Central brain icon
                        Icon(
                          Icons.psychology,
                          size: ResponsiveHelper.getIconSize(context, baseSize: 40),
                          color: const Color(0xFF9B59B6),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                    
                    Text(
                      'AI analyzing patterns...',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9B59B6),
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                    
                    LinearProgressIndicator(
                      value: _scanAnimation.value,
                      backgroundColor: const Color(0xFF9B59B6).withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightsList(List<DemoInsight> insights, ThemeData theme) {
    return AnimatedBuilder(
      animation: _revealsAnimation,
      builder: (context, child) {
        return Column(
          children: insights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value;
            final delay = index * 0.2;
            final progress = (_revealsAnimation.value - delay).clamp(0.0, 1.0);
            
            return Transform.translate(
              offset: Offset(0, (1 - progress) * 50),
              child: Opacity(
                opacity: progress,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: ResponsiveHelper.getAccessibleSpacing(context, 16),
                  ),
                  padding: ResponsiveHelper.getContentPadding(context),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        insight.type.color.withOpacity(0.1),
                        insight.type.color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                    border: Border.all(
                      color: insight.type.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            insight.type.icon,
                            color: insight.type.color,
                            size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                          ),
                          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                          Expanded(
                            child: Text(
                              insight.title,
                              style: ResponsiveTheme.responsiveTextStyle(
                                context,
                                baseFontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveHelper.getResponsiveWidth(context, 8),
                              vertical: ResponsiveHelper.getResponsiveHeight(context, 4),
                            ),
                            decoration: BoxDecoration(
                              color: insight.type.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
                            ),
                            child: Text(
                              '${(insight.confidence * 100).toInt()}%',
                              style: ResponsiveTheme.responsiveTextStyle(
                                context,
                                baseFontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: insight.type.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                      
                      Text(
                        insight.description,
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          height: 1.4,
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: ResponsiveHelper.getIconSize(context, baseSize: 16),
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                          Expanded(
                            child: Text(
                              insight.impact,
                              style: ResponsiveTheme.responsiveTextStyle(
                                context,
                                baseFontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildIdleState(ThemeData theme) {
    return Container(
      height: ResponsiveHelper.getResponsiveHeight(context, 120),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_fix_high,
              size: ResponsiveHelper.getIconSize(context, baseSize: 48),
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
            Text(
              'Click "Generate Insights" to discover AI-powered opportunities',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Insight particle for brain visualization
class InsightParticle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  Color color;
  InsightParticleType type;
  
  InsightParticle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
    required this.type,
  });
}

enum InsightParticleType {
  neuron,
  synapse,
  thought,
  connection,
}

// Brain particle painter for AI visualization
class BrainParticlePainter extends CustomPainter {
  final List<InsightParticle> particles;
  final Animation<double> animation;
  final Color primaryColor;
  
  BrainParticlePainter({
    required this.particles,
    required this.animation,
    required this.primaryColor,
  }) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      
      // Update position
      particle.position = Offset(
        (particle.position.dx + particle.velocity.dx) % size.width,
        (particle.position.dy + particle.velocity.dy) % size.height,
      );
      
      // Pulsing effect
      final pulse = 0.7 + 0.3 * math.sin(animation.value * 2 * math.pi + i);
      final currentOpacity = particle.opacity * pulse;
      
      paint.color = particle.color.withOpacity(currentOpacity);
      paint.style = PaintingStyle.fill;
      
      // Draw based on type
      switch (particle.type) {
        case InsightParticleType.neuron:
          canvas.drawCircle(particle.position, particle.size * pulse, paint);
          break;
        case InsightParticleType.synapse:
          _drawSynapse(canvas, paint, particle.position, particle.size * pulse);
          break;
        case InsightParticleType.thought:
          _drawThought(canvas, paint, particle.position, particle.size * pulse);
          break;
        case InsightParticleType.connection:
          _drawConnection(canvas, paint, particle.position, particle.size * pulse);
          break;
      }
    }
    
    // Draw neural connections
    _drawNeuralNetwork(canvas, size);
  }
  
  void _drawSynapse(Canvas canvas, Paint paint, Offset position, double size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: position, width: size * 2, height: size * 0.5),
      Radius.circular(size * 0.25),
    );
    canvas.drawRRect(rect, paint);
  }
  
  void _drawThought(Canvas canvas, Paint paint, Offset position, double size) {
    // Draw cloud-like shape
    for (int i = 0; i < 5; i++) {
      final angle = i * 2 * math.pi / 5;
      final offset = Offset(
        position.dx + math.cos(angle) * size * 0.7,
        position.dy + math.sin(angle) * size * 0.7,
      );
      canvas.drawCircle(offset, size * 0.4, paint);
    }
  }
  
  void _drawConnection(Canvas canvas, Paint paint, Offset position, double size) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = size * 0.3;
    
    final path = Path();
    path.moveTo(position.dx - size, position.dy);
    path.quadraticBezierTo(
      position.dx,
      position.dy - size,
      position.dx + size,
      position.dy,
    );
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
  }
  
  void _drawNeuralNetwork(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = primaryColor.withOpacity(0.1);
    
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
  bool shouldRepaint(BrainParticlePainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}