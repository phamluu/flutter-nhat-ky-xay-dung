import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../data/models/NhanVien.dart';
import '../../../services/nhan_vien_service.dart';
import 'ThemSuaNhanVienScreen.dart';
import 'XemChiTietNhanVienScreen.dart';

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

  void _deleteNhanVien(NhanVien nv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Bạn có chắc muốn xóa nhân viên '${nv.hoTen}'?"),
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
      await _service.deleteNhanVien(nv.id!);
      setState(() => _reload());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách nhân viên"),
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () =>_openForm(),
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
              return Slidable(
                key: ValueKey(nv.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => _openForm(nhanVien: nv),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Sửa',
                    ),
                    SlidableAction(
                      onPressed: (context) => _deleteNhanVien(nv),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Xóa',
                    ),
                  ],
                ),
                child: ListTile(
                  leading: nv.hinhAnh != null
                      ? CircleAvatar(backgroundImage: AssetImage(nv.hinhAnh!))
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(nv.hoTen ?? "Không tên",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(nv.email ?? ""),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => XemChiTietNhanVienScreen(nhanVien: nv),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
