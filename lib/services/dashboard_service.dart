import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';

class DashboardService extends ChangeNotifier {
  DashboardState _state = const DashboardState(
    metrics: [],
    charts: [],
    navigationItems: [],
  );

  DashboardState get state => _state;

  void _updateState(DashboardState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> initialize() async {
    _updateState(_state.copyWith(isLoading: true));
    
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate loading
    
    final metrics = _generateSampleMetrics();
    final charts = _generateSampleCharts();
    final navigationItems = _generateNavigationItems();
    
    _updateState(DashboardState(
      metrics: metrics,
      charts: charts,
      navigationItems: navigationItems,
      isLoading: false,
    ));
  }

  void toggleSidebar() {
    _updateState(_state.copyWith(
      isSidebarCollapsed: !_state.isSidebarCollapsed,
    ));
  }

  void selectNavigation(String route) {
    final updatedNavItems = _state.navigationItems.map((item) {
      return item.copyWith(isSelected: item.route == route);
    }).toList();

    _updateState(_state.copyWith(
      selectedNavRoute: route,
      navigationItems: updatedNavItems,
    ));
  }

  List<MetricCardData> _generateSampleMetrics() {
    return [
      const MetricCardData(
        title: 'Revenue',
        value: '\$124,592',
        subtitle: 'This month',
        trendPercentage: 12.5,
        isPositiveTrend: true,
        icon: Icons.trending_up,
        color: Color(0xFF34C759),
      ),
      const MetricCardData(
        title: 'Active Users',
        value: '8,549',
        subtitle: 'Last 30 days',
        trendPercentage: 8.2,
        isPositiveTrend: true,
        icon: Icons.people,
        color: Color(0xFF007AFF),
      ),
      const MetricCardData(
        title: 'Conversion Rate',
        value: '3.24%',
        subtitle: 'Current period',
        trendPercentage: -2.1,
        isPositiveTrend: false,
        icon: Icons.swap_horiz,
        color: Color(0xFFFF9500),
      ),
      const MetricCardData(
        title: 'Page Views',
        value: '52,847',
        subtitle: 'This week',
        trendPercentage: 15.3,
        isPositiveTrend: true,
        icon: Icons.visibility,
        color: Color(0xFF5856D6),
      ),
      const MetricCardData(
        title: 'Orders',
        value: '1,247',
        subtitle: 'This month',
        trendPercentage: 22.8,
        isPositiveTrend: true,
        icon: Icons.shopping_cart,
        color: Color(0xFF32D74B),
      ),
      const MetricCardData(
        title: 'Support Tickets',
        value: '89',
        subtitle: 'Open tickets',
        trendPercentage: -11.2,
        isPositiveTrend: true,
        icon: Icons.headset_mic,
        color: Color(0xFFFF453A),
      ),
    ];
  }

  List<ChartCardData> _generateSampleCharts() {
    return [
      ChartCardData(
        title: 'Revenue Trend',
        subtitle: 'Last 7 days',
        type: ChartType.line,
        primaryColor: const Color(0xFF34C759),
        data: [
          const ChartDataPoint(label: 'Mon', value: 12500),
          const ChartDataPoint(label: 'Tue', value: 15300),
          const ChartDataPoint(label: 'Wed', value: 18200),
          const ChartDataPoint(label: 'Thu', value: 16800),
          const ChartDataPoint(label: 'Fri', value: 21500),
          const ChartDataPoint(label: 'Sat', value: 19200),
          const ChartDataPoint(label: 'Sun', value: 22100),
        ],
      ),
      ChartCardData(
        title: 'User Acquisition',
        subtitle: 'By channel',
        type: ChartType.pie,
        primaryColor: const Color(0xFF007AFF),
        data: [
          const ChartDataPoint(label: 'Organic', value: 35),
          const ChartDataPoint(label: 'Paid Search', value: 25),
          const ChartDataPoint(label: 'Social Media', value: 20),
          const ChartDataPoint(label: 'Direct', value: 15),
          const ChartDataPoint(label: 'Email', value: 5),
        ],
      ),
      ChartCardData(
        title: 'Monthly Performance',
        subtitle: 'Last 6 months',
        type: ChartType.bar,
        primaryColor: const Color(0xFF5856D6),
        data: [
          const ChartDataPoint(label: 'Jan', value: 85),
          const ChartDataPoint(label: 'Feb', value: 92),
          const ChartDataPoint(label: 'Mar', value: 78),
          const ChartDataPoint(label: 'Apr', value: 96),
          const ChartDataPoint(label: 'May', value: 88),
          const ChartDataPoint(label: 'Jun', value: 94),
        ],
      ),
    ];
  }

  List<NavigationItem> _generateNavigationItems() {
    return [
      const NavigationItem(
        label: 'Dashboard',
        icon: Icons.dashboard,
        route: '/dashboard',
        isSelected: true,
      ),
      const NavigationItem(
        label: 'Analytics',
        icon: Icons.analytics,
        route: '/analytics',
      ),
      const NavigationItem(
        label: 'Users',
        icon: Icons.people_outline,
        route: '/users',
        badgeCount: 3,
      ),
      const NavigationItem(
        label: 'Reports',
        icon: Icons.assessment,
        route: '/reports',
      ),
      const NavigationItem(
        label: 'Settings',
        icon: Icons.settings_outlined,
        route: '/settings',
      ),
    ];
  }

  Future<void> refreshData() async {
    _updateState(_state.copyWith(isLoading: true));
    
    await Future.delayed(const Duration(milliseconds: 600));
    
    final metrics = _generateSampleMetrics();
    final charts = _generateSampleCharts();
    
    _updateState(_state.copyWith(
      metrics: metrics,
      charts: charts,
      isLoading: false,
    ));
  }
}