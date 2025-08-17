import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/utils/date_utils.dart';
import '../../../data/models/NhanVienCongTrinh.dart';
import '../../../services/nhan_vien_cong_trinh_service.dart';
import 'nhan_vien_cong_trinh_form_screen.dart';

class NhanVienCongTrinhListScreen extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;
  const NhanVienCongTrinhListScreen({Key? key, this.idCongTrinh, this.tenCongTrinh}) : super(key: key);

  @override
  State<NhanVienCongTrinhListScreen> createState() => _NhanVienCongTrinhListScreenState();
}

class _NhanVienCongTrinhListScreenState extends State<NhanVienCongTrinhListScreen> {
  late final NhanVienCongTrinhService _service;
  late Future<List<NhanVienCongTrinh>> _future;
  List<NhanVienCongTrinh> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _service = NhanVienCongTrinhService();
    _reload();
  }

  void _reload() {
    _future = _service.getByCongTrinh(widget.idCongTrinh);
  }
  void _openForm({NhanVienCongTrinh? nhanVienCongTrinh}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NhanVienCongTrinhFormScreen(item: nhanVienCongTrinh)),
    );
    if (result == true) {
      setState(() => _reload());
    }
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
      appBar: AppBar(
        title: widget.tenCongTrinh == null || widget.tenCongTrinh!.isEmpty
            ? const Text("Nhân viên công trình")
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nhân viên công trình",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            Text(
              widget.tenCongTrinh!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis, // tránh bị tràn
            ),
          ],
        ),
          backgroundColor: Colors.blue.shade100,
          foregroundColor: Colors.black,
          elevation: 0,
        actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _openForm(),
            ),
          ],
      ),
      body: FutureBuilder<List<NhanVienCongTrinh>>(
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
                final item = data[index];
                return Slidable(
                  key: ValueKey(item.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _openForm(nhanVienCongTrinh: item),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Sửa',
                      ),
                      SlidableAction(
                        onPressed: (context) async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Xác nhận"),
                              content: Text("Bạn có chắc muốn xóa ?"),
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
                            await _service.delete(item.id!);
                            setState(() => _reload());
                          }
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Xóa',
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Họ tên + số thứ tự
                        Text(
                          "${index + 1}. ${item.nhanVien?.hoTen ?? "Chưa đặt tên"}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        // Số điện thoại
                        Text(
                          item.nhanVien?.soDienThoai ?? "N/A",
                          style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.vaiTro ?? "",
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                        Text(
                          "${DateUtilsCore.formatDate(item.ngayBatDau)} - ${DateUtilsCore.formatDate(item.ngayKetThuc)}",
                          style: const TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),

                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     // MaterialPageRoute(
                    //     //     builder: (_) =>
                    //     //   //builder: (_) => XemChiTietNhatKyScreen(nhatKy: nk),
                    //     // ),
                    //   );
                    // },
                  ),
                );
              },
            );
          }
      )

    );
  }
}
