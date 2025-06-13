import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';
import '../utils/responsive_helper.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  AppSettings _settings = const AppSettings();
  bool _isLoading = false;

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
    _loadSettings();
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
          child: SingleChildScrollView(
            padding: ResponsiveHelper.getContentPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, theme),
                const SizedBox(height: 24),
                if (isMobile) ...[
                  _buildMobileSettings(context, theme),
                ] else ...[
                  _buildDesktopSettings(context, theme),
                ],
                const SizedBox(height: 100), // Bottom padding for mobile
              ],
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
            Icons.settings_outlined,
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
                'Settings & Preferences',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customize your app experience and manage preferences',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSettings(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buildAppearanceSection(theme),
        const SizedBox(height: 16),
        _buildNotificationsSection(theme),
        const SizedBox(height: 16),
        _buildDataSection(theme),
        const SizedBox(height: 16),
        _buildAboutSection(theme),
      ],
    );
  }

  Widget _buildDesktopSettings(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildAppearanceSection(theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildNotificationsSection(theme)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDataSection(theme)),
            const SizedBox(width: 16),
            Expanded(child: _buildAboutSection(theme)),
          ],
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Appearance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              theme,
              'Dark Mode',
              'Switch between light and dark themes',
              Icons.dark_mode,
              Switch(
                value: _settings.isDarkMode,
                onChanged: (value) => _updateSettings(_settings.copyWith(isDarkMode: value)),
              ),
            ),
            const Divider(),
            _buildSettingTile(
              theme,
              'Language',
              'Choose your preferred language',
              Icons.language,
              DropdownButton<String>(
                value: _settings.language,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'es', child: Text('Español')),
                  DropdownMenuItem(value: 'fr', child: Text('Français')),
                  DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _updateSettings(_settings.copyWith(language: value));
                  }
                },
              ),
            ),
            const Divider(),
            _buildSettingTile(
              theme,
              'Date Format',
              'Customize date display format',
              Icons.date_range,
              DropdownButton<String>(
                value: _settings.dateFormat,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/dd/yyyy')),
                  DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('dd/MM/yyyy')),
                  DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('yyyy-MM-dd')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _updateSettings(_settings.copyWith(dateFormat: value));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Notifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSettingTile(
              theme,
              'Enable Notifications',
              'Receive app notifications',
              Icons.notifications_active,
              Switch(
                value: _settings.notificationsEnabled,
                onChanged: (value) => _updateSettings(_settings.copyWith(notificationsEnabled: value)),
              ),
            ),
            const Divider(),
            _buildSettingTile(
              theme,
              'Push Notifications',
              'Receive push notifications on your device',
              Icons.phone_android,
              Switch(
                value: _settings.pushNotificationsEnabled,
                onChanged: _settings.notificationsEnabled 
                  ? (value) => _updateSettings(_settings.copyWith(pushNotificationsEnabled: value))
                  : null,
              ),
            ),
            const Divider(),
            _buildSettingTile(
              theme,
              'Auto Refresh',
              'Automatically refresh data',
              Icons.refresh,
              Switch(
                value: _settings.autoRefresh,
                onChanged: (value) => _updateSettings(_settings.copyWith(autoRefresh: value)),
              ),
            ),
            if (_settings.autoRefresh) ...[
              const Divider(),
              _buildSettingTile(
                theme,
                'Refresh Interval',
                'How often to refresh data (seconds)',
                Icons.timer,
                DropdownButton<int>(
                  value: _settings.refreshInterval,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 15, child: Text('15s')),
                    DropdownMenuItem(value: 30, child: Text('30s')),
                    DropdownMenuItem(value: 60, child: Text('1m')),
                    DropdownMenuItem(value: 300, child: Text('5m')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _updateSettings(_settings.copyWith(refreshInterval: value));
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storage, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Data Management',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              theme,
              'Export Data',
              'Download your data as JSON',
              Icons.download,
              () => _exportData(),
            ),
            const Divider(),
            _buildActionTile(
              theme,
              'Import Data',
              'Import data from backup file',
              Icons.upload,
              () => _importData(),
            ),
            const Divider(),
            _buildActionTile(
              theme,
              'Clear Cache',
              'Clear app cache and temporary files',
              Icons.clear_all,
              () => _clearCache(),
            ),
            const Divider(),
            _buildActionTile(
              theme,
              'Reset Settings',
              'Reset all settings to default',
              Icons.restore,
              () => _resetSettings(),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'About',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoTile(theme, 'App Version', '1.0.0'),
            const Divider(),
            _buildInfoTile(theme, 'Build Number', '100'),
            const Divider(),
            _buildInfoTile(theme, 'Last Updated', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
            const Divider(),
            _buildActionTile(
              theme,
              'Privacy Policy',
              'View our privacy policy',
              Icons.privacy_tip,
              () => _showPrivacyPolicy(),
            ),
            const Divider(),
            _buildActionTile(
              theme,
              'Terms of Service',
              'View terms of service',
              Icons.description,
              () => _showTermsOfService(),
            ),
            const Divider(),
            _buildActionTile(
              theme,
              'Contact Support',
              'Get help and support',
              Icons.support,
              () => _contactSupport(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    Widget trailing,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildActionTile(
    ThemeData theme,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDestructive ? theme.colorScheme.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('app_settings');
      
      if (settingsJson != null) {
        // In a real app, you would parse the JSON here
        // For now, we'll use default settings
      }
    } catch (e) {
      debugPrint('Error loading settings: \$e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSettings(AppSettings newSettings) async {
    setState(() {
      _settings = newSettings;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_settings', _settings.toJson().toString());
    } catch (e) {
      debugPrint('Error saving settings: \$e');
    }
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Your data has been exported successfully! The file has been saved to your downloads folder.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _importData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('Select a backup file to import your data. This will overwrite your current data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Data imported successfully! 📂'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            },
            child: const Text('Select File'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear all cached data and temporary files. The app may take longer to load initially.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Cache cleared successfully! 🧹'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              foregroundColor: Theme.of(context).colorScheme.onTertiary,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('This will reset all settings to their default values. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateSettings(const AppSettings());
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Settings reset to default! ⚙️'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a sample privacy policy. In a real app, this would contain the actual privacy policy content explaining how user data is collected, used, and protected.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a sample terms of service. In a real app, this would contain the actual terms and conditions that users must agree to when using the application.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact our support team:'),
            SizedBox(height: 16),
            Text('📧 Email: support@example.com'),
            SizedBox(height: 8),
            Text('📞 Phone: +1 (555) 123-4567'),
            SizedBox(height: 8),
            Text('💬 Live Chat: Available 24/7'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Opening support chat... 💬'),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            },
            child: const Text('Open Chat'),
          ),
        ],
      ),
    );
  }
}