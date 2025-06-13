import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';

class RevenueModelPlayground extends StatefulWidget {
  const RevenueModelPlayground({super.key});

  @override
  State<RevenueModelPlayground> createState() => _RevenueModelPlaygroundState();
}

class _RevenueModelPlaygroundState extends State<RevenueModelPlayground>
    with TickerProviderStateMixin {
  late AnimationController _growthController;
  late AnimationController _chartController;
  late AnimationController _counterController;
  
  late Animation<double> _growthAnimation;
  late Animation<double> _chartAnimation;
  late Animation<double> _counterAnimation;
  
  // Revenue model parameters
  double _customerCount = 50;
  double _averageRevenuePerUser = 2500;
  double _monthlyGrowthRate = 15.0;
  double _churnRate = 5.0;
  double _customerAcquisitionCost = 500;
  int _timeHorizon = 36; // months
  
  // Calculated metrics
  RevenueProjection? _projection;
  bool _isCalculating = false;
  
  @override
  void initState() {
    super.initState();
    
    _growthController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _growthAnimation = CurvedAnimation(
      parent: _growthController,
      curve: Curves.easeOutCubic,
    );
    
    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutBack,
    );
    
    _counterAnimation = CurvedAnimation(
      parent: _counterController,
      curve: Curves.easeOut,
    );
    
    _calculateProjection();
  }

  @override
  void dispose() {
    _growthController.dispose();
    _chartController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  void _calculateProjection() {
    setState(() {
      _isCalculating = true;
    });
    
    _counterController.forward(from: 0);
    
    // Simulate calculation delay for dramatic effect
    Future.delayed(const Duration(milliseconds: 800), () {
      final projection = RevenueProjection.calculate(
        initialCustomers: _customerCount,
        arpu: _averageRevenuePerUser,
        monthlyGrowthRate: _monthlyGrowthRate / 100,
        churnRate: _churnRate / 100,
        cac: _customerAcquisitionCost,
        timeHorizonMonths: _timeHorizon,
      );
      
      setState(() {
        _projection = projection;
        _isCalculating = false;
      });
      
      _growthController.forward(from: 0);
      _chartController.forward(from: 0);
      
      HapticFeedback.lightImpact();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1ABC9C).withOpacity(0.1),
            const Color(0xFF3498DB).withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 24)),
        border: Border.all(
          color: const Color(0xFF1ABC9C).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1ABC9C).withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
          
          _buildParameterControls(theme),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
          
          if (_isCalculating) 
            _buildCalculatingState(theme)
          else if (_projection != null)
            _buildProjectionResults(theme),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
          
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1ABC9C), Color(0xFF3498DB)],
            ),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1ABC9C).withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.calculate,
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
                'Revenue Model Playground',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Interactive revenue projections and scenario modeling',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 14,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
            vertical: ResponsiveHelper.getResponsiveHeight(context, 6),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1ABC9C).withOpacity(0.2),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
          ),
          child: Text(
            'Live Model',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1ABC9C),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParameterControls(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model Parameters',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        Wrap(
          spacing: ResponsiveHelper.getAccessibleSpacing(context, 16),
          runSpacing: ResponsiveHelper.getAccessibleSpacing(context, 16),
          children: [
            _buildParameterSlider(
              'Initial Customers',
              _customerCount,
              0,
              500,
              (value) {
                setState(() {
                  _customerCount = value;
                });
                _calculateProjection();
              },
              format: (value) => '${value.toInt()}',
              color: const Color(0xFF3498DB),
            ),
            
            _buildParameterSlider(
              'ARPU (Monthly)',
              _averageRevenuePerUser,
              500,
              10000,
              (value) {
                setState(() {
                  _averageRevenuePerUser = value;
                });
                _calculateProjection();
              },
              format: (value) => '\$${value.toInt()}',
              color: const Color(0xFF1ABC9C),
            ),
            
            _buildParameterSlider(
              'Growth Rate (%)',
              _monthlyGrowthRate,
              0,
              50,
              (value) {
                setState(() {
                  _monthlyGrowthRate = value;
                });
                _calculateProjection();
              },
              format: (value) => '${value.toStringAsFixed(1)}%',
              color: const Color(0xFF2ECC71),
            ),
            
            _buildParameterSlider(
              'Churn Rate (%)',
              _churnRate,
              0,
              25,
              (value) {
                setState(() {
                  _churnRate = value;
                });
                _calculateProjection();
              },
              format: (value) => '${value.toStringAsFixed(1)}%',
              color: const Color(0xFFE74C3C),
            ),
            
            _buildParameterSlider(
              'CAC',
              _customerAcquisitionCost,
              100,
              2000,
              (value) {
                setState(() {
                  _customerAcquisitionCost = value;
                });
                _calculateProjection();
              },
              format: (value) => '\$${value.toInt()}',
              color: const Color(0xFF9B59B6),
            ),
            
            _buildParameterSlider(
              'Time Horizon (Months)',
              _timeHorizon.toDouble(),
              12,
              60,
              (value) {
                setState(() {
                  _timeHorizon = value.toInt();
                });
                _calculateProjection();
              },
              format: (value) => '${value.toInt()}mo',
              color: const Color(0xFFF39C12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildParameterSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    required String Function(double) format,
    required Color color,
  }) {
    return Container(
      width: ResponsiveHelper.isMobile(context) 
          ? double.infinity 
          : ResponsiveHelper.getResponsiveWidth(context, 300),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getResponsiveWidth(context, 8),
                  vertical: ResponsiveHelper.getResponsiveHeight(context, 4),
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
                ),
                child: Text(
                  format(value),
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
          
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.3),
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: (newValue) {
                HapticFeedback.lightImpact();
                onChanged(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatingState(ThemeData theme) {
    return AnimatedBuilder(
      animation: _counterAnimation,
      builder: (context, child) {
        return Container(
          height: ResponsiveHelper.getResponsiveHeight(context, 200),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveWidth(context, 80),
                      height: ResponsiveHelper.getResponsiveWidth(context, 80),
                      child: CircularProgressIndicator(
                        value: _counterAnimation.value,
                        strokeWidth: 6,
                        backgroundColor: const Color(0xFF1ABC9C).withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1ABC9C)),
                      ),
                    ),
                    Icon(
                      Icons.calculate,
                      size: ResponsiveHelper.getIconSize(context, baseSize: 40),
                      color: const Color(0xFF1ABC9C),
                    ),
                  ],
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                
                Text(
                  'Calculating Revenue Model...',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1ABC9C),
                  ),
                ),
                
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                
                Text(
                  'Analyzing ${(_counterAnimation.value * 100).toInt()}% complete',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectionResults(ThemeData theme) {
    if (_projection == null) return const SizedBox();
    
    return AnimatedBuilder(
      animation: Listenable.merge([_growthAnimation, _chartAnimation]),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue Projections',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            
            // Key metrics row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Revenue',
                    _formatCurrency(_projection!.totalRevenue * _growthAnimation.value),
                    Icons.monetization_on,
                    const Color(0xFF1ABC9C),
                  ),
                ),
                
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                
                Expanded(
                  child: _buildMetricCard(
                    'Customer LTV',
                    _formatCurrency(_projection!.averageCustomerLTV * _growthAnimation.value),
                    Icons.person_add,
                    const Color(0xFF3498DB),
                  ),
                ),
                
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                
                Expanded(
                  child: _buildMetricCard(
                    'ROI',
                    '${(_projection!.roi * _growthAnimation.value * 100).toStringAsFixed(0)}%',
                    Icons.trending_up,
                    const Color(0xFF2ECC71),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
            
            // Revenue chart
            Container(
              height: ResponsiveHelper.getResponsiveHeight(context, 200),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1ABC9C).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                border: Border.all(
                  color: const Color(0xFF1ABC9C).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: CustomPaint(
                painter: RevenueChartPainter(
                  projection: _projection!,
                  animation: _chartAnimation,
                  primaryColor: const Color(0xFF1ABC9C),
                ),
                size: Size.infinite,
              ),
            ),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            
            // Scenario insights
            _buildScenarioInsights(theme),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
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
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioInsights(ThemeData theme) {
    if (_projection == null) return const SizedBox();
    
    final insights = [
      if (_projection!.roi > 300)
        'Exceptional ROI potential - ${(_projection!.roi * 100).toStringAsFixed(0)}% return',
      if (_projection!.averageCustomerLTV > _customerAcquisitionCost * 3)
        'Strong unit economics with ${(_projection!.averageCustomerLTV / _customerAcquisitionCost).toStringAsFixed(1)}:1 LTV:CAC ratio',
      if (_monthlyGrowthRate > 20)
        'Aggressive growth trajectory - reaching \$${(_projection!.totalRevenue / 1000000).toStringAsFixed(1)}M ARR',
      'Projected to acquire ${_projection!.totalCustomersAdded.toInt()} new customers',
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Insights',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
        
        ...insights.map((insight) {
          return Container(
            margin: EdgeInsets.only(
              bottom: ResponsiveHelper.getAccessibleSpacing(context, 8),
            ),
            padding: ResponsiveHelper.getContentPadding(context),
            decoration: BoxDecoration(
              color: const Color(0xFF1ABC9C).withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
              border: Border.all(
                color: const Color(0xFF1ABC9C).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: const Color(0xFF1ABC9C),
                  size: ResponsiveHelper.getIconSize(context, baseSize: 16),
                ),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                Expanded(
                  child: Text(
                    insight,
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Reset to defaults
              setState(() {
                _customerCount = 50;
                _averageRevenuePerUser = 2500;
                _monthlyGrowthRate = 15.0;
                _churnRate = 5.0;
                _customerAcquisitionCost = 500;
                _timeHorizon = 36;
              });
              _calculateProjection();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.2),
              foregroundColor: theme.colorScheme.onSurface,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
              ),
            ),
          ),
        ),
        
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
        
        Expanded(
          flex: 2,
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
                          const Color(0xFF1ABC9C).withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                      border: Border.all(
                        color: const Color(0xFF1ABC9C).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Investment Summary',
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        
                        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
                        
                        if (_projection != null) ...[
                          Text(
                            'Based on current model parameters, DreamFlow projects:',
                            style: ResponsiveTheme.responsiveTextStyle(
                              context,
                              baseFontSize: 16,
                              color: theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
                          
                          Container(
                            padding: ResponsiveHelper.getContentPadding(context),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1ABC9C).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow('Total Revenue', _formatCurrency(_projection!.totalRevenue)),
                                _buildSummaryRow('ROI', '${(_projection!.roi * 100).toStringAsFixed(0)}%'),
                                _buildSummaryRow('Customer LTV', _formatCurrency(_projection!.averageCustomerLTV)),
                                _buildSummaryRow('Total Customers', '${(_customerCount + _projection!.totalCustomersAdded).toInt()}'),
                              ],
                            ),
                          ),
                        ],
                        
                        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
                        
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1ABC9C),
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
            icon: const Icon(Icons.assessment),
            label: const Text('View Investment Summary'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1ABC9C),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1ABC9C),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }
}

class RevenueProjection {
  final double totalRevenue;
  final double totalCustomersAdded;
  final double averageCustomerLTV;
  final double roi;
  final List<MonthlyData> monthlyData;
  
  RevenueProjection({
    required this.totalRevenue,
    required this.totalCustomersAdded,
    required this.averageCustomerLTV,
    required this.roi,
    required this.monthlyData,
  });
  
  static RevenueProjection calculate({
    required double initialCustomers,
    required double arpu,
    required double monthlyGrowthRate,
    required double churnRate,
    required double cac,
    required int timeHorizonMonths,
  }) {
    final monthlyData = <MonthlyData>[];
    double customers = initialCustomers;
    double totalRevenue = 0;
    double totalInvestment = initialCustomers * cac;
    
    for (int month = 1; month <= timeHorizonMonths; month++) {
      // Calculate customer growth
      final newCustomers = customers * monthlyGrowthRate;
      final churnedCustomers = customers * churnRate;
      customers = customers + newCustomers - churnedCustomers;
      
      // Calculate revenue
      final monthlyRevenue = customers * arpu;
      totalRevenue += monthlyRevenue;
      
      // Calculate costs
      final acquisitionCost = newCustomers * cac;
      totalInvestment += acquisitionCost;
      
      monthlyData.add(MonthlyData(
        month: month,
        customers: customers,
        revenue: monthlyRevenue,
        cumulativeRevenue: totalRevenue,
      ));
    }
    
    final totalCustomersAdded = customers - initialCustomers;
    final averageCustomerLTV = totalRevenue / (initialCustomers + totalCustomersAdded);
    final roi = (totalRevenue - totalInvestment) / totalInvestment;
    
    return RevenueProjection(
      totalRevenue: totalRevenue,
      totalCustomersAdded: totalCustomersAdded,
      averageCustomerLTV: averageCustomerLTV,
      roi: roi,
      monthlyData: monthlyData,
    );
  }
}

class MonthlyData {
  final int month;
  final double customers;
  final double revenue;
  final double cumulativeRevenue;
  
  MonthlyData({
    required this.month,
    required this.customers,
    required this.revenue,
    required this.cumulativeRevenue,
  });
}

class RevenueChartPainter extends CustomPainter {
  final RevenueProjection projection;
  final Animation<double> animation;
  final Color primaryColor;
  
  RevenueChartPainter({
    required this.projection,
    required this.animation,
    required this.primaryColor,
  }) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.3),
          primaryColor.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    if (projection.monthlyData.isEmpty) return;
    
    final maxRevenue = projection.monthlyData
        .map((d) => d.cumulativeRevenue)
        .reduce(math.max);
    
    final path = Path();
    final fillPath = Path();
    
    for (int i = 0; i < projection.monthlyData.length; i++) {
      final progress = animation.value;
      if (i / projection.monthlyData.length > progress) break;
      
      final data = projection.monthlyData[i];
      final x = (i / (projection.monthlyData.length - 1)) * size.width;
      final y = size.height - (data.cumulativeRevenue / maxRevenue) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    // Complete the fill path
    final lastDataIndex = (projection.monthlyData.length * animation.value).floor();
    if (lastDataIndex > 0) {
      final lastX = ((lastDataIndex - 1) / (projection.monthlyData.length - 1)) * size.width;
      fillPath.lineTo(lastX, size.height);
      fillPath.close();
    }
    
    // Draw fill
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw line
    canvas.drawPath(path, paint);
    
    // Draw data points
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < projection.monthlyData.length; i++) {
      final progress = animation.value;
      if (i / projection.monthlyData.length > progress) break;
      
      final data = projection.monthlyData[i];
      final x = (i / (projection.monthlyData.length - 1)) * size.width;
      final y = size.height - (data.cumulativeRevenue / maxRevenue) * size.height;
      
      canvas.drawCircle(
        Offset(x, y),
        4,
        paint..color = primaryColor,
      );
    }
  }
  
  @override
  bool shouldRepaint(RevenueChartPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}