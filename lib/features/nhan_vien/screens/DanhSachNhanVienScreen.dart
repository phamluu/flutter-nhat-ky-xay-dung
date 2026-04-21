import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/utils/AuthHelper.dart';
import '../../../core/utils/SyncColor.dart';
import '../../../core/utils/trang_thai_dong_bo.dart';
import '../../../data/models/NhanVien.dart';
import '../../../services/SyncService.dart';
import '../../../services/nhan_vien_service.dart';
import 'ThemSuaNhanVienScreen.dart';
import 'XemChiTietNhanVienScreen.dart';

class DanhSachNhanVienScreen extends StatefulWidget {
  const DanhSachNhanVienScreen({super.key});

  @override
  State<DanhSachNhanVienScreen> createState() => _DanhSachNhanVienScreenState();
}

class _DanhSachNhanVienScreenState extends State<DanhSachNhanVienScreen> {
  bool isLoggedIn = false;
  final _service = NhanVienService();
  SyncService syn = SyncService();
  late Future<List<NhanVien>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
    checkLogin();
  }

  void _reload() {
    _future = _service.getAllNhanVien();
  }
  Future<void> checkLogin() async {
    final loggedIn = await AuthHelper.isLoggedIn();
    setState(() {
      isLoggedIn = loggedIn;
    });
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

  Future<void> _syncNhanVien(NhanVien nv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Đồng bộ nhân viên '${nv.hoTen}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Không"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Đồng bộ", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await syn.syncOneNhanVien(nv);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã đồng bộ nhân viên"),
          backgroundColor: Colors.green,
        ),
      );

      setState(() => _reload());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi đồng bộ: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelSyncNhanVien(NhanVien nv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Hủy đồng bộ nhân viên '${nv.hoTen}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Không"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hủy sync", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await syn.cancelSyncNhanVien(nv);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đã hủy đồng bộ"),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() => _reload());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
                  extentRatio: 0.65,
                  children: [
                    if(isLoggedIn) ...[
                      CustomSlidableAction(
                        onPressed: (context) {
                          if (nv.isSynced == TrangThaiDongBo.dadongbo.value) {
                            _cancelSyncNhanVien(nv);
                          } else {
                            _syncNhanVien(nv);
                          }
                        },
                        backgroundColor: Colors.transparent,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: nv.isSynced == TrangThaiDongBo.dadongbo.value
                                ? Colors.orange
                                : Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            nv.isSynced == TrangThaiDongBo.dadongbo.value
                                ? Icons.sync_disabled
                                : Icons.sync,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    CustomSlidableAction(
                      onPressed: (context) => _openForm(nhanVien: nv),
                      backgroundColor: Colors.transparent,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                    CustomSlidableAction(
                      onPressed: (context) => _deleteNhanVien(nv),
                      backgroundColor: Colors.transparent,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: nv.hinhAnh != null
                      ? CircleAvatar(backgroundImage: AssetImage(nv.hinhAnh!))
                      : const CircleAvatar(child: Icon(Icons.person)),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(nv.hoTen ?? "Không tên",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      SyncColor.icon(nv.isSynced)
                    ],
                  ),
                  subtitle: Text(nv.email ?? ""),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => XemChiTietNhanVienScreen(nhanVien: nv),
                      ),
                    ).then((result) {
                      if (result == true) {
                        setState(() => _reload());
                      }
                    });
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
