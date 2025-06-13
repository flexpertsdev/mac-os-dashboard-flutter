import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/app_models.dart';


class UsersService extends ChangeNotifier {
  List<UserProfile> _users = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedRole = 'All';
  String _selectedDepartment = 'All';

  List<UserProfile> get users => _filterUsers();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedRole => _selectedRole;
  String get selectedDepartment => _selectedDepartment;

  List<String> get availableRoles => [
    'All', 'Admin', 'Manager', 'Developer', 'Designer', 'Analyst', 'Support'
  ];

  List<String> get availableDepartments => [
    'All', 'Engineering', 'Design', 'Marketing', 'Sales', 'Support', 'HR', 'Finance'
  ];

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadUsers();
      if (_users.isEmpty) {
        await _generateSampleUsers();
      }
    } catch (e) {
      debugPrint('Error initializing users: \$e');
      await _generateSampleUsers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<UserProfile> _filterUsers() {
    List<UserProfile> filtered = _users;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               user.department.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by role
    if (_selectedRole != 'All') {
      filtered = filtered.where((user) => user.role == _selectedRole).toList();
    }

    // Filter by department
    if (_selectedDepartment != 'All') {
      filtered = filtered.where((user) => user.department == _selectedDepartment).toList();
    }

    return filtered;
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateRoleFilter(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  void updateDepartmentFilter(String department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  Future<void> addUser(UserProfile user) async {
    _users.add(user);
    await _saveUsers();
    notifyListeners();
  }

  Future<void> updateUser(UserProfile updatedUser) async {
    final index = _users.indexWhere((user) => user.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      await _saveUsers();
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    _users.removeWhere((user) => user.id == userId);
    await _saveUsers();
    notifyListeners();
  }

  Future<void> toggleUserStatus(String userId) async {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isActive: !_users[index].isActive);
      await _saveUsers();
      notifyListeners();
    }
  }

  UserProfile? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString('users');
    
    if (usersJson != null) {
      final List<dynamic> usersList = json.decode(usersJson);
      _users = usersList.map((json) => UserProfile.fromJson(json)).toList();
    }
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = json.encode(_users.map((user) => user.toJson()).toList());
    await prefs.setString('users', usersJson);
  }

  Future<void> _generateSampleUsers() async {
    const uuid = Uuid();
    final sampleUsers = [
      UserProfile(
        id: uuid.v4(),
        name: 'Sarah Johnson',
        email: 'sarah.johnson@company.com',
        role: 'Manager',
        department: 'Engineering',
        joinDate: DateTime.now().subtract(const Duration(days: 365)),
        avatarUrl: "https://pixabay.com/get/g4af6dee87e5100ea5ac6cb53ed2e910d83fe3c8b3247ef90e4d5fe463a86a0d03f4065593cc832b2a2589f6aeb9e3b99fba71d430153b1b7e646fd26624b770f_1280.jpg",
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      UserProfile(
        id: uuid.v4(),
        name: 'Michael Chen',
        email: 'michael.chen@company.com',
        role: 'Developer',
        department: 'Engineering',
        joinDate: DateTime.now().subtract(const Duration(days: 180)),
        avatarUrl: "https://pixabay.com/get/g7f4db4c72d6313e53d0fcbf53d928bd32dfaa3676e4825ecdb3b610da29d80fd7dad23ce4c1ddbaf73055680077972ca2f8934474a74847ba2fa2b2bcc860662_1280.jpg",
        lastLogin: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      UserProfile(
        id: uuid.v4(),
        name: 'Emily Rodriguez',
        email: 'emily.rodriguez@company.com',
        role: 'Designer',
        department: 'Design',
        joinDate: DateTime.now().subtract(const Duration(days: 120)),
        avatarUrl: "https://pixabay.com/get/g76f8f43df9488c6162fe6674253817fbf5741290b20ea5ce0f19b2dd06286ec674fe1e4bd8608d196754be24d89fc433f94472627830fc6783b88345c689d8be_1280.jpg",
        lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      UserProfile(
        id: uuid.v4(),
        name: 'David Wilson',
        email: 'david.wilson@company.com',
        role: 'Analyst',
        department: 'Marketing',
        joinDate: DateTime.now().subtract(const Duration(days: 300)),
        avatarUrl: "https://pixabay.com/get/g3c0d2440e6360f9d92fe5b503fc8e9203f7414b8a84fffe24dddbcfcc4c279caf2a412422d0a5c95e5b7b3b9fb031dd50fa8e3e1fcae5ecd31fe6001515d69f0_1280.jpg",
        lastLogin: DateTime.now().subtract(const Duration(hours: 4)),
        isActive: false,
      ),
      UserProfile(
        id: uuid.v4(),
        name: 'Lisa Park',
        email: 'lisa.park@company.com',
        role: 'Support',
        department: 'Support',
        joinDate: DateTime.now().subtract(const Duration(days: 60)),
        avatarUrl: "https://pixabay.com/get/gbd98caba44ee54773244012bef8deab7d84c5e4db646ac9e357d9e12e8d0cc0e70e268777d515e58961ab262750d43a427cc7e261232f1838f1192bfd3dfcc0c_1280.jpg",
        lastLogin: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      UserProfile(
        id: uuid.v4(),
        name: 'James Thompson',
        email: 'james.thompson@company.com',
        role: 'Admin',
        department: 'Engineering',
        joinDate: DateTime.now().subtract(const Duration(days: 800)),
        avatarUrl: "https://pixabay.com/get/gcefb24eb77f7b2614ff768eefaa990b249caae56b329b26b3cb8e36c4c3568533d5b558dfd4273208b58705e3c474a24368388ecb01551c817c9f3882d8bbc65_1280.jpg",
        lastLogin: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];

    _users = sampleUsers;
    await _saveUsers();
  }

  Future<void> refreshUsers() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Update last login times for active users
    for (int i = 0; i < _users.length; i++) {
      if (_users[i].isActive) {
        _users[i] = _users[i].copyWith(
          lastLogin: DateTime.now().subtract(
            Duration(minutes: (i * 15) + 5)
          ),
        );
      }
    }

    await _saveUsers();
    _isLoading = false;
    notifyListeners();
  }

  Map<String, int> getUserStatistics() {
    return {
      'total': _users.length,
      'active': _users.where((user) => user.isActive).length,
      'inactive': _users.where((user) => !user.isActive).length,
      'newThisMonth': _users.where((user) => 
        user.joinDate.isAfter(DateTime.now().subtract(const Duration(days: 30)))
      ).length,
    };
  }
}