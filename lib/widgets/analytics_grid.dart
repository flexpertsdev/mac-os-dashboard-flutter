import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';
import 'metric_card.dart';
import 'chart_card.dart';

class AnalyticsGrid extends StatefulWidget {
  final List<MetricCardData> metrics;
  final List<ChartCardData> charts;
  final bool isLoading;

  const AnalyticsGrid({
    super.key,
    required this.metrics,
    required this.charts,
    this.isLoading = false,
  });

  @override
  State<AnalyticsGrid> createState() => _AnalyticsGridState();
}

class _AnalyticsGridState extends State<AnalyticsGrid>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    if (!widget.isLoading) {
      _fadeController.forward();
    }
  }

  @override
  void didUpdateWidget(AnalyticsGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _fadeController.reverse();
      } else {
        _fadeController.forward();
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getCardSpacing(context);
    
    if (widget.isLoading) {
      return _buildLoadingState(context);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: ResponsiveHelper.getContentPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Key Metrics', Icons.trending_up),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            _buildMetricsGrid(context, spacing),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
            _buildSectionHeader(context, 'Analytics', Icons.analytics),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            _buildChartsGrid(context, spacing),
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 8)),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: ResponsiveHelper.getIconSize(context, baseSize: 20),
          ),
        ),
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
        Flexible(
          child: Text(
            title,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, double spacing) {
    final columns = ResponsiveHelper.getGridColumns(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    if (isMobile) {
      return _buildMobileMetricsList(spacing);
    }
    
    return _buildResponsiveMetricsGrid(columns, spacing);
  }

  Widget _buildMobileMetricsList(double spacing) {
    return Column(
      children: widget.metrics.asMap().entries.map((entry) {
        return Container(
          margin: EdgeInsets.only(
            bottom: entry.key < widget.metrics.length - 1 ? spacing : 0,
          ),
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 300 + (entry.key * 100)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: MetricCard(data: entry.value),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResponsiveMetricsGrid(int columns, double spacing) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: ResponsiveHelper.getCardAspectRatio(context),
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: widget.metrics.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: MetricCard(data: widget.metrics[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChartsGrid(BuildContext context, double spacing) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    if (isMobile) {
      return _buildMobileChartsList(spacing);
    } else if (isTablet) {
      return _buildTabletChartsGrid(spacing);
    } else {
      return _buildDesktopChartsGrid(spacing);
    }
  }

  Widget _buildMobileChartsList(double spacing) {
    return Column(
      children: widget.charts.asMap().entries.map((entry) {
        return Container(
          margin: EdgeInsets.only(
            bottom: entry.key < widget.charts.length - 1 ? spacing : 0,
          ),
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 400 + (entry.key * 150)),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: ChartCard(data: entry.value),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabletChartsGrid(double spacing) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: ResponsiveHelper.getCardAspectRatio(context),
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: widget.charts.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 150)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: ChartCard(data: widget.charts[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopChartsGrid(double spacing) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: widget.charts.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 150)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: ChartCard(data: widget.charts[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = ResponsiveHelper.getCardSpacing(context);
    final columns = ResponsiveHelper.getGridColumns(context);
    
    return SingleChildScrollView(
      padding: ResponsiveHelper.getContentPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLoadingSectionHeader(theme),
          const SizedBox(height: 16),
          _buildLoadingMetricsGrid(theme, columns, spacing),
          const SizedBox(height: 32),
          _buildLoadingSectionHeader(theme),
          const SizedBox(height: 16),
          _buildLoadingChartsGrid(theme, spacing),
        ],
      ),
    );
  }

  Widget _buildLoadingSectionHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 120,
          height: 24,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingMetricsGrid(ThemeData theme, int columns, double spacing) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: ResponsiveHelper.getCardAspectRatio(context),
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: 6, // Show 6 loading placeholders
      itemBuilder: (context, index) {
        return _buildLoadingCard(theme, 180);
      },
    );
  }

  Widget _buildLoadingChartsGrid(ThemeData theme, double spacing) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    if (isMobile) {
      return Column(
        children: List.generate(3, (index) {
          return Container(
            margin: EdgeInsets.only(bottom: index < 2 ? spacing : 0),
            child: _buildLoadingCard(theme, 320),
          );
        }),
      );
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isTablet(context) ? 2 : 3,
        childAspectRatio: ResponsiveHelper.isTablet(context) ? 1.2 : 1.1,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildLoadingCard(theme, 320);
      },
    );
  }

  Widget _buildLoadingCard(ThemeData theme, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 32,
              width: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Spacer(),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}