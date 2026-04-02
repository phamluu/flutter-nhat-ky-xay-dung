import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<void> backupDatabase(String dbName) async {
  try {
    // Lấy đường dẫn database gốc
    final dbPath = await getDatabasesPath();
    final source = File(join(dbPath, dbName));

    // Cho user chọn nơi lưu (chọn file, ví dụ trong thư mục Download)
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: "Chọn nơi lưu file backup",
      type: FileType.any, // Cho phép chọn tất cả loại file
    );

    if (result != null && result.files.single.path != null) {
      final savePath = result.files.single.path!;

      // Đọc dữ liệu từ DB gốc
      final bytes = await source.readAsBytes();

      // Ghi dữ liệu vào file user chọn
      final outFile = File(savePath);
      await outFile.writeAsBytes(bytes, flush: true);

      print("✅ Backup thành công: $savePath");
    } else {
      print("❌ Người dùng hủy chọn nơi lưu");
    }
  } catch (e) {
    print("❌ Lỗi backup: $e");
  }
}

Future<void> restoreDatabase(String dbName) async {
  try {
    final dbPath = await getDatabasesPath();
    final target = File(join(dbPath, dbName));

    final dir = await getExternalStorageDirectory();
    final backup = File(join(dir!.path, 'backup.db'));

    if (await backup.exists()) {
      await backup.copy(target.path);
      print("✅ Restore thành công!");
    } else {
      print("❌ Không tìm thấy file backup.");
    }
  } catch (e) {
    print("❌ Lỗi restore: $e");
  }
}
