import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';

class MetricCard extends StatefulWidget {
  final MetricCardData data;

  const MetricCard({
    super.key,
    required this.data,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: ResponsiveHelper.getCardConstraints(context),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                border: Border.all(
                  color: _isHovered
                      ? theme.colorScheme.outline.withOpacity(0.3)
                      : theme.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(
                      _isHovered ? 0.08 : 0.04,
                    ),
                    blurRadius: _isHovered ? 12 : 6,
                    offset: Offset(0, _isHovered ? 6 : 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showDetails(context),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                  child: Padding(
                    padding: ResponsiveHelper.getContentPadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, theme),
                        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                        _buildValue(context, theme),
                        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                        _buildTrend(context, theme),
                        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                        _buildSubtitle(context, theme),
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

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 8)),
          decoration: BoxDecoration(
            color: widget.data.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
          ),
          child: Icon(
            widget.data.icon,
            color: widget.data.color,
            size: ResponsiveHelper.getIconSize(context, baseSize: 20),
          ),
        ),
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
        Expanded(
          child: Text(
            widget.data.title,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
        ResponsiveTheme.responsiveIconButton(
          context: context,
          onPressed: () => _showMoreOptions(context),
          icon: Icons.more_horiz,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
          tooltip: 'More options',
        ),
      ],
    );
  }

  Widget _buildValue(BuildContext context, ThemeData theme) {
    return Text(
      widget.data.value,
      style: ResponsiveTheme.responsiveTextStyle(
        context,
        baseFontSize: 24,
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurface,
        height: 1.1,
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _buildTrend(BuildContext context, ThemeData theme) {
    final trendColor = widget.data.isPositiveTrend
        ? theme.colorScheme.secondary
        : theme.colorScheme.error;
    final trendIcon = widget.data.isPositiveTrend
        ? Icons.trending_up
        : Icons.trending_down;
    final trendText = '${widget.data.isPositiveTrend ? '+' : ''}${widget.data.trendPercentage.toStringAsFixed(1)}%';

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveWidth(context, 6),
            vertical: ResponsiveHelper.getResponsiveHeight(context, 2),
          ),
          decoration: BoxDecoration(
            color: trendColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                trendIcon,
                color: trendColor,
                size: ResponsiveHelper.getResponsiveWidth(context, 12),
              ),
              SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 2)),
              Text(
                trendText,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: trendColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
        Flexible(
          child: Text(
            'vs last period',
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: ResponsiveHelper.getResponsiveWidth(context, 4),
          height: ResponsiveHelper.getResponsiveWidth(context, 4),
          decoration: BoxDecoration(
            color: widget.data.color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 6)),
        Flexible(
          child: Text(
            widget.data.subtitle,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 8)),
              decoration: BoxDecoration(
                color: widget.data.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
              ),
              child: Icon(
                widget.data.icon,
                color: widget.data.color,
                size: ResponsiveHelper.getIconSize(context, baseSize: 20),
              ),
            ),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
            Flexible(
              child: Text(
                widget.data.title,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 20,
                  color: theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Value',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.data.value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Trend',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            _buildTrend(context, theme),
            const SizedBox(height: 16),
            Text(
              'Period',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.data.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Viewing detailed ${widget.data.title} analytics'),
                  backgroundColor: theme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: Text(
              'View Details',
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    // Show options menu for metric
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: ResponsiveHelper.getContentPadding(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('View Analytics'),
              onTap: () {
                Navigator.of(context).pop();
                _showDetails(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Metric'),
              onTap: () {
                Navigator.of(context).pop();
                // Implement share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Set Alert'),
              onTap: () {
                Navigator.of(context).pop();
                // Implement alert functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}