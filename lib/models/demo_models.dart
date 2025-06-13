import 'package:flutter/material.dart';

/// User roles available in the demo
enum UserRole {
  ceo('CEO / Executive', 'Strategic oversight and business performance', Icons.business_center, Color(0xFF007AFF)),
  dataAnalyst('Data Analyst', 'Deep-dive analytics and insights discovery', Icons.analytics, Color(0xFF34C759)),
  marketingDirector('Marketing Director', 'Campaign performance and customer insights', Icons.campaign, Color(0xFFFF9500)),
  productManager('Product Manager', 'Feature adoption and user behavior analysis', Icons.inventory, Color(0xFFAF52DE)),
  investor('Investor', 'Business metrics and growth potential assessment', Icons.trending_up, Color(0xFFFF2D92));

  const UserRole(this.title, this.description, this.icon, this.color);
  
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

/// Business scenarios available for demo
enum BusinessScenario {
  ecommerce(
    'E-Commerce Platform',
    'Customer journey, conversion optimization, inventory management',
    'Online retail business with global reach and complex supply chain',
    Icons.shopping_cart,
    Color(0xFF007AFF),
    ['Customer Acquisition', 'Conversion Funnels', 'Inventory Analytics', 'Seasonal Trends'],
  ),
  saasGrowth(
    'SaaS Growth Platform',
    'User onboarding, feature adoption, churn prediction, MRR tracking',
    'B2B software company scaling customer base and reducing churn',
    Icons.rocket_launch,
    Color(0xFF34C759),
    ['User Onboarding', 'Feature Adoption', 'Churn Prediction', 'Revenue Analytics'],
  ),
  manufacturing(
    'Manufacturing Operations',
    'Supply chain optimization, quality control, predictive maintenance',
    'Industrial manufacturer optimizing operations and reducing downtime',
    Icons.precision_manufacturing,
    Color(0xFFFF9500),
    ['Supply Chain', 'Quality Control', 'Predictive Maintenance', 'Operational Efficiency'],
  ),
  fintech(
    'Financial Services',
    'Risk assessment, portfolio analysis, compliance monitoring',
    'Fintech company managing risk and regulatory compliance',
    Icons.account_balance,
    Color(0xFFAF52DE),
    ['Risk Assessment', 'Portfolio Analysis', 'Compliance', 'Transaction Analytics'],
  ),
  healthtech(
    'Healthcare Analytics',
    'Patient outcomes, operational efficiency, resource optimization',
    'Healthcare organization improving patient care and operational efficiency',
    Icons.health_and_safety,
    Color(0xFFFF2D92),
    ['Patient Outcomes', 'Resource Optimization', 'Operational Efficiency', 'Quality Metrics'],
  );

  const BusinessScenario(
    this.title,
    this.subtitle,
    this.description,
    this.icon,
    this.color,
    this.keyFeatures,
  );
  
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> keyFeatures;
}

/// User's demo session configuration
class DemoSession {
  final UserRole selectedRole;
  final BusinessScenario selectedScenario;
  final DateTime startTime;
  final Map<String, dynamic> preferences;
  final List<String> completedFeatures;
  final Map<String, dynamic> generatedData;
  final List<DemoInsight> discoveredInsights;

  DemoSession({
    required this.selectedRole,
    required this.selectedScenario,
    required this.startTime,
    this.preferences = const {},
    this.completedFeatures = const [],
    this.generatedData = const {},
    this.discoveredInsights = const [],
  });

  DemoSession copyWith({
    UserRole? selectedRole,
    BusinessScenario? selectedScenario,
    DateTime? startTime,
    Map<String, dynamic>? preferences,
    List<String>? completedFeatures,
    Map<String, dynamic>? generatedData,
    List<DemoInsight>? discoveredInsights,
  }) {
    return DemoSession(
      selectedRole: selectedRole ?? this.selectedRole,
      selectedScenario: selectedScenario ?? this.selectedScenario,
      startTime: startTime ?? this.startTime,
      preferences: preferences ?? this.preferences,
      completedFeatures: completedFeatures ?? this.completedFeatures,
      generatedData: generatedData ?? this.generatedData,
      discoveredInsights: discoveredInsights ?? this.discoveredInsights,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedRole': selectedRole.name,
      'selectedScenario': selectedScenario.name,
      'startTime': startTime.toIso8601String(),
      'preferences': preferences,
      'completedFeatures': completedFeatures,
      'generatedData': generatedData,
      'discoveredInsights': discoveredInsights.map((i) => i.toJson()).toList(),
    };
  }

