import 'package:flutter/material.dart';
import 'backup.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt")),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text("Backup & Restore Database"),
            subtitle: const Text("Xuất hoặc khôi phục dữ liệu"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BackupScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
