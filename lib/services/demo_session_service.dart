import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/demo_models.dart';

class DemoSessionService extends ChangeNotifier {
  static const String _sessionKey = 'demo_session';
  static const String _progressKey = 'demo_progress';
  static const String _insightsKey = 'demo_insights';
  static const String _userDataKey = 'user_data';
  
  DemoSession? _currentSession;
  final Map<String, DemoFeature> _features = {};
  final List<DemoInsight> _insights = [];
  bool _isOnboardingComplete = false;
  
  DemoSession? get currentSession => _currentSession;
  bool get isOnboardingComplete => _isOnboardingComplete;
  List<DemoFeature> get features => _features.values.toList();
  List<DemoInsight> get insights => _insights;
  
  // Get completion percentage
  double get completionPercentage {
    if (_features.isEmpty) return 0.0;
    final completed = _features.values.where((f) => f.isCompleted).length;
    return completed / _features.length;
  }

  Future<void> initializeSession() async {
    await _loadSession();
    await _loadProgress();
    await _loadInsights();
    _initializeFeatures();
  }

  Future<void> startNewSession(UserRole role, BusinessScenario scenario) async {
    _currentSession = DemoSession(
      selectedRole: role,
      selectedScenario: scenario,
      startTime: DateTime.now(),
    );
    
    _isOnboardingComplete = true;
    await _saveSession();
    await _generateScenarioData();
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true;
    await _saveSession();
    notifyListeners();
  }

