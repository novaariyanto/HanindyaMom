import 'package:flutter/material.dart';
import 'package:hanindyamom/screens/auth/login_screen.dart';
import 'package:hanindyamom/screens/settings/edit_profile_screen.dart';
import 'package:hanindyamom/screens/settings/privacy_policy_screen.dart';
import 'package:hanindyamom/screens/settings/terms_screen.dart';
import 'package:hanindyamom/screens/settings/support_screen.dart';
import 'package:hanindyamom/services/profile_service.dart';
import 'package:hanindyamom/services/settings_service.dart';
import 'package:hanindyamom/l10n/app_localizations.dart';
import 'package:hanindyamom/providers/locale_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoDetectTimezone = true;
  String _selectedUnit = 'ml'; // ml or oz
  bool _loading = true;
  String? _error;
  String _profileName = '';
  String _profileEmail = '';
  String? _profilePhoto;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadProfile();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final s = await SettingsService().getSettings();
      setState(() {
        _selectedUnit = s.unit;
        _notificationsEnabled = s.notifications;
        // timezone dari API tidak otomatis detect di UI ini
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final p = await ProfileService().getProfile();
      if (!mounted) return;
      setState(() {
        _profileName = p.name;
        _profileEmail = p.email;
        _profilePhoto = p.photo;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(context.tr('settings.title')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text('Gagal memuat: $_error'))
              : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(),
            const SizedBox(height: 24),
            
            // App Settings
            _buildSectionTitle(context.tr('settings.appSettings')),
            const SizedBox(height: 12),
            _buildAppSettings(),
            
            const SizedBox(height: 24),
            
            // Notifications
            _buildSectionTitle(context.tr('settings.notifications')),
            const SizedBox(height: 12),
            _buildNotificationSettings(),
            
            const SizedBox(height: 24),
            
            // Data & Privacy
            _buildSectionTitle(context.tr('settings.dataPrivacy')),
            const SizedBox(height: 12),
            _buildDataSettings(),
            
            const SizedBox(height: 24),
            
            // About
            _buildSectionTitle(context.tr('settings.about')),
            const SizedBox(height: 12),
            _buildAboutSection(),
            
            const SizedBox(height: 32),
            
            // Logout Button
            _buildLogoutButton(),
            
            const SizedBox(height: 16),
          ],
        ),
      )),
    );
  }

  Widget _buildProfileSection() {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildProfileAvatar(theme),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _profileName.isEmpty ? '—' : _profileName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _profileEmail.isEmpty ? '—' : _profileEmail,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
                if (updated == true) {
                  _loadProfile();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(ThemeData theme) {
    final url = ProfileService.buildPhotoUrl(_profilePhoto);
    ImageProvider? image;
    if (url != null && url.isNotEmpty) {
      image = NetworkImage(url);
    }
    return CircleAvatar(
      radius: 30,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      backgroundImage: image,
      child: image == null ? Icon(Icons.person, color: theme.colorScheme.primary, size: 30) : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildAppSettings() {
    final currentLangCode = (context.watch<LocaleProvider>().locale?.languageCode) ?? Localizations.localeOf(context).languageCode;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.tr('settings.language')),
            subtitle: Text((currentLangCode == 'id') ? context.tr('settings.language.id') : context.tr('settings.language.en')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showLanguageDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: Text(context.tr('settings.measurementUnit')),
            subtitle: Text(_selectedUnit == 'ml' ? context.tr('settings.unit.ml') : context.tr('settings.unit.oz')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showUnitDialog,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.access_time),
            title: Text(context.tr('settings.autoTimezone.title')),
            subtitle: Text(context.tr('settings.autoTimezone.subtitle')),
            value: _autoDetectTimezone,
            onChanged: (value) {
              setState(() {
                _autoDetectTimezone = value;
              });
              _saveSettings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications),
            title: Text(context.tr('settings.notifications.title')),
            subtitle: Text(context.tr('settings.notifications.subtitle')),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _saveSettings();
            },
          ),
          if (_notificationsEnabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(context.tr('settings.reminder.feeding.title')),
              subtitle: Text(context.tr('settings.reminder.feeding.subtitle')),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('common.feature_not_available'))),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.baby_changing_station),
              title: Text(context.tr('settings.reminder.diaper.title')),
              subtitle: Text(context.tr('settings.reminder.diaper.subtitle')),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('common.feature_not_available'))),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataSettings() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: Text(context.tr('settings.backup.title')),
            subtitle: Text(context.tr('settings.backup.subtitle')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('common.feature_not_available'))),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(context.tr('settings.export.title')),
            subtitle: Text(context.tr('settings.export.subtitle')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('common.feature_not_available'))),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(context.tr('settings.delete.title'), style: const TextStyle(color: Colors.red)),
            subtitle: Text(context.tr('settings.delete.subtitle')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
            onTap: _showDeleteDataDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(context.tr('about.version')),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAboutDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text(context.tr('about.privacy_policy')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(context.tr('about.terms')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TermsScreen()));
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help),
            title: Text(context.tr('about.support')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SupportScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, color: Colors.red),
        label: Text(context.tr('settings.logout'), style: const TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings.language')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(context.tr('settings.language.id')),
              value: 'id',
              groupValue: (context.read<LocaleProvider>().locale?.languageCode) ?? Localizations.localeOf(context).languageCode,
              onChanged: (value) {
                context.read<LocaleProvider>().setLocale('id');
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: Text(context.tr('settings.language.en')),
              value: 'en',
              groupValue: (context.read<LocaleProvider>().locale?.languageCode) ?? Localizations.localeOf(context).languageCode,
              onChanged: (value) {
                context.read<LocaleProvider>().setLocale('en');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUnitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unit Pengukuran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Mililiter (ml)'),
              value: 'ml',
              groupValue: _selectedUnit,
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value!;
                });
                _saveSettings();
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('Ounce (oz)'),
              value: 'oz',
              groupValue: _selectedUnit,
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value!;
                });
                _saveSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    try {
      await SettingsService().update(
        timezone: 'Asia/Jakarta',
        unit: _selectedUnit,
        notifications: _notificationsEnabled,
      );
    } catch (_) {}
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings.delete.confirmTitle')),
        content: Text(context.tr('settings.delete.confirmText')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr('common.cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(context.tr('common.feature_not_available'))),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.tr('common.delete')),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('settings.logout.confirmTitle')),
        content: Text(context.tr('settings.logout.confirmText')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.tr('common.cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(context.tr('settings.logout')),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: context.tr('app.title'),
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          Icons.baby_changing_station,
          color: Theme.of(context).colorScheme.primary,
          size: 30,
        ),
      ),
      children: [
        Text(context.tr('about.description')),
      ],
    );
  }
}
