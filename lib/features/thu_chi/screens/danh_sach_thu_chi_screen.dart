import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/ThuChi.dart';
import '../../../data/models/DanhMucThuChi.dart';
import '../../../services/thu_chi_service.dart';
import '../../../services/danh_muc_thu_chi_service.dart';
import 'them_thu_chi_screen.dart';

class DanhSachThuChiScreen extends StatefulWidget {
  const DanhSachThuChiScreen({super.key});

  @override
  State<DanhSachThuChiScreen> createState() => _DanhSachThuChiScreenState();
}

class _DanhSachThuChiScreenState extends State<DanhSachThuChiScreen> {
  final _thuChiService = ThuChiService();
  final _danhMucService = DanhMucThuChiService();

  late Future<List<ThuChi>> _futureThuChi;
  late Future<List<DanhMucThuChi>> _futureDanhMuc;

  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _futureThuChi = _thuChiService.getAll();
    _futureDanhMuc = _danhMucService.getAll();
  }

  void _openForm({ThuChi? tc}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThemThuChiScreen(thuChi: tc),
      ),
    );
    if (result == true) setState(() => _load());
  }

  void _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa khoản thu/chi?'),
        content: const Text('Bạn chắc chắn muốn xóa khoản này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirm == true) {
      await _thuChiService.delete(id);
      if (mounted) setState(() => _load());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách thu chi"),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _openForm())
        ],
      ),
      body: FutureBuilder<List<ThuChi>>(
        future: _futureThuChi,
        builder: (context, snapshotThuChi) {
          if (!snapshotThuChi.hasData) return const Center(child: CircularProgressIndicator());
          final thuChiList = snapshotThuChi.data!;
          if (thuChiList.isEmpty) return const Center(child: Text("Chưa có thu chi"));

          return FutureBuilder<List<DanhMucThuChi>>(
            future: _futureDanhMuc,
            builder: (context, snapshotDanhMuc) {
              if (!snapshotDanhMuc.hasData) return const SizedBox();
              final danhMucList = snapshotDanhMuc.data!;

              // Nhóm theo danh mục
              final Map<int, List<ThuChi>> grouped = {};
              for (var tc in thuChiList) {
                grouped.putIfAbsent(tc.idDanhMucThuChi!, () => []).add(tc);
              }

              return ListView(
                children: danhMucList.map((dm) {
                  final items = grouped[dm.id] ?? [];
                  if (items.isEmpty) return const SizedBox.shrink();
                  return ExpansionTile(
                    title: Text(dm.ten),
                    children: items.map((tc) {
                      return ListTile(
                        title: Text("${tc.loai == 1 ? "Thu" : "Chi"}: ${_currencyFormat.format(tc.soTien)}"),
                        subtitle: Text(tc.ghiChu ?? ""),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(tc: tc)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _delete(tc.id!),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
