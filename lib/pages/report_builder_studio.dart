import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../utils/responsive_helper.dart';
import '../utils/responsive_theme.dart';
import '../services/demo_session_service.dart';
import '../models/demo_models.dart';

class ReportBuilderStudio extends StatefulWidget {
  final Map<String, dynamic>? existingReport;
  
  const ReportBuilderStudio({
    super.key,
    this.existingReport,
  });

  @override
  State<ReportBuilderStudio> createState() => _ReportBuilderStudioState();
}

class _ReportBuilderStudioState extends State<ReportBuilderStudio>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _canvasController;
  late AnimationController _componentController;
  late AnimationController _previewController;
  
  late Animation<double> _heroAnimation;
  late Animation<double> _canvasSlide;
  late Animation<double> _componentFade;
  late Animation<double> _previewScale;
  
  // Studio state
  bool _isPreviewMode = false;
  bool _showComponentPanel = true;
  bool _showPropertiesPanel = true;
  String _selectedTool = 'select';
  
  // Report data
  final Map<String, dynamic> _reportData = {
    'title': '',
    'description': '',
    'template': 'blank',
    'components': <Map<String, dynamic>>[],
    'layout': 'dashboard',
    'theme': 'professional',
    'scheduled': false,
    'recipients': <String>[],
  };
  
  // Drag and drop state
  ReportComponent? _draggedComponent;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  
  // Canvas components
  final List<CanvasComponent> _canvasComponents = [];
  CanvasComponent? _selectedComponent;
  
  // Available components
  final List<ReportComponent> _availableComponents = [
    ReportComponent(
      id: 'chart_bar',
      name: 'Bar Chart',
      icon: Icons.bar_chart,
      category: 'Charts',
      color: const Color(0xFF3B82F6),
      description: 'Compare values across categories',
    ),
    ReportComponent(
      id: 'chart_line',
      name: 'Line Chart',
      icon: Icons.show_chart,
      category: 'Charts',
      color: const Color(0xFF10B981),
      description: 'Show trends over time',
    ),
    ReportComponent(
      id: 'chart_pie',
      name: 'Pie Chart',
      icon: Icons.pie_chart,
      category: 'Charts',
      color: const Color(0xFF8B5CF6),
      description: 'Display proportional data',
    ),
    ReportComponent(
      id: 'metric_card',
      name: 'KPI Card',
      icon: Icons.analytics,
      category: 'Metrics',
      color: const Color(0xFFF59E0B),
      description: 'Highlight key metrics',
    ),
    ReportComponent(
      id: 'data_table',
      name: 'Data Table',
      icon: Icons.table_chart,
      category: 'Data',
      color: const Color(0xFF06B6D4),
      description: 'Tabular data display',
    ),
    ReportComponent(
      id: 'text_block',
      name: 'Text Block',
      icon: Icons.text_fields,
      category: 'Content',
      color: const Color(0xFF6B7280),
      description: 'Rich text and titles',
    ),
    ReportComponent(
      id: 'image_widget',
      name: 'Image',
      icon: Icons.image,
      category: 'Media',
      color: const Color(0xFFEF4444),
      description: 'Charts and graphics',
    ),
    ReportComponent(
      id: 'filter_panel',
      name: 'Filters',
      icon: Icons.filter_list,
      category: 'Interactive',
      color: const Color(0xFF7C3AED),
      description: 'Data filtering controls',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // Initialize with existing report data if provided
    if (widget.existingReport != null) {
      _reportData.addAll(widget.existingReport!);
    }
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _canvasController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _componentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _heroAnimation = CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutCubic,
    );
    
    _canvasSlide = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _canvasController,
      curve: Curves.easeOutBack,
    ));
    
    _componentFade = CurvedAnimation(
      parent: _componentController,
      curve: Curves.easeIn,
    );
    
    _previewScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeOutBack,
    ));
    
    _startAnimations();
  }

  void _startAnimations() async {
    _heroController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _canvasController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _componentController.forward();
  }

  @override
  void dispose() {
    _heroController.dispose();
    _canvasController.dispose();
    _componentController.dispose();
    _previewController.dispose();
    super.dispose();
  }
  
  void _togglePreview() {
    setState(() {
      _isPreviewMode = !_isPreviewMode;
    });
    
    if (_isPreviewMode) {
      _previewController.forward();
    } else {
      _previewController.reverse();
    }
    
    HapticFeedback.mediumImpact();
  }
  
  void _togglePanel(String panel) {
    setState(() {
      if (panel == 'components') {
        _showComponentPanel = !_showComponentPanel;
      } else if (panel == 'properties') {
        _showPropertiesPanel = !_showPropertiesPanel;
      }
    });
    HapticFeedback.lightImpact();
  }
  
  void _selectTool(String tool) {
    setState(() {
      _selectedTool = tool;
      _selectedComponent = null;
    });
    HapticFeedback.lightImpact();
  }
  
  void _onComponentDragStart(ReportComponent component, Offset position) {
    setState(() {
      _draggedComponent = component;
      _dragOffset = position;
      _isDragging = true;
    });
    HapticFeedback.lightImpact();
  }
  
  void _onComponentDragUpdate(Offset position) {
    setState(() {
      _dragOffset = position;
    });
  }
  
  void _onComponentDragEnd(Offset position) {
    if (_draggedComponent != null) {
      // Check if dropped on canvas
      final canvasArea = _getCanvasArea();
      if (canvasArea.contains(position)) {
        _addComponentToCanvas(_draggedComponent!, position);
        HapticFeedback.heavyImpact();
      }
    }
    
    setState(() {
      _draggedComponent = null;
      _isDragging = false;
    });
  }
  
  void _addComponentToCanvas(ReportComponent component, Offset position) {
    final canvasArea = _getCanvasArea();
    final relativePosition = Offset(
      (position.dx - canvasArea.left) / canvasArea.width,
      (position.dy - canvasArea.top) / canvasArea.height,
    );
    
    final canvasComponent = CanvasComponent(
      id: '${component.id}_${DateTime.now().millisecondsSinceEpoch}',
      component: component,
      position: relativePosition,
      size: const Size(0.2, 0.15), // Default size as ratio of canvas
      properties: {},
    );
    
    setState(() {
      _canvasComponents.add(canvasComponent);
      _selectedComponent = canvasComponent;
    });
    
    final demoService = context.read<DemoSessionService>();
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Component Added',
      description: 'Added ${component.name} to report canvas.',
      impact: 'Enhanced report visualization capabilities with interactive ${component.category.toLowerCase()} component.',
      discoveredAt: DateTime.now(),
      source: 'Report Builder Studio',
      confidence: 0.95,
      type: InsightType.optimization,
    );
    
    demoService.addInsight(insight);
    demoService.incrementFeatureInteraction('report_builder');
  }
  
  Rect _getCanvasArea() {
    // This would normally be calculated from the actual canvas widget
    // For now, returning a reasonable estimate
    final screenSize = MediaQuery.of(context).size;
    final padding = ResponsiveHelper.getContentPadding(context);
    
    return Rect.fromLTWH(
      _showComponentPanel ? 300 : 0,
       100,
      screenSize.width - (_showComponentPanel ? 300 : 0) - (_showPropertiesPanel ? 300 : 0),
      screenSize.height - 200,
    );
  }
  
  void _saveReport() async {
    _reportData['components'] = _canvasComponents.map((c) => c.toJson()).toList();
    _reportData['lastModified'] = DateTime.now().toIso8601String();
    
    final demoService = context.read<DemoSessionService>();
    
    // Save report data to local storage
    await demoService.saveUserData({
      'reportData': _reportData,
      'canvasComponents': _canvasComponents.length,
      'reportType': _reportData['template'],
    });
    
    final insight = DemoInsight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Report Created',
      description: 'Successfully built "${_reportData['title']}" with ${_canvasComponents.length} components.',
      impact: 'Enhanced business intelligence capabilities. Report ready for stakeholder distribution.',
      discoveredAt: DateTime.now(),
      source: 'Report Builder Studio',
      confidence: 1.0,
      type: InsightType.achievement,
    );
    
    demoService.addInsight(insight);
    demoService.incrementFeatureInteraction('report_creation');
    
    HapticFeedback.heavyImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
            const Expanded(child: Text('Report saved successfully!')),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
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
        animation: Listenable.merge([_heroAnimation, _canvasSlide, _componentFade]),
        builder: (context, child) {
          return Stack(
            children: [
              // Main layout
              Column(
                children: [
                  _buildStudioHeader(theme),
                  Expanded(
                    child: Row(
                      children: [
                        // Component panel
                        if (_showComponentPanel)
                          _buildComponentPanel(theme),
                        
                        // Main canvas area
                        Expanded(
                          child: _buildCanvasArea(theme),
                        ),
                        
                        // Properties panel
                        if (_showPropertiesPanel)
                          _buildPropertiesPanel(theme),
                      ],
                    ),
                  ),
                  _buildBottomToolbar(theme),
                ],
              ),
              
              // Dragged component overlay
              if (_isDragging && _draggedComponent != null)
                _buildDraggedComponent(),
              
              // Preview overlay
              if (_isPreviewMode)
                _buildPreviewOverlay(theme),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildStudioHeader(ThemeData theme) {
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
                    widget.existingReport != null ? 'Edit Report' : 'Report Builder Studio',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Drag, drop, and design your perfect business report',
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
                // Tools
                _buildToolButton('select', Icons.near_me, 'Select'),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                _buildToolButton('hand', Icons.pan_tool, 'Pan'),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                _buildToolButton('zoom', Icons.zoom_in, 'Zoom'),
                
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                
                // Preview toggle
                GestureDetector(
                  onTap: _togglePreview,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
                      vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
                    ),
                    decoration: BoxDecoration(
                      gradient: _isPreviewMode
                          ? const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            )
                          : null,
                      color: _isPreviewMode ? null : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                      border: Border.all(
                        color: _isPreviewMode ? Colors.transparent : Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isPreviewMode ? Icons.edit : Icons.visibility,
                          color: Colors.white,
                          size: ResponsiveHelper.getIconSize(context, baseSize: 18),
                        ),
                        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                        Text(
                          _isPreviewMode ? 'Edit' : 'Preview',
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                
                // Save button
                GestureDetector(
                  onTap: _saveReport,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getResponsiveWidth(context, 20),
                      vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                      ),
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 20)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.save,
                          color: Colors.white,
                          size: ResponsiveHelper.getIconSize(context, baseSize: 18),
                        ),
                        SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                        Text(
                          'Save Report',
                          style: ResponsiveTheme.responsiveTextStyle(
                            context,
                            baseFontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildToolButton(String tool, IconData icon, String tooltip) {
    final isSelected = _selectedTool == tool;
    
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: () => _selectTool(tool),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                  )
                : null,
            color: isSelected ? null : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : null,
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
  
  Widget _buildComponentPanel(ThemeData theme) {
    return Transform.translate(
      offset: Offset(_canvasSlide.value * -300, 0),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: const Color(0xFF1A202C),
          border: Border(
            right: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Panel header
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
                    Icons.widgets,
                    color: const Color(0xFF3B82F6),
                    size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                  ),
                  SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                  Expanded(
                    child: Text(
                      'Components',
                      style: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _togglePanel('components'),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.6),
                      size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            
            // Components list
            Expanded(
              child: FadeTransition(
                opacity: _componentFade,
                child: ListView(
                  padding: ResponsiveHelper.getContentPadding(context),
                  children: [
                    _buildComponentCategory('Charts'),
                    _buildComponentCategory('Metrics'),
                    _buildComponentCategory('Data'),
                    _buildComponentCategory('Content'),
                    _buildComponentCategory('Media'),
                    _buildComponentCategory('Interactive'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildComponentCategory(String category) {
    final categoryComponents = _availableComponents
        .where((c) => c.category == category)
        .toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
          ),
          child: Text(
            category,
            style: ResponsiveTheme.responsiveTextStyle(
              context,
              baseFontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        
        ...categoryComponents.map((component) => _buildComponentItem(component)),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
      ],
    );
  }
  
  Widget _buildComponentItem(ReportComponent component) {
    return Draggable<ReportComponent>(
      data: component,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragStarted: () => HapticFeedback.lightImpact(),
      onDragEnd: (details) => _onComponentDragEnd(details.offset),
      feedback: Material(
        color: Colors.transparent,
        child: _buildComponentCard(component, isDragging: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildComponentCard(component),
      ),
      child: _buildComponentCard(component),
    );
  }
  
  Widget _buildComponentCard(ReportComponent component, {bool isDragging = false}) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveHelper.getAccessibleSpacing(context, 8),
      ),
      padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 12)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            component.color.withOpacity(isDragging ? 0.3 : 0.1),
            component.color.withOpacity(isDragging ? 0.2 : 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
        border: Border.all(
          color: component.color.withOpacity(isDragging ? 0.5 : 0.3),
          width: isDragging ? 2 : 1,
        ),
        boxShadow: isDragging ? [
          BoxShadow(
            color: component.color.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ] : null,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 8)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [component.color, component.color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
            ),
            child: Icon(
              component.icon,
              color: Colors.white,
              size: ResponsiveHelper.getIconSize(context, baseSize: 20),
            ),
          ),
          
          SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  component.name,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 2)),
                Text(
                  component.description,
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCanvasArea(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1E293B).withOpacity(0.8),
            const Color(0xFF0F172A),
          ],
        ),
      ),
      child: Column(
        children: [
          // Canvas header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveWidth(context, 20),
              vertical: ResponsiveHelper.getResponsiveHeight(context, 16),
            ),
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
                // Report title input
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _reportData['title'] = value;
                      });
                    },
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Untitled Report',
                      hintStyle: ResponsiveTheme.responsiveTextStyle(
                        context,
                        baseFontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                
                // Canvas controls
                Row(
                  children: [
                    _buildCanvasControl(Icons.grid_on, 'Grid', () {}),
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                    _buildCanvasControl(Icons.straighten, 'Rulers', () {}),
                    SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                    _buildCanvasControl(Icons.fullscreen, 'Fit', () {}),
                  ],
                ),
              ],
            ),
          ),
          
          // Canvas
          Expanded(
            child: DragTarget<ReportComponent>(
              onWillAccept: (component) => component != null,
              onAccept: (component) {
                // Handle drop on canvas
                final canvasCenter = Offset(
                  MediaQuery.of(context).size.width / 2,
                  MediaQuery.of(context).size.height / 2,
                );
                _addComponentToCanvas(component, canvasCenter);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty 
                        ? const Color(0xFF3B82F6).withOpacity(0.1)
                        : Colors.transparent,
                    border: candidateData.isNotEmpty 
                        ? Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.5),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Stack(
                    children: [
                      // Grid background
                      CustomPaint(
                        painter: GridPainter(
                          color: Colors.white.withOpacity(0.05),
                          strokeWidth: 1,
                          gridSize: 20,
                        ),
                        size: Size.infinite,
                      ),
                      
                      // Canvas components
                      ..._canvasComponents.map((component) => _buildCanvasComponent(component)),
                      
                      // Drop zone indicator
                      if (candidateData.isNotEmpty)
                        Center(
                          child: Container(
                            padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 32)),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3B82F6).withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: ResponsiveHelper.getIconSize(context, baseSize: 48),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCanvasControl(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(ResponsiveHelper.getResponsiveWidth(context, 8)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: ResponsiveHelper.getIconSize(context, baseSize: 16),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCanvasComponent(CanvasComponent component) {
    final canvasArea = _getCanvasArea();
    final position = Offset(
      component.position.dx * canvasArea.width,
      component.position.dy * canvasArea.height,
    );
    final size = Size(
      component.size.width * canvasArea.width,
      component.size.height * canvasArea.height,
    );
    
    final isSelected = _selectedComponent?.id == component.id;
    
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedComponent = component;
          });
          HapticFeedback.lightImpact();
        },
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                component.component.color.withOpacity(0.2),
                component.component.color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFF3B82F6)
                  : component.component.color.withOpacity(0.3),
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                component.component.icon,
                color: component.component.color,
                size: ResponsiveHelper.getIconSize(context, baseSize: 32),
              ),
              SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
              Text(
                component.component.name,
                style: ResponsiveTheme.responsiveTextStyle(
                  context,
                  baseFontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPropertiesPanel(ThemeData theme) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF1A202C),
        border: Border(
          left: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Panel header
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
                  Icons.tune,
                  color: const Color(0xFF8B5CF6),
                  size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                ),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 12)),
                Expanded(
                  child: Text(
                    'Properties',
                    style: ResponsiveTheme.responsiveTextStyle(
                      context,
                      baseFontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _togglePanel('properties'),
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.6),
                    size: ResponsiveHelper.getIconSize(context, baseSize: 20),
                  ),
                ),
              ],
            ),
          ),
          
          // Properties content
          Expanded(
            child: _selectedComponent != null
                ? _buildComponentProperties(_selectedComponent!)
                : _buildReportProperties(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildComponentProperties(CanvasComponent component) {
    return ListView(
      padding: ResponsiveHelper.getContentPadding(context),
      children: [
        Text(
          component.component.name,
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
        
        // Position properties
        _buildPropertySection(
          'Position',
          [
            _buildSliderProperty('X', component.position.dx, 0.0, 1.0, (value) {
              setState(() {
                component.position = Offset(value, component.position.dy);
              });
            }),
            _buildSliderProperty('Y', component.position.dy, 0.0, 1.0, (value) {
              setState(() {
                component.position = Offset(component.position.dx, value);
              });
            }),
          ],
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
        
        // Size properties
        _buildPropertySection(
          'Size',
          [
            _buildSliderProperty('Width', component.size.width, 0.1, 0.8, (value) {
              setState(() {
                component.size = Size(value, component.size.height);
              });
            }),
            _buildSliderProperty('Height', component.size.height, 0.1, 0.6, (value) {
              setState(() {
                component.size = Size(component.size.width, value);
              });
            }),
          ],
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
        
        // Delete button
        GestureDetector(
          onTap: () {
            setState(() {
              _canvasComponents.remove(component);
              _selectedComponent = null;
            });
            HapticFeedback.heavyImpact();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: ResponsiveHelper.getIconSize(context, baseSize: 18),
                ),
                SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                Text(
                  'Delete Component',
                  style: ResponsiveTheme.responsiveTextStyle(
                    context,
                    baseFontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildReportProperties() {
    return ListView(
      padding: ResponsiveHelper.getContentPadding(context),
      children: [
        Text(
          'Report Settings',
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
        
        // Template selection
        _buildPropertySection(
          'Template',
          [
            _buildDropdownProperty('Layout', _reportData['template'], [
              'blank', 'dashboard', 'executive', 'detailed'
            ], (value) {
              setState(() {
                _reportData['template'] = value;
              });
            }),
          ],
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
        
        // Theme selection
        _buildPropertySection(
          'Appearance',
          [
            _buildDropdownProperty('Theme', _reportData['theme'], [
              'professional', 'modern', 'minimal', 'colorful'
            ], (value) {
              setState(() {
                _reportData['theme'] = value;
              });
            }),
          ],
        ),
        
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 20)),
        
        // Scheduling
        _buildPropertySection(
          'Scheduling',
          [
            _buildSwitchProperty('Auto-refresh', _reportData['scheduled'], (value) {
              setState(() {
                _reportData['scheduled'] = value;
              });
            }),
          ],
        ),
      ],
    );
  }
  
  Widget _buildPropertySection(String title, List<Widget> properties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
        ...properties,
      ],
    );
  }
  
  Widget _buildSliderProperty(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            Text(
              (value * 100).toInt().toString(),
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF8B5CF6),
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            thumbColor: const Color(0xFF8B5CF6),
            overlayColor: const Color(0xFF8B5CF6).withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
      ],
    );
  }
  
  Widget _buildDropdownProperty(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
            vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1A202C),
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 14,
                color: Colors.white,
              ),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option[0].toUpperCase() + option.substring(1)),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) onChanged(newValue);
              },
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
      ],
    );
  }
  
  Widget _buildSwitchProperty(String label, bool value, ValueChanged<bool> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF8B5CF6),
              inactiveThumbColor: Colors.white.withOpacity(0.6),
              inactiveTrackColor: Colors.white.withOpacity(0.2),
            ),
          ],
        ),
        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 12)),
      ],
    );
  }
  
  Widget _buildBottomToolbar(ThemeData theme) {
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Component count
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
              vertical: ResponsiveHelper.getResponsiveHeight(context, 6),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
            ),
            child: Text(
              '${_canvasComponents.length} components',
              style: ResponsiveTheme.responsiveTextStyle(
                context,
                baseFontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          
          const Spacer(),
          
          // Panel toggles
          Row(
            children: [
              _buildPanelToggle('Components', _showComponentPanel, () => _togglePanel('components')),
              SizedBox(width: ResponsiveHelper.getAccessibleSpacing(context, 8)),
              _buildPanelToggle('Properties', _showPropertiesPanel, () => _togglePanel('properties')),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPanelToggle(String label, bool isVisible, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
          vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
        ),
        decoration: BoxDecoration(
          gradient: isVisible
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                )
              : null,
          color: isVisible ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
          border: Border.all(
            color: isVisible ? Colors.transparent : Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: ResponsiveTheme.responsiveTextStyle(
            context,
            baseFontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildDraggedComponent() {
    if (_draggedComponent == null) return const SizedBox();
    
    return Positioned(
      left: _dragOffset.dx - 100,
      top: _dragOffset.dy - 50,
      child: IgnorePointer(
        child: Transform.scale(
          scale: 1.1,
          child: _buildComponentCard(_draggedComponent!, isDragging: true),
        ),
      ),
    );
  }
  
  Widget _buildPreviewOverlay(ThemeData theme) {
    return AnimatedBuilder(
      animation: _previewScale,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(0.9),
          child: Transform.scale(
            scale: _previewScale.value,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Preview header
                    Container(
                      padding: ResponsiveHelper.getContentPadding(context),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E40AF),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                          topRight: Radius.circular(ResponsiveHelper.getResponsiveWidth(context, 16)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _reportData['title'].toString().isEmpty 
                                  ? 'Untitled Report' 
                                  : _reportData['title'].toString(),
                              style: ResponsiveTheme.responsiveTextStyle(
                                context,
                                baseFontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _togglePreview,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: ResponsiveHelper.getIconSize(context, baseSize: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Preview content
                    Expanded(
                      child: Container(
                        padding: ResponsiveHelper.getContentPadding(context),
                        child: _canvasComponents.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.assignment,
                                      size: ResponsiveHelper.getIconSize(context, baseSize: 64),
                                      color: Colors.grey.withOpacity(0.5),
                                    ),
                                    SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 16)),
                                    Text(
                                      'No components added yet',
                                      style: ResponsiveTheme.responsiveTextStyle(
                                        context,
                                        baseFontSize: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : 3,
                                  childAspectRatio: 1.5,
                                  crossAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 16),
                                  mainAxisSpacing: ResponsiveHelper.getAccessibleSpacing(context, 16),
                                ),
                                itemCount: _canvasComponents.length,
                                itemBuilder: (context, index) {
                                  final component = _canvasComponents[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          component.component.color.withOpacity(0.1),
                                          component.component.color.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
                                      border: Border.all(
                                        color: component.component.color.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          component.component.icon,
                                          color: component.component.color,
                                          size: ResponsiveHelper.getIconSize(context, baseSize: 32),
                                        ),
                                        SizedBox(height: ResponsiveHelper.getAccessibleSpacing(context, 8)),
                                        Text(
                                          component.component.name,
                                          style: ResponsiveTheme.responsiveTextStyle(
                                            context,
                                            baseFontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Data models
class ReportComponent {
  final String id;
  final String name;
  final IconData icon;
  final String category;
  final Color color;
  final String description;

  ReportComponent({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    required this.color,
    required this.description,
  });
}

class CanvasComponent {
  final String id;
  final ReportComponent component;
  Offset position;
  Size size;
  final Map<String, dynamic> properties;

  CanvasComponent({
    required this.id,
    required this.component,
    required this.position,
    required this.size,
    required this.properties,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'componentId': component.id,
      'position': {'x': position.dx, 'y': position.dy},
      'size': {'width': size.width, 'height': size.height},
      'properties': properties,
    };
  }
}

// Custom painter for grid
class GridPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gridSize;

  GridPainter({
    required this.color,
    required this.strokeWidth,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return color != oldDelegate.color ||
           strokeWidth != oldDelegate.strokeWidth ||
           gridSize != oldDelegate.gridSize;
  }
}