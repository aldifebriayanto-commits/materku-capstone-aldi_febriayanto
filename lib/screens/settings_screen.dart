import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/material_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isOfflineMode = false;
  bool _autoDownload = false;
  bool _showNotifications = true;
  String _downloadQuality = 'Medium';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isOfflineMode = prefs.getBool('offline_mode') ?? false;
      _autoDownload = prefs.getBool('auto_download') ?? false;
      _showNotifications = prefs.getBool('show_notifications') ?? true;
      _downloadQuality = prefs.getString('download_quality') ?? 'Medium';
    });
  }

  Future<void> _saveOfflineMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offline_mode', value);
    setState(() => _isOfflineMode = value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Mode Offline Aktif' : 'Mode Online Aktif',
          ),
          backgroundColor: value ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  Future<void> _saveAutoDownload(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_download', value);
    setState(() => _autoDownload = value);
  }

  Future<void> _saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_notifications', value);
    setState(() => _showNotifications = value);
  }

  // ✅ FIXED: Sebelumnya salah pakai getString, seharusnya setString
  Future<void> _saveDownloadQuality(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('download_quality', value); // ✅ FIXED: setString bukan getString
    setState(() => _downloadQuality = value);
  }

  Future<void> _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Cache'),
        content: const Text('Apakah Anda yakin ingin menghapus semua cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<MaterialProvider>();
              await provider.clearAllDownloads();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: const Color(0xFF3B82F6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF3B82F6),
                  Color(0xFF8B5CF6),
                ],
              ),
            ),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF3B82F6)),
                ),
                SizedBox(height: 12),
                Text(
                  'Guest User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'guest@materku.app',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Mode Offline
          _buildSection(
            title: 'Mode Aplikasi',
            children: [
              _buildSwitchTile(
                icon: Icons.offline_bolt,
                title: 'Mode Offline',
                subtitle: _isOfflineMode
                    ? 'Aplikasi tidak akan mengakses internet'
                    : 'Aplikasi akan menggunakan koneksi internet',
                value: _isOfflineMode,
                onChanged: _saveOfflineMode,
                activeColor: Colors.orange,
              ),
            ],
          ),

          // Download Settings
          _buildSection(
            title: 'Pengaturan Download',
            children: [
              _buildSwitchTile(
                icon: Icons.download,
                title: 'Auto Download',
                subtitle: 'Otomatis download saat menambahkan ke favorit',
                value: _autoDownload,
                onChanged: _saveAutoDownload,
              ),
              _buildDropdownTile(
                icon: Icons.high_quality,
                title: 'Kualitas Download',
                value: _downloadQuality,
                items: ['Low', 'Medium', 'High'],
                onChanged: _saveDownloadQuality,
              ),
            ],
          ),

          // Notifications
          _buildSection(
            title: 'Notifikasi',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Notifikasi',
                subtitle: 'Tampilkan notifikasi untuk update materi',
                value: _showNotifications,
                onChanged: _saveNotifications,
              ),
            ],
          ),

          // Storage
          _buildSection(
            title: 'Penyimpanan',
            children: [
              _buildTile(
                icon: Icons.storage,
                title: 'Kelola Penyimpanan',
                subtitle: 'Lihat dan kelola file yang tersimpan',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur ini akan segera hadir'),
                    ),
                  );
                },
              ),
              _buildTile(
                icon: Icons.delete_sweep,
                title: 'Hapus Cache',
                subtitle: 'Bersihkan file sementara',
                onTap: _clearCache,
                trailing: const Icon(Icons.chevron_right),
              ),
            ],
          ),

          // About
          _buildSection(
            title: 'Tentang',
            children: [
              _buildTile(
                icon: Icons.info,
                title: 'Tentang Aplikasi',
                subtitle: 'MaterKu v1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'MaterKu',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.school, size: 48),
                    children: const [
                      Text('Repository Materi Kuliah'),
                      SizedBox(height: 8),
                      Text('Aplikasi untuk berbagi materi pembelajaran'),
                    ],
                  );
                },
              ),
              _buildTile(
                icon: Icons.privacy_tip,
                title: 'Kebijakan Privasi',
                subtitle: 'Baca kebijakan privasi kami',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur ini akan segera hadir'),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    Color? activeColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (activeColor ?? Colors.deepPurple).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: activeColor ?? Colors.deepPurple),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor ?? Colors.deepPurple,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.deepPurple),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}