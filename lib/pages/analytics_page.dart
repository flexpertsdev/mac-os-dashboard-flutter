import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';
import '../utils/responsive_helper.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedMetric = 'Revenue';
  String _selectedPeriod = 'Daily';
  // bool _isLoading = false; // TODO: Implement loading state

  final List<String> _availableMetrics = [
    'Revenue', 'Users', 'Sessions', 'Conversion Rate', 'Bounce Rate'
  ];

  final List<String> _availablePeriods = [
    'Daily', 'Weekly', 'Monthly', 'Quarterly'
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getContentPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme),
                  const SizedBox(height: 24),
                  _buildFilters(context, theme, isMobile),
                  const SizedBox(height: 24),
                  _buildMetricsOverview(context, theme),
                  const SizedBox(height: 24),
                  _buildChartsSection(context, theme, isMobile),
                  const SizedBox(height: 24),
                  _buildDetailedAnalytics(context, theme, isMobile),
                  const SizedBox(height: 100), // Bottom padding for mobile
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.analytics,
            color: theme.colorScheme.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Advanced Analytics',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Deep dive into your data with interactive charts and insights',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _exportData,
          icon: Icon(
            Icons.download,
            color: theme.colorScheme.primary,
          ),
          tooltip: 'Export Data',
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, ThemeData theme, bool isMobile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.filter_list,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filters & Date Range',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isMobile) ...[
              _buildMobileFilters(context, theme),
            ] else ...[
              _buildDesktopFilters(context, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFilters(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildDateRangeButton(context, theme)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricDropdown(context, theme)),
          ],
        ),
        const SizedBox(height: 12),
        _buildPeriodDropdown(context, theme),
      ],
    );
  }

  Widget _buildDesktopFilters(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildDateRangeButton(context, theme)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricDropdown(context, theme)),
        const SizedBox(width: 16),
        Expanded(child: _buildPeriodDropdown(context, theme)),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _applyFilters,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeButton(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () => _selectDateRange(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.date_range,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricDropdown(BuildContext context, ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _selectedMetric,
      decoration: InputDecoration(
        labelText: 'Metric',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.trending_up,
          color: theme.colorScheme.primary,
        ),
      ),
      items: _availableMetrics.map((metric) {
        return DropdownMenuItem(
          value: metric,
          child: Text(metric),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedMetric = value;
          });
        }
      },
    );
  }

  Widget _buildPeriodDropdown(BuildContext context, ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _selectedPeriod,
      decoration: InputDecoration(
        labelText: 'Period',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: Icon(
          Icons.schedule,
          color: theme.colorScheme.primary,
        ),
      ),
      items: _availablePeriods.map((period) {
        return DropdownMenuItem(
          value: period,
          child: Text(period),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPeriod = value;
          });
        }
      },
    );
  }

  Widget _buildMetricsOverview(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.dashboard,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Key Metrics Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer<DashboardService>(
          builder: (context, dashboardService, child) {
            final metrics = dashboardService.state.metrics;
            final columns = ResponsiveHelper.getGridColumns(context);
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              itemCount: metrics.length,
              itemBuilder: (context, index) {
                return _buildInteractiveMetricCard(context, theme, metrics[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildInteractiveMetricCard(
    BuildContext context,
    ThemeData theme,
    MetricCardData metric,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _showMetricDetails(context, metric),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: metric.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      metric.icon,
                      color: metric.color,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    metric.isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                    color: metric.isPositiveTrend 
                      ? theme.colorScheme.secondary 
                      : theme.colorScheme.error,
                    size: 16,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                metric.title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metric.value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, ThemeData theme, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.bar_chart,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Interactive Charts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isMobile) ...[
          _buildMobileCharts(context, theme),
        ] else ...[
          _buildDesktopCharts(context, theme),
        ],
      ],
    );
  }

  Widget _buildMobileCharts(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildTrendChart(context, theme),
        const SizedBox(height: 16),
        _buildComparisonChart(context, theme),
      ],
    );
  }

  Widget _buildDesktopCharts(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildTrendChart(context, theme),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildComparisonChart(context, theme),
        ),
      ],
    );
  }

  Widget _buildTrendChart(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$_selectedMetric Trend',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(fontSize: 10);
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text('Day ${value.toInt()}', style: style),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 42,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            '\$${value.toInt()}k',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: 7,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 2.8),
                        FlSpot(2, 4.2),
                        FlSpot(3, 3.5),
                        FlSpot(4, 4.8),
                        FlSpot(5, 4.1),
                        FlSpot(6, 5.2),
                        FlSpot(7, 4.7),
                      ],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.3),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withOpacity(0.1),
                            theme.colorScheme.primary.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonChart(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Department Comparison',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: theme.colorScheme.primary,
                      value: 30,
                      title: '30%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: theme.colorScheme.secondary,
                      value: 25,
                      title: '25%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: theme.colorScheme.tertiary,
                      value: 20,
                      title: '20%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: theme.colorScheme.error,
                      value: 15,
                      title: '15%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: theme.colorScheme.outline,
                      value: 10,
                      title: '10%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedAnalytics(BuildContext context, ThemeData theme, bool isMobile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Detailed Analytics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnalyticsTable(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTable(BuildContext context, ThemeData theme) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          children: [
            _buildTableHeader(theme, 'Metric'),
            _buildTableHeader(theme, 'Current'),
            _buildTableHeader(theme, 'Previous'),
            _buildTableHeader(theme, 'Change'),
          ],
        ),
        _buildTableRow(theme, 'Revenue', '\$45.2K', '\$38.1K', '+18.6%', true),
        _buildTableRow(theme, 'Users', '12.4K', '11.8K', '+5.1%', true),
        _buildTableRow(theme, 'Sessions', '28.7K', '31.2K', '-8.0%', false),
        _buildTableRow(theme, 'Bounce Rate', '32.1%', '35.4%', '-3.3%', true),
      ],
    );
  }

  Widget _buildTableHeader(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  TableRow _buildTableRow(
    ThemeData theme,
    String metric,
    String current,
    String previous,
    String change,
    bool isPositive,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(metric, style: theme.textTheme.bodyMedium),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(current, style: theme.textTheme.bodyMedium),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(previous, style: theme.textTheme.bodyMedium),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive 
                  ? theme.colorScheme.secondary 
                  : theme.colorScheme.error,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isPositive 
                    ? theme.colorScheme.secondary 
                    : theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    // TODO: Implement actual filter logic
    // setState(() {
    //   _isLoading = true;
    // });

    // Simulate data loading
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        // setState(() {
        //   _isLoading = false;
        // });
      }
    });
  }

  Future<void> _refreshData() async {
    // TODO: Implement actual refresh logic
    // setState(() {
    //   _isLoading = true;
    // });

    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Analytics data exported successfully! 📊'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMetricDetails(BuildContext context, MetricCardData metric) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(metric.icon, color: metric.color),
            const SizedBox(width: 8),
            Text(metric.title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Value: ${metric.value}'),
            const SizedBox(height: 8),
            Text('Trend: ${metric.trendPercentage.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text('Description: ${metric.subtitle}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}