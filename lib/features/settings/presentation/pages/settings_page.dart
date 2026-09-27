import 'dart:io';

import 'package:flutter/material.dart';

import 'manage_accounts_page.dart';
import 'manage_labels_page.dart';
import 'edit_profile_page.dart';
import '../../services/profile_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ProfileService _profileService = ProfileService();
  bool _isDarkMode = false;
  String _userName = 'Pengguna';
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final data = await _profileService.loadProfile();
    setState(() {
      _userName = data['name'] ?? 'Pengguna';
      _photoPath = data['photoPath'];
    });
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('Fitur ini sedang dalam tahap pengembangan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Reset Database',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Semua data transaksi, akun, dan label akan dihapus secara permanen. Apakah Anda yakin?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Hapus Semua Data',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atur'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue,
              backgroundImage: _photoPath != null
                  ? FileImage(File(_photoPath!))
                  : null,
              child: _photoPath == null
                  ? const Icon(Icons.person, color: Colors.white, size: 32)
                  : null,
            ),
            title: Text(
              _userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: const Text('Ketuk untuk mengedit profil'),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfilePage(),
                ),
              );
              if (result == true) {
                _loadProfileData();
              }
            },
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.cloud_sync, color: Colors.grey),
            title: const Text('Google Drive Backup'),
            subtitle: const Text(
              'Coming Soon',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
            onTap: _showComingSoonDialog,
          ),
          const Divider(height: 1),

          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Mode Gelap'),
            value: _isDarkMode,
            onChanged: (val) {
              setState(() => _isDarkMode = val);
            },
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.account_balance_wallet_rounded),
            title: const Text('Kelola Akun'),
            subtitle: const Text('Tambah, edit, atau hapus daftar akun'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageAccountsPage(),
                ),
              );
            },
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.label_rounded),
            title: const Text('Kelola Label'),
            subtitle: const Text(
              'Tambah, edit, atau hapus daftar label/kategori',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageLabelsPage(),
                ),
              );
            },
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.data_object_rounded),
            title: const Text('Backup & Restore (JSON)'),
            subtitle: const Text('Ekspor atau impor data mentah database'),
            onTap: () {},
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.table_view_rounded),
            title: const Text('Ekspor ke CSV'),
            subtitle: const Text('Simpan log transaksi sebagai spreadsheet'),
            onTap: () {},
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            title: const Text(
              'Reset Database',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Hapus seluruh data aplikasi secara permanen',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: _showResetConfirmation,
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
