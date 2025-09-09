import 'package:flutter/material.dart';
import 'package:hanindyamom/screens/auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoDetectTimezone = true;
  String _selectedUnit = 'ml'; // ml or oz
  String _selectedLanguage = 'id'; // id or en

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildProfileSection(),
            const SizedBox(height: 24),
            
            // App Settings
            _buildSectionTitle('Pengaturan Aplikasi'),
            const SizedBox(height: 12),
            _buildAppSettings(),
            
            const SizedBox(height: 24),
            
            // Notifications
            _buildSectionTitle('Notifikasi'),
            const SizedBox(height: 12),
            _buildNotificationSettings(),
            
            const SizedBox(height: 24),
            
            // Data & Privacy
            _buildSectionTitle('Data & Privasi'),
            const SizedBox(height: 12),
            _buildDataSettings(),
            
            const SizedBox(height: 24),
            
            // About
            _buildSectionTitle('Tentang'),
            const SizedBox(height: 12),
            _buildAboutSection(),
            
            const SizedBox(height: 32),
            
            // Logout Button
            _buildLogoutButton(),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.person,
                color: theme.colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ibu Sari',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'sari@example.com',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur edit profil belum tersedia')),
                );
              },
            ),
          ],
        ),
      ),
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
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Bahasa'),
            subtitle: Text(_selectedLanguage == 'id' ? 'Indonesia' : 'English'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showLanguageDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.straighten),
            title: const Text('Unit Pengukuran'),
            subtitle: Text(_selectedUnit == 'ml' ? 'Mililiter (ml)' : 'Ounce (oz)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showUnitDialog,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: const Icon(Icons.access_time),
            title: const Text('Auto-detect Timezone'),
            subtitle: const Text('Otomatis mendeteksi zona waktu'),
            value: _autoDetectTimezone,
            onChanged: (value) {
              setState(() {
                _autoDetectTimezone = value;
              });
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
            title: const Text('Notifikasi'),
            subtitle: const Text('Aktifkan notifikasi pengingat'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          if (_notificationsEnabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Pengingat Feeding'),
              subtitle: const Text('Setiap 3 jam'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur pengaturan pengingat belum tersedia')),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.baby_changing_station),
              title: const Text('Pengingat Diaper'),
              subtitle: const Text('Setiap 4 jam'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur pengaturan pengingat belum tersedia')),
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
            title: const Text('Backup Data'),
            subtitle: const Text('Cadangkan data ke cloud'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur backup belum tersedia')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Download data dalam format CSV'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur export belum tersedia')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Hapus Semua Data', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Hapus semua data secara permanen'),
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
            title: const Text('Versi Aplikasi'),
            subtitle: const Text('1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAboutDialog();
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Kebijakan Privasi'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur kebijakan privasi belum tersedia')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Syarat & Ketentuan'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur syarat & ketentuan belum tersedia')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Bantuan & Dukungan'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur bantuan belum tersedia')),
              );
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
        label: const Text('Keluar', style: TextStyle(color: Colors.red)),
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
        title: const Text('Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Indonesia'),
              value: 'id',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
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
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua data? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur hapus data belum tersedia')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
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
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'HanindyaMom',
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
        const Text(
          'HanindyaMom adalah aplikasi terbaik untuk memantau '
          'perkembangan dan aktivitas bayi Anda.\n\n'
          'Dibuat dengan ❤️ untuk ibu-ibu Indonesia.',
        ),
      ],
    );
  }
}
