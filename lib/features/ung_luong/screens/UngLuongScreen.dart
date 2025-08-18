import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/services/nhan_vien_service.dart';
import '../../../data/models/NhanVien.dart';
import '../../../data/models/UngLuong.dart';
import '../../../services/ung_luong_service.dart';
import 'UngLuongFormDialog.dart';
import 'package:intl/intl.dart';
class UngLuongScreen extends StatefulWidget {
  const UngLuongScreen({Key? key}) : super(key: key);

  @override
  State<UngLuongScreen> createState() => _UngLuongScreenState();
}

class _UngLuongScreenState extends State<UngLuongScreen> {
  List<Ungluong> _list = [];
  List<NhanVien> nhanViens = [];
  late final UngLuongService service;
  late final NhanVienService _nhanVienService;

  bool _isLoadingNhanViens = true;
  @override
  void initState() {
    super.initState();
    service = UngLuongService();
    _nhanVienService = NhanVienService();
    _loadData();
    _loadNhanViens();
  }
  Future<void> _loadNhanViens() async {
    nhanViens = await _nhanVienService.getAllNhanVien();
    setState(() => _isLoadingNhanViens = false);
  }
  Future<void> _loadData() async {
    final data = await service.getAllUngLuong();
    setState(() => _list = data);
  }

  void _showForm({Ungluong? ungLuong}) {
    showDialog(
      context: context,
      builder: (_) => UngLuongFormDialog(
        ungLuong: ungLuong,
        nhanViens: nhanViens,
        onSave: (u) async {
          if (u.id == null) {
            await service.addUngLuong(u);
          } else {
            await service.updateUngLuong(u);
          }
          _loadData();
        },
      ),
    );
  }

  void _delete(Ungluong u) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa ứng lương này không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirm == true) {
      await service.deleteUngLuong(u.id!);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý ứng lương')),
      body: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (_, index) {
          final u = _list[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(u.nhanVien?.hoTen ?? 'Không tên'),
              subtitle: Text(
                  'Số tiền: ${u.soTien ?? 0}\nNgày ứng: ${u.ngayUng != null ? DateFormat('dd/MM/yyyy').format(u.ngayUng!) : "Chưa có"}\nLý do: ${u.lyDo ?? ""}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () => _showForm(ungLuong: u), icon: const Icon(Icons.edit)),
                  IconButton(onPressed: () => _delete(u), icon: const Icon(Icons.delete, color: Colors.red)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
