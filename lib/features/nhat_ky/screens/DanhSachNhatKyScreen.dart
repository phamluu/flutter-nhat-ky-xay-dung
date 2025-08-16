import 'package:flutter/material.dart';
import '../../../data/models/NhatKy.dart';
import '../../../services/nhat_ky_service.dart';
import 'ThemSuaNhatKyScreen.dart';

class DanhSachNhatKyScreen extends StatefulWidget {
  const DanhSachNhatKyScreen({super.key});

  @override
  State<DanhSachNhatKyScreen> createState() => _DanhSachNhatKyScreenState();
}

class _DanhSachNhatKyScreenState extends State<DanhSachNhatKyScreen> {
  final _service = NhatKyService();
  late Future<List<NhatKy>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _service.getAllNhatKy();
  }

  void _openForm({NhatKy? nhatKy}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ThemSuaNhatKyScreen(nhatKy: nhatKy)),
    );
    if (result == true) {
      setState(() => _reload());
    }
  }

  void _deleteNhatKy(int id) async {
    await _service.deleteNhatKy(id);
    setState(() => _reload());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhật ký công trình"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: FutureBuilder<List<NhatKy>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text("Chưa có nhật ký nào"));
          }
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final nk = data[index];
              return ListTile(
                title: Text((index+1).toString() + '. ' + (nk.tenNhatKy ?? "Chưa đặt tên")),
                subtitle: Text(nk.noiDung ?? ""),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _openForm(nhatKy: nk),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Xác nhận"),
                            content: Text("Bạn có chắc muốn xóa công trình '${nk.tenNhatKy}'?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Hủy"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Xóa"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await _service.deleteNhatKy(nk.id!);
                          setState(() {
                            _reload(); // load lại danh sách
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