  Future<void> markFeatureCompleted(String featureId) async {
    if (_features.containsKey(featureId)) {
      _features[featureId] = _features[featureId]!.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> incrementFeatureInteraction(String featureId) async {
    if (_features.containsKey(featureId)) {
      _features[featureId] = _features[featureId]!.copyWith(
        interactionCount: _features[featureId]!.interactionCount + 1,
      );
      await _saveProgress();
      notifyListeners();
    }
  }

  Future<void> addInsight(DemoInsight insight) async {
    _insights.add(insight);
    await _saveInsights();
    notifyListeners();
  }

  Future<void> resetSession() async {
    _currentSession = null;
    _isOnboardingComplete = false;
    _features.clear();
    _insights.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_progressKey);
    await prefs.remove(_insightsKey);
    
    notifyListeners();
  }

  // Generate realistic demo data based on selected scenario
  Future<void> _generateScenarioData() async {
    if (_currentSession == null) return;
    
    final scenario = _currentSession!.selectedScenario;
    final random = Random();
    final data = <String, dynamic>{};
    
    switch (scenario) {
      case BusinessScenario.ecommerce:
        data.addAll({
          'monthly_revenue': 1500000 + random.nextDouble() * 500000,
          'conversion_rate': 2.5 + random.nextDouble() * 2.0,
          'average_order_value': 85 + random.nextDouble() * 40,
          'customer_acquisition_cost': 25 + random.nextDouble() * 15,
          'cart_abandonment_rate': 65 + random.nextDouble() * 15,
          'customer_lifetime_value': 320 + random.nextDouble() * 180,
          'return_customer_rate': 35 + random.nextDouble() * 20,
          'inventory_turnover': 8.5 + random.nextDouble() * 3.0,
        });
        break;
        
      case BusinessScenario.saasGrowth:
        data.addAll({
          'monthly_recurring_revenue': 850000 + random.nextDouble() * 350000,
          'churn_rate': 3.5 + random.nextDouble() * 2.0,
          'customer_acquisition_cost': 120 + random.nextDouble() * 80,
          'lifetime_value': 1800 + random.nextDouble() * 800,
          'monthly_active_users': 45000 + random.nextInt(25000),
          'feature_adoption_rate': 65 + random.nextDouble() * 25,
          'support_ticket_volume': 150 + random.nextInt(100),
          'trial_to_paid_conversion': 18 + random.nextDouble() * 12,
        });
        break;
        
      case BusinessScenario.manufacturing:
        data.addAll({
          'production_efficiency': 78 + random.nextDouble() * 15,
          'defect_rate': 1.2 + random.nextDouble() * 1.5,
          'equipment_uptime': 92 + random.nextDouble() * 6,
          'supply_chain_cost': 2.8 + random.nextDouble() * 1.2,
          'inventory_accuracy': 96 + random.nextDouble() * 3,
          'energy_consumption': 450 + random.nextDouble() * 150,
          'safety_incidents': random.nextInt(5),
          'delivery_performance': 94 + random.nextDouble() * 5,
        });
        break;
        
      case BusinessScenario.fintech:
        data.addAll({
          'portfolio_performance': 12.5 + random.nextDouble() * 8.0,
          'risk_score': 6.5 + random.nextDouble() * 2.0,
          'transaction_volume': 25000000 + random.nextDouble() * 15000000,
          'fraud_detection_rate': 99.2 + random.nextDouble() * 0.7,
          'compliance_score': 94 + random.nextDouble() * 5,
          'customer_satisfaction': 4.3 + random.nextDouble() * 0.6,
          'processing_time': 2.1 + random.nextDouble() * 1.2,
          'regulatory_alerts': random.nextInt(8),
        });
        break;
        
      case BusinessScenario.healthtech:
        data.addAll({
          'patient_satisfaction': 87 + random.nextDouble() * 10,
          'readmission_rate': 8.5 + random.nextDouble() * 4.0,
          'staff_utilization': 82 + random.nextDouble() * 12,
          'treatment_success_rate': 91 + random.nextDouble() * 7,
          'wait_time_minutes': 25 + random.nextDouble() * 20,
          'cost_per_patient': 1850 + random.nextDouble() * 650,
          'bed_occupancy_rate': 75 + random.nextDouble() * 20,
          'quality_score': 92 + random.nextDouble() * 6,
        });
        break;
    }
    
    _currentSession = _currentSession!.copyWith(generatedData: data);
    await _saveSession();
  }

  void _initializeFeatures() {
    _features.clear();
    
    // Core features available to all roles/scenarios
    _features.addAll({
      'dashboard_overview': DemoFeature(
        id: 'dashboard_overview',
        name: 'Executive Dashboard',
        description: 'High-level KPI overview with real-time updates',
        icon: Icons.dashboard,
        color: const Color(0xFF007AFF),
      ),
      'advanced_analytics': DemoFeature(
        id: 'advanced_analytics',
        name: 'Advanced Analytics',
        description: 'Deep-dive analytics with interactive visualizations',
        icon: Icons.analytics,
        color: const Color(0xFF34C759),
      ),
      'ai_insights': DemoFeature(
        id: 'ai_insights',
        name: 'AI-Powered Insights',
        description: 'Automated insights and anomaly detection',
        icon: Icons.psychology,
        color: const Color(0xFFFF9500),
      ),
      'collaborative_workspace': DemoFeature(
        id: 'collaborative_workspace',
        name: 'Collaborative Analytics',
        description: 'Team collaboration and shared insights',
        icon: Icons.group,
        color: const Color(0xFFAF52DE),
      ),
      'predictive_modeling': DemoFeature(
        id: 'predictive_modeling',
        name: 'Predictive Modeling',
        description: 'Forecasting and trend prediction',
        icon: Icons.trending_up,
        color: const Color(0xFFFF2D92),
      ),
      'real_time_monitoring': DemoFeature(
        id: 'real_time_monitoring',
        name: 'Real-Time Monitoring',
        description: 'Live data streams and instant alerts',
        icon: Icons.monitor,
        color: const Color(0xFF5856D6),
      ),
    });
  }

  Future<void> _saveSession() async {
    if (_currentSession == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = jsonEncode(_currentSession!.toJson());
    await prefs.setString(_sessionKey, sessionJson);
    await prefs.setBool('onboarding_complete', _isOnboardingComplete);
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(_sessionKey);
    _isOnboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    
    if (sessionJson != null) {
      try {
        final sessionData = jsonDecode(sessionJson);
        _currentSession = DemoSession.fromJson(sessionData);
      } catch (e) {
        debugPrint('Error loading session: $e');
      }
    }
  }
  
  // User data management for immersive experiences
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = jsonEncode(userData);
    await prefs.setString(_userDataKey, userDataJson);
    debugPrint('Saved user data: ${userData['name']}');
  }
  
  Future<Map<String, dynamic>?> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataJson = prefs.getString(_userDataKey);
    
    if (userDataJson != null) {
      try {
        return jsonDecode(userDataJson);
      } catch (e) {
        debugPrint('Error loading user data: $e');
      }
    }
    return null;
  }
  
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressData = <String, dynamic>{};
    
