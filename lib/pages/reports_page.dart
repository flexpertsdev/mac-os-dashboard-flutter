import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../services/users_service.dart';
import '../utils/responsive_helper.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  List<Report> _reports = [];
  bool _isLoading = false;
  String _selectedReportType = 'All';

  final List<String> _reportTypes = [
    'All', 'Analytics', 'Users', 'Financial', 'Performance', 'Custom'
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
    _loadReports();
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

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: RefreshIndicator(
            onRefresh: _refreshReports,
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getContentPadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme),
                  const SizedBox(height: 24),
                  _buildQuickActions(context, theme, isMobile),
                  const SizedBox(height: 24),
                  _buildFilters(context, theme),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    _buildLoadingState(theme)
                  else
                    _buildReportsList(context, theme),
                  const SizedBox(height: 100), // Bottom padding for mobile
                ],
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.assessment,
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
                'Reports & Insights',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Generate, schedule, and manage your business reports',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        FloatingActionButton.extended(
          onPressed: () => _showCreateReportDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('New Report'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme, bool isMobile) {
    final actions = [
      _QuickAction(
        title: 'User Analytics',
        description: 'Generate user behavior report',
        icon: Icons.people_alt,
        color: theme.colorScheme.primary,
        onTap: () => _generateQuickReport(ReportType.users),
      ),
      _QuickAction(
        title: 'Performance',
        description: 'System performance metrics',
        icon: Icons.speed,
        color: theme.colorScheme.secondary,
        onTap: () => _generateQuickReport(ReportType.performance),
      ),
      _QuickAction(
        title: 'Financial',
        description: 'Revenue and cost analysis',
        icon: Icons.attach_money,
        color: theme.colorScheme.tertiary,
        onTap: () => _generateQuickReport(ReportType.financial),
      ),
      _QuickAction(
        title: 'Custom Report',
        description: 'Build your own report',
        icon: Icons.build,
        color: theme.colorScheme.error,
        onTap: () => _showCreateReportDialog(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.flash_on, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 1.2 : 1.4,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Card(
              child: InkWell(
                onTap: action.onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: action.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          action.icon,
                          color: action.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        action.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.filter_list, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Filter by Type:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Wrap(
                spacing: 8,
                children: _reportTypes.map((type) {
                  final isSelected = _selectedReportType == type;
                  return ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedReportType = type;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsList(BuildContext context, ThemeData theme) {
    final filteredReports = _selectedReportType == 'All'
        ? _reports
        : _reports.where((r) => r.type.name.toLowerCase() == _selectedReportType.toLowerCase()).toList();

    if (filteredReports.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.folder_open, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Recent Reports (${filteredReports.length})',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredReports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildReportCard(context, theme, filteredReports[index]);
          },
        ),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context, ThemeData theme, Report report) {
    final statusColor = _getStatusColor(theme, report.status);
    final typeIcon = _getTypeIcon(report.type);

    return Card(
      child: InkWell(
        onTap: () => _showReportDetails(context, report),
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
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      typeIcon,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          report.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.status.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Created by ${report.createdBy}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(report.createdDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Column(
      children: List.generate(3, (index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 200,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.assessment_outlined,
                size: 64,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No reports found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first report to get started',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showCreateReportDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme, ReportStatus status) {
    switch (status) {
      case ReportStatus.completed:
        return theme.colorScheme.secondary;
      case ReportStatus.processing:
        return theme.colorScheme.tertiary;
      case ReportStatus.failed:
        return theme.colorScheme.error;
      case ReportStatus.scheduled:
        return theme.colorScheme.primary;
      case ReportStatus.pending:
      default:
        return theme.colorScheme.outline;
    }
  }

  IconData _getTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.analytics:
        return Icons.analytics;
      case ReportType.users:
        return Icons.people;
      case ReportType.financial:
        return Icons.attach_money;
      case ReportType.performance:
        return Icons.speed;
      case ReportType.custom:
      default:
        return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _loadReports() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading sample reports
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _reports = [
          Report(
            id: '1',
            title: 'Monthly User Analytics',
            description: 'Comprehensive analysis of user behavior and engagement metrics for the past month',
            createdDate: DateTime.now().subtract(const Duration(days: 2)),
            createdBy: 'Sarah Johnson',
            type: ReportType.analytics,
            status: ReportStatus.completed,
            parameters: {'period': 'monthly', 'metrics': ['sessions', 'users', 'bounce_rate']},
          ),
          Report(
            id: '2',
            title: 'Q4 Financial Summary',
            description: 'Quarterly financial performance and revenue analysis',
            createdDate: DateTime.now().subtract(const Duration(days: 5)),
            scheduledDate: DateTime.now().add(const Duration(days: 1)),
            createdBy: 'Michael Chen',
            type: ReportType.financial,
            status: ReportStatus.scheduled,
            parameters: {'quarter': 'Q4', 'year': '2024'},
          ),
          Report(
            id: '3',
            title: 'System Performance Report',
            description: 'Application performance metrics and optimization recommendations',
            createdDate: DateTime.now().subtract(const Duration(hours: 6)),
            createdBy: 'Emily Rodriguez',
            type: ReportType.performance,
            status: ReportStatus.processing,
            parameters: {'timeframe': 'last_week', 'systems': ['api', 'database', 'frontend']},
          ),
        ];
        _isLoading = false;
      });
    });
  }

  Future<void> _refreshReports() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateQuickReport(ReportType type) {
    final newReport = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${type.name.toUpperCase()} Quick Report',
      description: 'Auto-generated ${type.name} report',
      createdDate: DateTime.now(),
      createdBy: 'Current User',
      type: type,
      status: ReportStatus.processing,
      parameters: {'type': 'quick', 'auto_generated': true},
    );

    setState(() {
      _reports.insert(0, newReport);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating ${type.name} report... 📊'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );

    // Simulate report completion
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        final index = _reports.indexWhere((r) => r.id == newReport.id);
        if (index != -1) {
          _reports[index] = _reports[index].copyWith(status: ReportStatus.completed);
        }
      });
    });
  }

  void _showCreateReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateReportDialog(
        onReportCreated: (report) {
          setState(() {
            _reports.insert(0, report);
          });
        },
      ),
    );
  }

  void _showReportDetails(BuildContext context, Report report) {
    showDialog(
      context: context,
      builder: (context) => _ReportDetailsDialog(report: report),
    );
  }
}

class _QuickAction {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _CreateReportDialog extends StatefulWidget {
  final Function(Report) onReportCreated;

  const _CreateReportDialog({required this.onReportCreated});

  @override
  State<_CreateReportDialog> createState() => _CreateReportDialogState();
}

class _CreateReportDialogState extends State<_CreateReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  ReportType _selectedType = ReportType.analytics;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Create New Report'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Report Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Report Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: ReportType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createReport() {
    if (_formKey.currentState!.validate()) {
      final report = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        createdDate: DateTime.now(),
        createdBy: 'Current User',
        type: _selectedType,
        status: ReportStatus.pending,
        parameters: {'custom': true},
      );

      widget.onReportCreated(report);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report created successfully!'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }
}

class _ReportDetailsDialog extends StatelessWidget {
  final Report report;

  const _ReportDetailsDialog({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(report.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description:',
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(report.description),
          const SizedBox(height: 16),
          Text(
            'Details:',
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          _buildDetailRow('Type', report.type.name.toUpperCase()),
          _buildDetailRow('Status', report.status.name.toUpperCase()),
          _buildDetailRow('Created by', report.createdBy),
          _buildDetailRow('Created on', _formatDateTime(report.createdDate)),
          if (report.scheduledDate != null)
            _buildDetailRow('Scheduled for', _formatDateTime(report.scheduledDate!)),
        ],
      ),
      actions: [
        if (report.status == ReportStatus.completed)
          TextButton.icon(
            onPressed: () => _downloadReport(context),
            icon: const Icon(Icons.download),
            label: const Text('Download'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('\$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _downloadReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report downloaded successfully! 📄'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
    Navigator.of(context).pop();
  }
}

extension ReportCopyWith on Report {
  Report copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdDate,
    DateTime? scheduledDate,
    String? createdBy,
    ReportType? type,
    ReportStatus? status,
    Map<String, dynamic>? parameters,
    String? filePath,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      createdBy: createdBy ?? this.createdBy,
      type: type ?? this.type,
      status: status ?? this.status,
      parameters: parameters ?? this.parameters,
      filePath: filePath ?? this.filePath,
    );
  }
}