  factory DemoSession.fromJson(Map<String, dynamic> json) {
    return DemoSession(
      selectedRole: UserRole.values.firstWhere((r) => r.name == json['selectedRole']),
      selectedScenario: BusinessScenario.values.firstWhere((s) => s.name == json['selectedScenario']),
      startTime: DateTime.parse(json['startTime']),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      completedFeatures: List<String>.from(json['completedFeatures'] ?? []),
      generatedData: Map<String, dynamic>.from(json['generatedData'] ?? {}),
      discoveredInsights: (json['discoveredInsights'] as List?)
          ?.map((i) => DemoInsight.fromJson(i))
          .toList() ?? [],
    );
  }
}

/// Insights discovered during demo exploration
class DemoInsight {
  final String id;
  final String title;
  final String description;
  final String impact;
  final DateTime discoveredAt;
  final String source;
  final double confidence;
  final InsightType type;

  DemoInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.impact,
    required this.discoveredAt,
    required this.source,
    required this.confidence,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'impact': impact,
      'discoveredAt': discoveredAt.toIso8601String(),
      'source': source,
      'confidence': confidence,
      'type': type.name,
    };
  }

  factory DemoInsight.fromJson(Map<String, dynamic> json) {
    return DemoInsight(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      impact: json['impact'],
      discoveredAt: DateTime.parse(json['discoveredAt']),
      source: json['source'],
      confidence: json['confidence'],
      type: InsightType.values.firstWhere((t) => t.name == json['type']),
    );
  }
}

enum InsightType {
  opportunity('Opportunity', Icons.lightbulb, Color(0xFF34C759)),
  risk('Risk', Icons.warning, Color(0xFFFF9500)),
  anomaly('Anomaly', Icons.error, Color(0xFFFF3B30)),
  trend('Trend', Icons.trending_up, Color(0xFF007AFF)),
  correlation('Correlation', Icons.hub, Color(0xFFAF52DE));

  const InsightType(this.label, this.icon, this.color);
  
  final String label;
  final IconData icon;
  final Color color;
}

/// Onboarding step configuration
class OnboardingStep {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final Widget Function(BuildContext, VoidCallback) builder;

  OnboardingStep({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.builder,
  });
}

/// Demo feature tracking
class DemoFeature {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final DateTime? completedAt;
  final int interactionCount;

  DemoFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isCompleted = false,
    this.completedAt,
    this.interactionCount = 0,
  });

  DemoFeature copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    bool? isCompleted,
    DateTime? completedAt,
    int? interactionCount,
  }) {
    return DemoFeature(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      interactionCount: interactionCount ?? this.interactionCount,
    );
  }
}

/// Analytics metrics for different scenarios
class ScenarioMetric {
  final String id;
  final String name;
  final String category;
  final double value;
  final double previousValue;
  final String unit;
  final bool isPositiveTrend;
  final DateTime timestamp;

  ScenarioMetric({
    required this.id,
    required this.name,
    required this.category,
    required this.value,
    required this.previousValue,
    required this.unit,
    required this.isPositiveTrend,
    required this.timestamp,
  });

  double get changePercentage {
    if (previousValue == 0) return 0;
    return ((value - previousValue) / previousValue) * 100;
  }

  String get formattedValue {
    if (unit == '%') {
      return '${value.toStringAsFixed(1)}%';
    } else if (unit == '\$') {
      if (value >= 1000000) {
        return '\$${(value / 1000000).toStringAsFixed(1)}M';
      } else if (value >= 1000) {
        return '\$${(value / 1000).toStringAsFixed(1)}K';
      } else {
        return '\$${value.toStringAsFixed(0)}';
      }
    } else {
      return '${value.toStringAsFixed(0)} $unit';
    }
  }
}