import 'package:flutter/material.dart';

import '../../../data/models/NhanVienCongTrinh.dart';
import '../../../services/nhan_vien_cong_trinh_service.dart';
import 'nhan_vien_cong_trinh_form_screen.dart';

class NhanVienCongTrinhListScreen extends StatefulWidget {
  const NhanVienCongTrinhListScreen({super.key});

  @override
  State<NhanVienCongTrinhListScreen> createState() => _NhanVienCongTrinhListScreenState();
}

class _NhanVienCongTrinhListScreenState extends State<NhanVienCongTrinhListScreen> {
  final _service = NhanVienCongTrinhService();
  List<NhanVienCongTrinh> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _service.getAll();
    setState(() {
      _items = data;
      _loading = false;
    });
  }

  Future<void> _delete(NhanVienCongTrinh item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa nhân viên công trình?'),
        content: const Text('Bạn có chắc chắn muốn xóa?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (ok == true) {
      await _service.delete(item.id!);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhân viên công trình')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text('NV: ${item.idNhanVien} | CT: ${item.idCongTrinh ?? "-"}'),
            subtitle: Text(
                '${item.ngayBatDau ?? ""} → ${item.ngayKetThuc ?? ""}\nVai trò: ${item.vaiTro ?? ""}'),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _delete(item),
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NhanVienCongTrinhFormScreen(item: item),
                ),
              );
              if (result == true) _loadData();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NhanVienCongTrinhFormScreen()),
          );
          if (result == true) _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
