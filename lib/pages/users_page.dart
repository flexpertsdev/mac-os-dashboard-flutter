import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_models.dart';
import '../services/users_service.dart';
import '../utils/responsive_helper.dart';
import '../pages/user_creation_wizard.dart';
import '../pages/user_profile_explorer.dart';
import '../pages/user_impact_analysis.dart';


class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsersService>(context, listen: false).initialize();
    });
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
          child: Consumer<UsersService>(
            builder: (context, usersService, child) {
              return RefreshIndicator(
                onRefresh: usersService.refreshUsers,
                child: SingleChildScrollView(
                  padding: ResponsiveHelper.getContentPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, theme, usersService),
                      const SizedBox(height: 24),
                      _buildStatistics(context, theme, usersService),
                      const SizedBox(height: 24),
                      _buildFilters(context, theme, usersService, isMobile),
                      const SizedBox(height: 24),
                      if (usersService.isLoading)
                        _buildLoadingState(theme)
                      else
                        _buildUsersList(context, theme, usersService, isMobile),
                      const SizedBox(height: 100), // Bottom padding for mobile
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, UsersService usersService) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.people_outline,
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
                'User Management',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage team members, roles, and permissions',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        FloatingActionButton.extended(
          onPressed: () => _showAddUserDialog(context, usersService),
          icon: const Icon(Icons.add),
          label: const Text('Add User'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context, ThemeData theme, UsersService usersService) {
    final stats = usersService.getUserStatistics();
    final isMobile = ResponsiveHelper.isMobile(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isMobile ? 1.4 : 1.8,
      children: [
        _buildStatCard(theme, 'Total Users', stats['total'].toString(), 
          Icons.people, theme.colorScheme.primary),
        _buildStatCard(theme, 'Active Users', stats['active'].toString(), 
          Icons.check_circle, theme.colorScheme.secondary),
        _buildStatCard(theme, 'Inactive Users', stats['inactive'].toString(), 
          Icons.cancel, theme.colorScheme.error),
        _buildStatCard(theme, 'New This Month', stats['newThisMonth'].toString(), 
          Icons.trending_up, theme.colorScheme.tertiary),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Card(
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, ThemeData theme, UsersService usersService, bool isMobile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Search & Filters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isMobile) ...[
              _buildSearchField(theme, usersService),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildRoleFilter(theme, usersService)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDepartmentFilter(theme, usersService)),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(flex: 2, child: _buildSearchField(theme, usersService)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRoleFilter(theme, usersService)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDepartmentFilter(theme, usersService)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, UsersService usersService) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Search users...',
        prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: usersService.updateSearchQuery,
    );
  }

  Widget _buildRoleFilter(ThemeData theme, UsersService usersService) {
    return DropdownButtonFormField<String>(
      value: usersService.selectedRole,
      decoration: InputDecoration(
        labelText: 'Role',
        prefixIcon: Icon(Icons.work, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: usersService.availableRoles.map((role) {
        return DropdownMenuItem(value: role, child: Text(role));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          usersService.updateRoleFilter(value);
        }
      },
    );
  }

  Widget _buildDepartmentFilter(ThemeData theme, UsersService usersService) {
    return DropdownButtonFormField<String>(
      value: usersService.selectedDepartment,
      decoration: InputDecoration(
        labelText: 'Department',
        prefixIcon: Icon(Icons.business, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      items: usersService.availableDepartments.map((dept) {
        return DropdownMenuItem(value: dept, child: Text(dept));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          usersService.updateDepartmentFilter(value);
        }
      },
    );
  }

  Widget _buildUsersList(BuildContext context, ThemeData theme, UsersService usersService, bool isMobile) {
    final users = usersService.users;

    if (users.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Users (${users.length})',
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
          itemCount: users.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildUserCard(context, theme, users[index], usersService);
          },
        ),
      ],
    );
  }

  Widget _buildUserCard(BuildContext context, ThemeData theme, UserProfile user, UsersService usersService) {
    return Card(
      child: InkWell(
        onTap: () => _showUserDetails(context, user, usersService),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(user.avatarUrl),
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: user.isActive
                                ? theme.colorScheme.secondary.withOpacity(0.1)
                                : theme.colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.isActive ? 'Active' : 'Inactive',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: user.isActive
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.work,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user.role} • ${user.department}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatLastLogin(user.lastLogin),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleUserAction(context, value, user, usersService),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit User')),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(user.isActive ? 'Deactivate' : 'Activate'),
                  ),
                  const PopupMenuItem(value: 'delete', child: Text('Delete User')),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Column(
      children: List.generate(5, (index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(width: 16),
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
                Icons.people_outline,
                size: 64,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No users found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, UsersService usersService) {
    // Navigate to immersive user creation wizard instead of modal
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UserCreationWizard(),
        fullscreenDialog: true,
      ),
    );
  }

  void _showUserDetails(BuildContext context, UserProfile user, UsersService usersService) {
    // Navigate to immersive user profile explorer instead of modal
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserProfileExplorer(
          userData: {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'role': user.role,
            'department': user.department,
            'avatar': user.avatar,
            'isActive': user.isActive,
            'lastLogin': user.lastLogin,
            'permissions': ['View Dashboards', 'Edit Reports'], // Mock permissions
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _handleUserAction(BuildContext context, String action, UserProfile user, UsersService usersService) {
    switch (action) {
      case 'edit':
        // Navigate to user profile explorer in edit mode instead of modal
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfileExplorer(
              userData: {
                'id': user.id,
                'name': user.name,
                'email': user.email,
                'role': user.role,
                'department': user.department,
                'avatar': user.avatar,
                'isActive': user.isActive,
                'lastLogin': user.lastLogin,
                'permissions': ['View Dashboards', 'Edit Reports'], // Mock permissions
              },
            ),
            fullscreenDialog: true,
          ),
        );
        break;
      case 'toggle':
        usersService.toggleUserStatus(user.id);
        break;
      case 'delete':
        // Navigate to immersive impact analysis instead of simple confirmation
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserImpactAnalysis(user: user),
            fullscreenDialog: true,
          ),
        );
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, UserProfile user, UsersService usersService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              usersService.deleteUser(user.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} has been deleted'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _UserFormDialog extends StatefulWidget {
  final UsersService usersService;
  final bool isEditing;
  final UserProfile? user;

  const _UserFormDialog({
    required this.usersService,
    required this.isEditing,
    this.user,
  });

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _selectedRole;
  late String _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _selectedRole = widget.user?.role ?? 'Developer';
    _selectedDepartment = widget.user?.department ?? 'Engineering';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.isEditing ? 'Edit User' : 'Add New User'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Role',
                prefixIcon: Icon(Icons.work),
              ),
              items: widget.usersService.availableRoles.skip(1).map((role) {
                return DropdownMenuItem(value: role, child: Text(role));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration: const InputDecoration(
                labelText: 'Department',
                prefixIcon: Icon(Icons.business),
              ),
              items: widget.usersService.availableDepartments.skip(1).map((dept) {
                return DropdownMenuItem(value: dept, child: Text(dept));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartment = value!;
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
          onPressed: _saveUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: Text(widget.isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final user = UserProfile(
        id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        email: _emailController.text,
        role: _selectedRole,
        department: _selectedDepartment,
        joinDate: widget.user?.joinDate ?? DateTime.now(),
        avatarUrl: widget.user?.avatarUrl ?? "https://pixabay.com/get/g1ebc8475b6064116ec991b0a11ead274169cec2282ff121053dc62d22a6b11a21c69d5f69d0892abc6ece1ee09cc9b913b428c7d17d40821946869be859729fb_1280.jpg",
        lastLogin: widget.user?.lastLogin ?? DateTime.now(),
        isActive: widget.user?.isActive ?? true,
      );

      if (widget.isEditing) {
        widget.usersService.updateUser(user);
      } else {
        widget.usersService.addUser(user);
      }

      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isEditing 
            ? 'User updated successfully!' 
            : 'User added successfully!'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }
}

class _UserDetailsDialog extends StatelessWidget {
  final UserProfile user;
  final UsersService usersService;

  const _UserDetailsDialog({
    required this.user,
    required this.usersService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.avatarUrl),
            radius: 16,
          ),
          const SizedBox(width: 8),
          Text(user.name),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(Icons.email, 'Email', user.email),
          _buildDetailRow(Icons.work, 'Role', user.role),
          _buildDetailRow(Icons.business, 'Department', user.department),
          _buildDetailRow(Icons.calendar_today, 'Join Date', 
            '${user.joinDate.day}/${user.joinDate.month}/${user.joinDate.year}'),
          _buildDetailRow(Icons.access_time, 'Last Login', 
            _formatDateTime(user.lastLogin)),
          _buildDetailRow(Icons.circle, 'Status', 
            user.isActive ? 'Active' : 'Inactive',
            color: user.isActive ? theme.colorScheme.secondary : theme.colorScheme.error),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text('\$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}