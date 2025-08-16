import 'package:flutter/material.dart';

import '../../../data/models/NhanVien.dart';
import '../../../services/nhan_vien_service.dart';
import 'ThemSuaNhanVienScreen.dart';

class DanhSachNhanVienScreen extends StatefulWidget {
  const DanhSachNhanVienScreen({super.key});

  @override
  State<DanhSachNhanVienScreen> createState() => _DanhSachNhanVienScreenState();
}

class _DanhSachNhanVienScreenState extends State<DanhSachNhanVienScreen> {
  final _service = NhanVienService();
  late Future<List<NhanVien>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _service.getAllNhanVien();
  }

  void _openForm({NhanVien? nhanVien}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThemSuaNhanVienScreen(nhanVien: nhanVien),
      ),
    );
    if (result == true) {
      setState(() => _reload());
    }
  }

  void _deleteNhanVien(int id) async {
    await _service.deleteNhanVien(id);
    setState(() => _reload());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách nhân viên"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          ),
        ],
      ),
      body: FutureBuilder<List<NhanVien>>(
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
            return const Center(child: Text("Chưa có nhân viên nào"));
          }
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final nv = data[index];
              return ListTile(
                leading: nv.hinhAnh != null
                    ? CircleAvatar(backgroundImage: AssetImage(nv.hinhAnh!))
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(nv.hoTen ?? "Không tên"),
                subtitle: Text(nv.email ?? ""),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _openForm(nhanVien: nv),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteNhanVien(nv.id!),
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