    for (final feature in _features.values) {
      progressData[feature.id] = {
        'isCompleted': feature.isCompleted,
        'completedAt': feature.completedAt?.toIso8601String(),
        'interactionCount': feature.interactionCount,
      };
    }
    
    await prefs.setString(_progressKey, jsonEncode(progressData));
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);
    
    if (progressJson != null) {
      try {
        final progressData = jsonDecode(progressJson) as Map<String, dynamic>;
        
        for (final entry in progressData.entries) {
          final featureId = entry.key;
          final data = entry.value as Map<String, dynamic>;
          
          if (_features.containsKey(featureId)) {
            _features[featureId] = _features[featureId]!.copyWith(
              isCompleted: data['isCompleted'] ?? false,
              completedAt: data['completedAt'] != null 
                  ? DateTime.parse(data['completedAt'])
                  : null,
              interactionCount: data['interactionCount'] ?? 0,
            );
          }
        }
      } catch (e) {
        debugPrint('Error loading progress: $e');
      }
    }
  }

  Future<void> _saveInsights() async {
    final prefs = await SharedPreferences.getInstance();
    final insightsJson = jsonEncode(_insights.map((i) => i.toJson()).toList());
    await prefs.setString(_insightsKey, insightsJson);
  }

  Future<void> _loadInsights() async {
    final prefs = await SharedPreferences.getInstance();
    final insightsJson = prefs.getString(_insightsKey);
    
    if (insightsJson != null) {
      try {
        final insightsData = jsonDecode(insightsJson) as List;
        _insights.clear();
        _insights.addAll(
          insightsData.map((data) => DemoInsight.fromJson(data)),
        );
      } catch (e) {
        debugPrint('Error loading insights: $e');
      }
    }
  }

  // Get metrics for current scenario
  List<ScenarioMetric> getScenarioMetrics() {
    if (_currentSession?.generatedData == null) return [];
    
    final data = _currentSession!.generatedData;
    final scenario = _currentSession!.selectedScenario;
    final metrics = <ScenarioMetric>[];
    final random = Random();
    
    data.forEach((key, value) {
      if (value is num) {
        final previousValue = value * (0.8 + random.nextDouble() * 0.4);
        final isPositive = value > previousValue;
        
        metrics.add(ScenarioMetric(
          id: key,
          name: _formatMetricName(key),
          category: _getMetricCategory(key, scenario),
          value: value.toDouble(),
          previousValue: previousValue,
          unit: _getMetricUnit(key),
          isPositiveTrend: isPositive,
          timestamp: DateTime.now(),
        ));
      }
    });
    
    return metrics;
  }

  String _formatMetricName(String key) {
    return key.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  String _getMetricCategory(String key, BusinessScenario scenario) {
    switch (scenario) {
      case BusinessScenario.ecommerce:
        if (key.contains('revenue') || key.contains('value') || key.contains('cost')) {
          return 'Financial';
        } else if (key.contains('customer') || key.contains('conversion')) {
          return 'Customer';
        } else {
          return 'Operations';
        }
      case BusinessScenario.saasGrowth:
        if (key.contains('revenue') || key.contains('cost') || key.contains('value')) {
          return 'Financial';
        } else if (key.contains('user') || key.contains('customer') || key.contains('churn')) {
          return 'Customer';
        } else {
          return 'Product';
        }
      default:
        return 'General';
    }
  }

  String _getMetricUnit(String key) {
    if (key.contains('rate') || key.contains('percentage') || key.contains('efficiency')) {
      return '%';
    } else if (key.contains('revenue') || key.contains('cost') || key.contains('value')) {
      return '\$';
    } else if (key.contains('time') && key.contains('minutes')) {
      return 'min';
    } else if (key.contains('users') || key.contains('volume') || key.contains('incidents')) {
      return '';
    } else {
      return '';
    }
  }
}