import 'package:flutter/material.dart';

class MetricCardData {
  final String title;
  final String value;
  final String subtitle;
  final double trendPercentage;
  final bool isPositiveTrend;
  final IconData icon;
  final Color color;

  const MetricCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trendPercentage,
    required this.isPositiveTrend,
    required this.icon,
    required this.color,
  });
}

class ChartDataPoint {
  final String label;
  final double value;
  final DateTime? date;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.date,
  });
}

class ChartCardData {
  final String title;
  final String subtitle;
  final List<ChartDataPoint> data;
  final ChartType type;
  final Color primaryColor;

  const ChartCardData({
    required this.title,
    required this.subtitle,
    required this.data,
    required this.type,
    required this.primaryColor,
  });
}

enum ChartType {
  line,
  bar,
  pie,
  area,
}

class NavigationItem {
  final String label;
  final IconData icon;
  final String route;
  final int? badgeCount;
  final bool isSelected;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.route,
    this.badgeCount,
    this.isSelected = false,
  });

  NavigationItem copyWith({
    String? label,
    IconData? icon,
    String? route,
    int? badgeCount,
    bool? isSelected,
  }) {
    return NavigationItem(
      label: label ?? this.label,
      icon: icon ?? this.icon,
      route: route ?? this.route,
      badgeCount: badgeCount ?? this.badgeCount,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class DashboardState {
  final List<MetricCardData> metrics;
  final List<ChartCardData> charts;
  final List<NavigationItem> navigationItems;
  final bool isLoading;
  final String selectedNavRoute;
  final bool isSidebarCollapsed;

  const DashboardState({
    required this.metrics,
    required this.charts,
    required this.navigationItems,
    this.isLoading = false,
    this.selectedNavRoute = '/dashboard',
    this.isSidebarCollapsed = false,
  });

  DashboardState copyWith({
    List<MetricCardData>? metrics,
    List<ChartCardData>? charts,
    List<NavigationItem>? navigationItems,
    bool? isLoading,
    String? selectedNavRoute,
    bool? isSidebarCollapsed,
  }) {
    return DashboardState(
      metrics: metrics ?? this.metrics,
      charts: charts ?? this.charts,
      navigationItems: navigationItems ?? this.navigationItems,
      isLoading: isLoading ?? this.isLoading,
      selectedNavRoute: selectedNavRoute ?? this.selectedNavRoute,
      isSidebarCollapsed: isSidebarCollapsed ?? this.isSidebarCollapsed,
    );
  }
}