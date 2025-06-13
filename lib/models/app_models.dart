import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final DateTime joinDate;
  final String avatarUrl;
  final bool isActive;
  final DateTime lastLogin;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.joinDate,
    required this.avatarUrl,
    this.isActive = true,
    required this.lastLogin,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'department': department,
    'joinDate': joinDate.toIso8601String(),
    'avatarUrl': avatarUrl,
    'isActive': isActive,
    'lastLogin': lastLogin.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
    department: json['department'],
    joinDate: DateTime.parse(json['joinDate']),
    avatarUrl: json['avatarUrl'],
    isActive: json['isActive'] ?? true,
    lastLogin: DateTime.parse(json['lastLogin']),
  );

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? department,
    DateTime? joinDate,
    String? avatarUrl,
    bool? isActive,
    DateTime? lastLogin,
  }) => UserProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    role: role ?? this.role,
    department: department ?? this.department,
    joinDate: joinDate ?? this.joinDate,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    isActive: isActive ?? this.isActive,
    lastLogin: lastLogin ?? this.lastLogin,
  );
}

class Report {
  final String id;
  final String title;
  final String description;
  final DateTime createdDate;
  final DateTime? scheduledDate;
  final String createdBy;
  final ReportType type;
  final ReportStatus status;
  final Map<String, dynamic> parameters;
  final String? filePath;

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.createdDate,
    this.scheduledDate,
    required this.createdBy,
    required this.type,
    this.status = ReportStatus.pending,
    required this.parameters,
    this.filePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'createdDate': createdDate.toIso8601String(),
    'scheduledDate': scheduledDate?.toIso8601String(),
    'createdBy': createdBy,
    'type': type.name,
    'status': status.name,
    'parameters': parameters,
    'filePath': filePath,
  };

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    createdDate: DateTime.parse(json['createdDate']),
    scheduledDate: json['scheduledDate'] != null 
      ? DateTime.parse(json['scheduledDate']) 
      : null,
    createdBy: json['createdBy'],
    type: ReportType.values.firstWhere((e) => e.name == json['type']),
    status: ReportStatus.values.firstWhere((e) => e.name == json['status']),
    parameters: json['parameters'],
    filePath: json['filePath'],
  );
}

enum ReportType {
  analytics,
  users,
  financial,
  performance,
  custom,
}

enum ReportStatus {
  pending,
  processing,
  completed,
  failed,
  scheduled,
}

class AppSettings {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final bool pushNotificationsEnabled;
  final String language;
  final String dateFormat;
  final String currency;
  final bool autoRefresh;
  final int refreshInterval;
  final Map<String, bool> featureFlags;

  const AppSettings({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.pushNotificationsEnabled = true,
    this.language = 'en',
    this.dateFormat = 'MM/dd/yyyy',
    this.currency = 'USD',
    this.autoRefresh = true,
    this.refreshInterval = 30,
    this.featureFlags = const {},
  });

  Map<String, dynamic> toJson() => {
    'isDarkMode': isDarkMode,
    'notificationsEnabled': notificationsEnabled,
    'pushNotificationsEnabled': pushNotificationsEnabled,
    'language': language,
    'dateFormat': dateFormat,
    'currency': currency,
    'autoRefresh': autoRefresh,
    'refreshInterval': refreshInterval,
    'featureFlags': featureFlags,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    isDarkMode: json['isDarkMode'] ?? false,
    notificationsEnabled: json['notificationsEnabled'] ?? true,
    pushNotificationsEnabled: json['pushNotificationsEnabled'] ?? true,
    language: json['language'] ?? 'en',
    dateFormat: json['dateFormat'] ?? 'MM/dd/yyyy',
    currency: json['currency'] ?? 'USD',
    autoRefresh: json['autoRefresh'] ?? true,
    refreshInterval: json['refreshInterval'] ?? 30,
    featureFlags: Map<String, bool>.from(json['featureFlags'] ?? {}),
  );

  AppSettings copyWith({
    bool? isDarkMode,
    bool? notificationsEnabled,
    bool? pushNotificationsEnabled,
    String? language,
    String? dateFormat,
    String? currency,
    bool? autoRefresh,
    int? refreshInterval,
    Map<String, bool>? featureFlags,
  }) => AppSettings(
    isDarkMode: isDarkMode ?? this.isDarkMode,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    language: language ?? this.language,
    dateFormat: dateFormat ?? this.dateFormat,
    currency: currency ?? this.currency,
    autoRefresh: autoRefresh ?? this.autoRefresh,
    refreshInterval: refreshInterval ?? this.refreshInterval,
    featureFlags: featureFlags ?? this.featureFlags,
  );
}

class AnalyticsFilter {
  final DateTime startDate;
  final DateTime endDate;
  final List<String> metrics;
  final String groupBy;
  final Map<String, dynamic> additionalFilters;

  const AnalyticsFilter({
    required this.startDate,
    required this.endDate,
    required this.metrics,
    this.groupBy = 'day',
    this.additionalFilters = const {},
  });

  Map<String, dynamic> toJson() => {
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'metrics': metrics,
    'groupBy': groupBy,
    'additionalFilters': additionalFilters,
  };

  factory AnalyticsFilter.fromJson(Map<String, dynamic> json) => AnalyticsFilter(
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    metrics: List<String>.from(json['metrics']),
    groupBy: json['groupBy'] ?? 'day',
    additionalFilters: json['additionalFilters'] ?? {},
  );
}