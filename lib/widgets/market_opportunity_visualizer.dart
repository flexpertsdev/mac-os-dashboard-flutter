import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';

class MarketOpportunityVisualizer extends StatefulWidget {
  const MarketOpportunityVisualizer({super.key});

  @override
  State<MarketOpportunityVisualizer> createState() => _MarketOpportunityVisualizerState();
}

class _MarketOpportunityVisualizerState extends State<MarketOpportunityVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _growthController;
  late AnimationController _pulseController;
  late AnimationController _orbitalController;
  late AnimationController _expansionController;
  
  late Animation<double> _growthAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _orbitalAnimation;
  late Animation<double> _expansionAnimation;
  
  int _selectedMarketIndex = 0;
  bool _isExpanded = false;
  
  final List<MarketOpportunity> _markets = [
    MarketOpportunity(
      name: 'Global Analytics Market',
      tam: 274.3, // Billions
      sam: 89.7,
      som: 12.4,
      growthRate: 23.2,
      color: const Color(0xFF3498DB),
      description: 'Business intelligence and analytics software market',
      keyDrivers: ['Digital Transformation', 'Data-Driven Decisions', 'AI Integration', 'Cloud Adoption'],
      penetration: 0.15,
      timeline: '2024-2029',
    ),
    MarketOpportunity(
      name: 'AI-Powered Business Intelligence',
      tam: 156.8,
      sam: 47.2,
      som: 8.9,
      growthRate: 31.7,
      color: const Color(0xFF9B59B6),
      description: 'Artificial intelligence in business analytics',
      keyDrivers: ['Machine Learning', 'Predictive Analytics', 'Real-time Insights', 'Automation'],
      penetration: 0.08,
      timeline: '2024-2028',
    ),
    MarketOpportunity(
      name: 'Enterprise Dashboard Solutions',
      tam: 98.4,
      sam: 32.1,
      som: 6.7,
      growthRate: 18.9,
      color: const Color(0xFF1ABC9C),
      description: 'Executive and operational dashboard platforms',
      keyDrivers: ['Remote Work', 'Real-time Monitoring', 'Data Visualization', 'Mobile Access'],
      penetration: 0.22,
      timeline: '2024-2027',
    ),
    MarketOpportunity(
      name: 'Collaborative Analytics',
      tam: 67.2,
      sam: 18.9,
      som: 4.1,
      growthRate: 27.4,
      color: const Color(0xFFE74C3C),
      description: 'Team-based data analysis and sharing platforms',
      keyDrivers: ['Team Collaboration', 'Data Democracy', 'Self-Service BI', 'Knowledge Sharing'],
      penetration: 0.12,
      timeline: '2024-2026',
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    
    _growthController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _orbitalController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _setupAnimations();
    _startAnimations();
  }

  @override
  void dispose() {
    _growthController.dispose();
    _pulseController.dispose();
    _orbitalController.dispose();
    _expansionController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _growthAnimation = CurvedAnimation(
      parent: _growthController,
      curve: Curves.easeOutCubic,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _orbitalAnimation = CurvedAnimation(
      parent: _orbitalController,
      curve: Curves.linear,
    );
    
    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.elasticOut,
    );
  }

  void _startAnimations() {
    _growthController.forward();
    _pulseController.repeat(reverse: true);
    _orbitalController.repeat();
  }

  void _selectMarket(int index) {
    if (_selectedMarketIndex == index) return;
    
    setState(() {
      _selectedMarketIndex = index;
    });
    
    HapticFeedback.lightImpact();
    _growthController.forward(from: 0);
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    HapticFeedback.mediumImpact();
    
    if (_isExpanded) {
      _expansionController.forward();
    } else {
      _expansionController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedMarket = _markets[_selectedMarketIndex];
    
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            selectedMarket.color.withOpacity(0.1),
            selectedMarket.color.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 24)),
        border: Border.all(
          color: selectedMarket.color.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: selectedMarket.color.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, selectedMarket),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
          
          _buildMarketSelector(theme),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
          
          _buildVisualization(selectedMarket),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
          
          _buildMetrics(theme, selectedMarket),
          
          if (_isExpanded) ...[
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
            _buildDetailedAnalysis(theme, selectedMarket),
          ],
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          _buildActionButton(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, MarketOpportunity market) {
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
                  gradient: LinearGradient(
                    colors: [market.color, market.color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                  boxShadow: [
                    BoxShadow(
                      color: market.color.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.trending_up,
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
                'Market Opportunity',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Interactive market sizing and growth projections',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        
        IconButton(
          onPressed: _toggleExpansion,
          icon: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.expand_more,
              color: market.color,
              size: ResponsiveHelper.getIconSize(context, baseSize: 24),
            ),
          ),
          style: IconButton.styleFrom(
            backgroundColor: market.color.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketSelector(ThemeData theme) {
    return SizedBox(
      height: ResponsiveHelper.getResponsiveHeight(context, 60),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _markets.length,
        itemBuilder: (context, index) {
          final market = _markets[index];
          final isSelected = index == _selectedMarketIndex;
          
          return GestureDetector(
            onTap: () => _selectMarket(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(
                right: ResponsiveHelper.getAccessibleSpacing(context, 12),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
                vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [market.color, market.color.withOpacity(0.8)],
                      )
                    : null,
                color: isSelected ? null : market.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                border: Border.all(
                  color: market.color.withOpacity(isSelected ? 1.0 : 0.3),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: market.color.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    market.name.split(' ').first,
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : market.color,
                    ),
                  ),
                  Text(
                    '\$${market.tam.toStringAsFixed(1)}B TAM',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 12,
                      color: isSelected ? Colors.white.withOpacity(0.9) : market.color.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVisualization(MarketOpportunity market) {
    return AnimatedBuilder(
      animation: Listenable.merge([_growthAnimation, _orbitalAnimation]),
      builder: (context, child) {
        return Container(
          height: ResponsiveHelper.getResponsiveHeight(context, 250),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // TAM Circle (Largest)
              _buildMarketCircle(
                market.tam,
                market.color.withOpacity(0.2),
                'TAM',
                '\$${market.tam.toStringAsFixed(1)}B',
                1.0,
                0,
              ),
              
              // SAM Circle (Medium)
              _buildMarketCircle(
                market.sam,
                market.color.withOpacity(0.4),
                'SAM',
                '\$${market.sam.toStringAsFixed(1)}B',
                0.7,
                1,
              ),
              
              // SOM Circle (Smallest)
              _buildMarketCircle(
                market.som,
                market.color.withOpacity(0.8),
                'SOM',
                '\$${market.som.toStringAsFixed(1)}B',
                0.4,
                2,
              ),
              
              // Orbital elements
              ...List.generate(5, (index) {
                final angle = (_orbitalAnimation.value * 2 * math.pi) + (index * 2 * math.pi / 5);
                final radius = 80.0 + (index * 10);
                final x = math.cos(angle) * radius;
                final y = math.sin(angle) * radius;
                
                return Positioned(
                  left: 125 + x,
                  top: 125 + y,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: market.color.withOpacity(0.6),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: market.color.withOpacity(0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              
              // Center growth indicator
              Container(
                width: ResponsiveHelper.getResponsiveWidth(context, 80),
                height: ResponsiveHelper.getResponsiveWidth(context, 80),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      market.color,
                      market.color.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: market.color.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${market.growthRate.toStringAsFixed(1)}%',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'CAGR',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 10,
                        color: Colors.white.withOpacity(0.9),
                      ),
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

  Widget _buildMarketCircle(
    double value,
    Color color,
    String label,
    String amount,
    double scale,
    int layer,
  ) {
    final size = ResponsiveHelper.getResponsiveWidth(context, 200) * scale * _growthAnimation.value;
    
    return Positioned(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.8),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (layer == 0) ...[
              Text(
                label,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
              Text(
                amount,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetrics(ThemeData theme, MarketOpportunity market) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            theme,
            'Market Penetration',
            '${(market.penetration * 100).toStringAsFixed(1)}%',
            Icons.donut_large,
            market.color,
          ),
        ),
        
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        Expanded(
          child: _buildMetricCard(
            theme,
            'Growth Timeline',
            market.timeline,
            Icons.schedule,
            market.color,
          ),
        ),
        
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        Expanded(
          child: _buildMetricCard(
            theme,
            'Market Position',
            '#${_selectedMarketIndex + 1}',
            Icons.star,
            market.color,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
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
              baseFontSize: 18,
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
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis(ThemeData theme, MarketOpportunity market) {
    return AnimatedBuilder(
      animation: _expansionAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _expansionAnimation.value,
          child: Opacity(
            opacity: _expansionAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Market Analysis',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                
                Text(
                  market.description,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                
                Text(
                  'Key Growth Drivers',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                
                Wrap(
                  spacing: ResponsiveHelper.getAccessibleSpacing(context, 8),
                  runSpacing: ResponsiveHelper.getAccessibleSpacing(context, 8),
                  children: market.keyDrivers.map((driver) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
                        vertical: ResponsiveHelper.getResponsiveHeight(context, 6),
                      ),
                      decoration: BoxDecoration(
                        color: market.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                        border: Border.all(
                          color: market.color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        driver,
                        style: ResponsiveTheme.responsiveTextStyle(
                          context,
                          baseFontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: market.color,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    final market = _markets[_selectedMarketIndex];
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.heavyImpact();
          
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: ResponsiveHelper.getContentPadding(context),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.surface,
                      market.color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                  border: Border.all(
                    color: market.color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: market.color,
                          size: ResponsiveHelper.getIconSize(context, baseSize: 32),
                        ),
                        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                        Expanded(
                          child: Text(
                            'Investment Opportunity',
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
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
                    
                    Text(
                      'DreamFlow is positioned to capture significant market share in the ${market.name.toLowerCase()} with our innovative approach to business intelligence.',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
                    
                    Container(
                      padding: ResponsiveHelper.getContentPadding(context),
                      decoration: BoxDecoration(
                        color: market.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Target Revenue',
                                style: ResponsiveTheme.responsiveTextStyle(
                                  context,
                                  baseFontSize: 12,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                '\$${(market.som * 0.1).toStringAsFixed(1)}B',
                                style: ResponsiveTheme.responsiveTextStyle(
                                  context,
                                  baseFontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: market.color,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Market Share',
                                style: ResponsiveTheme.responsiveTextStyle(
                                  context,
                                  baseFontSize: 12,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                '${((market.som * 0.1 / market.tam) * 100).toStringAsFixed(1)}%',
                                style: ResponsiveTheme.responsiveTextStyle(
                                  context,
                                  baseFontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: market.color,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Timeline',
                                style: ResponsiveTheme.responsiveTextStyle(
                                  context,
                                  baseFontSize: 12,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                '3-5 Years',
                                style: ResponsiveTheme.responsiveTextStyle(
                                  context,
                                  baseFontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: market.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
                    
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: market.color,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsiveWidth(context, 32),
                          vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
                        ),
                      ),
                      child: const Text('Explore Investment Details'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        icon: const Icon(Icons.rocket_launch),
        label: const Text('Explore Investment Opportunity'),
        style: ElevatedButton.styleFrom(
          backgroundColor: market.color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
          ),
        ),
      ),
    );
  }
}

class MarketOpportunity {
  final String name;
  final double tam; // Total Addressable Market (Billions)
  final double sam; // Serviceable Addressable Market (Billions)
  final double som; // Serviceable Obtainable Market (Billions)
  final double growthRate; // CAGR %
  final Color color;
  final String description;
  final List<String> keyDrivers;
  final double penetration; // Market penetration %
  final String timeline;
  
  MarketOpportunity({
    required this.name,
    required this.tam,
    required this.sam,
    required this.som,
    required this.growthRate,
    required this.color,
    required this.description,
    required this.keyDrivers,
    required this.penetration,
    required this.timeline,
  });
}