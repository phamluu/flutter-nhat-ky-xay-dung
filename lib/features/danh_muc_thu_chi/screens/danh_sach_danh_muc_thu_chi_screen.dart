import 'package:flutter/material.dart';

import '../../../data/models/DanhMucThuChi.dart';
import '../../../services/danh_muc_thu_chi_service.dart';
import '../../../services/thu_chi_service.dart';
import 'them_danh_muc_thu_chi_screen.dart';

class DanhSachDanhMucThuChiScreen extends StatefulWidget {
  const DanhSachDanhMucThuChiScreen({super.key});

  @override
  State<DanhSachDanhMucThuChiScreen> createState() => _DanhSachDanhMucThuChiScreenState();
}

class _DanhSachDanhMucThuChiScreenState extends State<DanhSachDanhMucThuChiScreen> {
  final _service = DanhMucThuChiService();
  late Future<List<DanhMucThuChi>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _service.getAll();
  }

  void _openForm({DanhMucThuChi? dm}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThemDanhMucThuChiScreen(danhMuc: dm),
      ),
    );
    if (result == true) {
      setState(() => _load());
    }
  }

  void _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa danh mục?'),
        content: const Text('Bạn chắc chắn muốn xóa danh mục này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirm != true) return;

    // Chặn xóa nếu danh mục đang được dùng
    final inUse = await ThuChiService().countByDanhMuc(id);
    if (inUse > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xóa: đang có $inUse khoản thu/chi dùng danh mục này')),
      );
      return;
    }

    await _service.delete(id);
    if (mounted) setState(() => _load());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh mục thu chi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openForm(),
          )
        ],
      ),
      body: FutureBuilder<List<DanhMucThuChi>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          if (list.isEmpty) return const Center(child: Text("Chưa có danh mục"));

          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final dm = list[i];
              return ListTile(
                title: Text(dm.ten),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(dm: dm),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _delete(dm.id!),
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
