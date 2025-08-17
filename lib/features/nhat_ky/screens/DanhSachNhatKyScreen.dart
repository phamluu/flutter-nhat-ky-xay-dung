import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../data/models/NhatKy.dart';
import '../../../services/nhat_ky_service.dart';
import 'ThemSuaNhatKyScreen.dart';
import 'XemChiTietNhatKyScreen.dart';

class DanhSachNhatKyScreen extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;
  const DanhSachNhatKyScreen({Key? key, this.idCongTrinh, this.tenCongTrinh}) : super(key: key);

  @override
  State<DanhSachNhatKyScreen> createState() => _DanhSachNhatKyScreenState();
}

class _DanhSachNhatKyScreenState extends State<DanhSachNhatKyScreen> {
  late final NhatKyService _service;
  late Future<List<NhatKy>> _future;
  @override
  void initState() {
    super.initState();
    _service = NhatKyService();
    _reload();
  }

  void _reload() {
    _future = _service.getAllNhatKy(widget.idCongTrinh);
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
          title: widget.tenCongTrinh == null || widget.tenCongTrinh!.isEmpty
              ? const Text("Nhật ký công trình")
              : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Nhật ký",
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
              return Slidable(
                key: ValueKey(nk.id),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => _openForm(nhatKy: nk),
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
                            content: Text("Bạn có chắc muốn xóa nhật ký '${nk.tenNhatKy}'?"),
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
                  title: Text(
                    "${index + 1}. ${nk.tenNhatKy ?? "Chưa đặt tên"}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text((nk.ngayTrienKhai ?? ""), style: const TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => XemChiTietNhatKyScreen(nhatKy: nk),
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
