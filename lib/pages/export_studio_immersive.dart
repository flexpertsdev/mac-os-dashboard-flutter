import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';
import '../services/demo_session_service.dart';
import '../models/demo_models.dart';

class ExportStudioImmersive extends StatefulWidget {
  final Map<String, dynamic> reportData;
  final List<ExportFormat> exportFormats;
  
  const ExportStudioImmersive({
    super.key,
    required this.reportData,
    required this.exportFormats,
  });

  @override
  State<ExportStudioImmersive> createState() => _ExportStudioImmersiveState();
}

class _ExportStudioImmersiveState extends State<ExportStudioImmersive>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _optionsController;
  late AnimationController _previewController;
  
  late Animation<double> _heroAnimation;
  late Animation<double> _optionsStagger;
  late Animation<double> _previewSlide;
  
  // Export state
  String _selectedFormat = '';
  bool _includeRawData = true;
  bool _includeVisualizations = true;
  bool _includeAnnotations = false;
  bool _includeComments = false;
  String _selectedQuality = 'high';
  String _selectedOrientation = 'landscape';
  bool _isExporting = false;
  bool _showPreview = false;
  
  // Export options
  final List<String> _qualityOptions = ['low', 'medium', 'high', 'ultra'];
  final List<String> _orientationOptions = ['portrait', 'landscape'];
  
  // Advanced options
  bool _showAdvancedOptions = false;
  String _selectedColorScheme = 'auto';
  bool _enableInteractivity = false;
  String _compressionLevel = 'balanced';
  List<String> _selectedSections = [];

  @override
  void initState() {
    super.initState();
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _optionsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    
    _optionsStagger = CurvedAnimation(
      parent: _optionsController,
      curve: Curves.easeOutBack,
    );
    
    _previewSlide = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeOutCubic,
    ));
    
    _startAnimations();
  }

  void _startAnimations() async {
    _heroController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _optionsController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _optionsController.dispose();
    _previewController.dispose();
    super.dispose();
  }
  
  void _selectFormat(ExportFormat format) {
    setState(() {
      _selectedFormat = format.name;
    });
    HapticFeedback.lightImpact();
  }
  
  void _togglePreview() {
    setState(() {
      _showPreview = !_showPreview;
    });
    
    if (_showPreview) {
      _previewController.forward();
    } else {
      _previewController.reverse();
    }
    
    HapticFeedback.mediumImpact();
  }
  
  void _exportReport() async {
    if (_selectedFormat.isEmpty) {
      _showErrorSnackBar('Please select an export format');
      return;
    }
    
    setState(() {
      _isExporting = true;
    });
    
    HapticFeedback.heavyImpact();
    
    // Simulate export process
    await Future.delayed(const Duration(seconds: 3));
    
    final demoService = context.read<DemoSessionService>();
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Report Exported Successfully',
      description: 'Exported \"${widget.reportData['title']}\" as $_selectedFormat with custom settings.',
      impact: 'Enhanced data sharing capabilities with stakeholders and team members.',
      discoveredAt: DateTime.now(),
      source: 'Export Studio',
      confidence: 1.0,
      type: InsightType.optimization,
    );
    
    demoService.addInsight(insight);
    demoService.incrementFeatureInteraction('report_export_advanced');
    
    setState(() {
      _isExporting = false;
    });
    
    _showSuccessDialog();
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
        ),
      ),
    );
  }
  
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: ResponsiveHelper.getContentPadding(context),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 24)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: ResponsiveHelper.getIconSize(context, baseSize: 64),
                color: Colors.white,
              ),
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
              Text(
                'Export Successful!',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
              Text(
                'Your report has been exported as $_selectedFormat and is ready for download.',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Close export studio
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                        ),
                        child: Text(
                          'Done',
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        // Simulate download/share action
                        HapticFeedback.heavyImpact();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                        ),
                        child: Text(
                          'Download',
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF10B981),
                          ),
                          textAlign: TextAlign.center,
                        ),
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: AnimatedBuilder(
        animation: Listenable.merge([_heroAnimation, _optionsStagger, _previewSlide]),
        builder: (context, child) {
          return SafeArea(
            child: Stack(
              children: [
                // Main content
                Column(
                  children: [
                    _buildExportHeader(theme),
                    Expanded(
                      child: Row(
                        children: [
                          // Export options panel
                          Expanded(
                            flex: 3,
                            child: _buildOptionsPanel(theme),
                          ),
                          
                          // Preview panel (when enabled)
                          if (_showPreview)
                            Expanded(
                              flex: 2,
                              child: _buildPreviewPanel(theme),
                            ),
                        ],
                      ),
                    ),
                    _buildExportActions(theme),
                  ],
                ),
                
                // Loading overlay
                if (_isExporting)
                  _buildLoadingOverlay(),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildExportHeader(ThemeData theme) {
    return Transform.translate(
      offset: Offset(0, (1 - _heroAnimation.value) * -100),
      child: Container(
        padding: ResponsiveHelper.getContentPadding(context),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1E40AF).withOpacity(0.9),
              const Color(0xFF3B82F6).withOpacity(0.7),
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                ),
              ),
            ),
            
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
            
            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export Studio',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Customize and export your report in multiple formats',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Header actions
            Row(
              children: [
                _buildHeaderAction(
                  _showPreview ? Icons.visibility_off : Icons.visibility,
                  'Preview',
                  _togglePreview,
                ),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                _buildHeaderAction(Icons.settings, 'Settings', () {
                  setState(() {
                    _showAdvancedOptions = !_showAdvancedOptions;
                  });
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeaderAction(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: ResponsiveHelper.getIconSize(context, baseSize: 20),
          ),
        ),
      ),
    );
  }
  
  Widget _buildOptionsPanel(ThemeData theme) {
    return Transform.translate(
      offset: Offset((1 - _optionsStagger.value) * -300, 0),
      child: SingleChildScrollView(
        padding: ResponsiveHelper.getContentPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Format selection
            _buildFormatSelection(theme),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
            
            // Content options
            _buildContentOptions(theme),
            
            SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
            
            // Quality settings
            _buildQualitySettings(theme),
            
            if (_showAdvancedOptions) ...[
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 32)),
              _buildAdvancedOptions(theme),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildFormatSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Format',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 4,
            childAspectRatio: 1.2,
            crossAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
            mainAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 12),
          ),
          itemCount: widget.exportFormats.length,
          itemBuilder: (context, index) {
            final format = widget.exportFormats[index];
            final isSelected = _selectedFormat == format.name;
            
            return GestureDetector(
              onTap: () => _selectFormat(format),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [format.color, format.color.withOpacity(0.8)],
                        )
                      : null,
                  color: isSelected ? null : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: format.color.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      format.icon,
                      color: isSelected ? Colors.white : format.color,
                      size: ResponsiveHelper.getIconSize(context, baseSize: 32),
                    ),
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                    Text(
                      format.name,
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildContentOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Options',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        _buildToggleOption(
          'Include Raw Data',
          'Export underlying data tables',
          _includeRawData,
          (value) => setState(() => _includeRawData = value),
          Icons.table_chart,
          const Color(0xFF10B981),
        ),
        
        _buildToggleOption(
          'Include Visualizations',
          'Export charts and graphs',
          _includeVisualizations,
          (value) => setState(() => _includeVisualizations = value),
          Icons.bar_chart,
          const Color(0xFF3B82F6),
        ),
        
        _buildToggleOption(
          'Include Annotations',
          'Export user annotations and insights',
          _includeAnnotations,
          (value) => setState(() => _includeAnnotations = value),
          Icons.note_add,
          const Color(0xFF8B5CF6),
        ),
        
        _buildToggleOption(
          'Include Comments',
          'Export team discussions',
          _includeComments,
          (value) => setState(() => _includeComments = value),
          Icons.chat_bubble,
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }
  
  Widget _buildToggleOption(
    String title,
    String description,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 12),
      ),
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(value ? 0.2 : 0.05),
            color.withOpacity(value ? 0.1 : 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
        border: Border.all(
          color: color.withOpacity(value ? 0.4 : 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
            decoration: BoxDecoration(
              gradient: value
                  ? LinearGradient(colors: [color, color.withOpacity(0.8)])
                  : null,
              color: value ? null : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
            ),
            child: Icon(
              icon,
              color: value ? Colors.white : color,
              size: ResponsiveHelper.getIconSize(context, baseSize: 20),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                Text(
                  description,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          Switch(
            value: value,
            onChanged: (newValue) {
              onChanged(newValue);
              HapticFeedback.lightImpact();
            },
            activeColor: color,
            inactiveThumbColor: Colors.white.withOpacity(0.6),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQualitySettings(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quality Settings',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        // Quality selector
        _buildOptionSelector(
          'Export Quality',
          _qualityOptions,
          _selectedQuality,
          (value) => setState(() => _selectedQuality = value),
          const Color(0xFF10B981),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        // Orientation selector
        _buildOptionSelector(
          'Page Orientation',
          _orientationOptions,
          _selectedOrientation,
          (value) => setState(() => _selectedOrientation = value),
          const Color(0xFF3B82F6),
        ),
      ],
    );
  }
  
  Widget _buildOptionSelector(
    String title,
    List<String> options,
    String selectedValue,
    ValueChanged<String> onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
        
        Row(
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  margin: EdgeInsets.only(
                    right: option == options.last ? 0 : ResponsiveHelper.getAccessibleSpacing(context, 8),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [color, color.withOpacity(0.8)])
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    option[0].toUpperCase() + option.substring(1),
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildAdvancedOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Options',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        _buildToggleOption(
          'Enable Interactivity',
          'Create interactive export (where supported)',
          _enableInteractivity,
          (value) => setState(() => _enableInteractivity = value),
          Icons.touch_app,
          const Color(0xFF8B5CF6),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
        
        _buildOptionSelector(
          'Color Scheme',
          ['auto', 'light', 'dark'],
          _selectedColorScheme,
          (value) => setState(() => _selectedColorScheme = value),
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }
  
  Widget _buildPreviewPanel(ThemeData theme) {
    return Transform.translate(
      offset: Offset(_previewSlide.value * MediaQuery.of(context).size.width, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A202C),
          border: Border(
            left: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            // Preview header
            Container(
              padding: ResponsiveHelper.getContentPadding(context),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.preview,
                    color: const Color(0xFF3B82F6),
                    size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                  Expanded(
                    child: Text(
                      'Live Preview',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Preview content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: ResponsiveHelper.getResponsiveWidth(context, 200),
                      height: ResponsiveHelper.getResponsiveHeight(context, 260),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: ResponsiveHelper.getResponsiveHeight(context, 40),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                                topRight: Radius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.reportData['title']?.toString() ?? 'Report',
                                style: ResponsiveTheme.responsiveTextStyle(
                                  context,
                                  baseFontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 16)),
                              child: Column(
                                children: [
                                  // Simulated chart
                                  Container(
                                    height: ResponsiveHelper.getResponsiveHeight(context, 80),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                                      ),
                                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
                                    ),
                                  ),
                                  
                                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                                  
                                  // Simulated metrics
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: ResponsiveHelper.getResponsiveHeight(context, 40),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 6)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                                      Expanded(
                                        child: Container(
                                          height: ResponsiveHelper.getResponsiveHeight(context, 40),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 6)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                                  
                                  // Simulated table
                                  ...List.generate(4, (i) => Container(
                                    margin: EdgeInsets.only(
                                      bottom: ResponsiveHelper.getAccessibleSpacing(context, 4),
                                    ),
                                    height: ResponsiveHelper.getResponsiveHeight(context, 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 2)),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                    
                    Text(
                      'Format: $_selectedFormat',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 4)),
                    
                    Text(
                      'Quality: $_selectedQuality • $_selectedOrientation',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 12,
                        color: Colors.white.withOpacity(0.6),
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
  
  Widget _buildExportActions(ThemeData theme) {
    return Container(
      padding: ResponsiveHelper.getContentPadding(context),
      decoration: BoxDecoration(
        color: const Color(0xFF1A202C),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Export info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedFormat.isNotEmpty 
                      ? 'Ready to export as $_selectedFormat'
                      : 'Select an export format to continue',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                if (_selectedFormat.isNotEmpty)
                  Text(
                    'Quality: $_selectedQuality • ${_selectedOrientation.toUpperCase()}',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
          
          // Export button
          GestureDetector(
            onTap: _selectedFormat.isNotEmpty ? _exportReport : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsiveWidth(context, 32),
                vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
              ),
              decoration: BoxDecoration(
                gradient: _selectedFormat.isNotEmpty
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      )
                    : null,
                color: _selectedFormat.isEmpty 
                    ? Colors.grey.withOpacity(0.3)
                    : null,
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                boxShadow: _selectedFormat.isNotEmpty ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.file_download,
                    color: _selectedFormat.isNotEmpty 
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                  Text(
                    'Export Report',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _selectedFormat.isNotEmpty 
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: ResponsiveHelper.getContentPadding(context),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 24)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: ResponsiveHelper.getResponsiveWidth(context, 60),
                height: ResponsiveHelper.getResponsiveWidth(context, 60),
                child: const CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 24)),
              
              Text(
                'Exporting Report...',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
              
              Text(
                'Preparing your $_selectedFormat export with custom settings',
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExportFormat {
  final String name;
  final IconData icon;
  final Color color;

  ExportFormat(this.name, this.icon, this.color);
}