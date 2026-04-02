import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  final String dbName = "ptl_app.db";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Backup & Restore")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.backup),
              label: const Text("Backup Database"),
              onPressed: () async {
                try {
                  final path = await backupDatabase(dbName);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Đã lưu backup tại: $path",
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi backup: $e")),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.restore),
              label: const Text("Restore Database"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                try {
                  await restoreDatabase(dbName);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Khôi phục thành công. Vui lòng khởi động lại app."),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Lỗi restore: $e")),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "⚠️ Khi khôi phục, dữ liệu hiện tại sẽ bị ghi đè. Hãy cẩn thận!",
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== BACKUP ======================
Future<String> backupDatabase(String dbName) async {
  final dbPath = await getDatabasesPath();
  final source = File(join(dbPath, dbName));

  // Người dùng chọn thư mục backup
  final outputDir = await FilePicker.platform.getDirectoryPath(
    dialogTitle: "Chọn thư mục để lưu file backup",
  );

  if (outputDir != null) {
    final backupPath = join(outputDir, "backup.db");
    await source.copy(backupPath);
    print("✅ Backup thành công: $backupPath");
    return backupPath;
  } else {
    throw Exception("Người dùng hủy chọn thư mục");
  }
}

// ====================== RESTORE ======================
Future<void> restoreDatabase(String dbName) async {
  final dbPath = await getDatabasesPath();
  final target = File(join(dbPath, dbName));

  // Người dùng chọn file backup
  final result = await FilePicker.platform.pickFiles(
    dialogTitle: "Chọn file backup để khôi phục",
    type: FileType.custom,
    allowedExtensions: ['db'],
  );

  if (result != null) {
    final backupFile = File(result.files.single.path!);
    await backupFile.copy(target.path);
    print("✅ Restore thành công!");
  } else {
    throw Exception("Người dùng chưa chọn file backup");
  }
}
