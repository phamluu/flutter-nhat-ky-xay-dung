import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhat_ky_xay_dung/data/models/NhanVienCongTrinh.dart';
import 'package:nhat_ky_xay_dung/services/nhan_vien_cong_trinh_service.dart';
import 'package:nhat_ky_xay_dung/services/nhan_vien_service.dart';
import '../../../core/utils/currencyFormat.dart';
import '../../../data/models/NhanVien.dart';
import '../../../data/models/UngLuong.dart';
import '../../../services/ung_luong_service.dart';
import 'UngLuongFormDialog.dart';
import 'package:intl/intl.dart';
class UngLuongScreen extends StatefulWidget {
  final int? idCongTrinh;
  final String? tenCongTrinh;
  const UngLuongScreen({Key? key, this.idCongTrinh, this.tenCongTrinh}) : super(key: key);

  @override
  State<UngLuongScreen> createState() => _UngLuongScreenState();
}

class _UngLuongScreenState extends State<UngLuongScreen> {
  List<Ungluong> _list = [];
  List<NhanVien> nhanViens = [];
  List<NhanVienCongTrinh> nhanVienCongTrinhs = [];
  late final UngLuongService service;
  late final NhanVienService _nhanVienService;
  late final NhanVienCongTrinhService _nhanVienCongTrinhService;
  bool _isLoadingNhanViens = true;
  @override
  void initState() {
    super.initState();
    service = UngLuongService();
    _nhanVienService = NhanVienService();
    _nhanVienCongTrinhService = NhanVienCongTrinhService();

    _loadData();
    _loadNhanViens();
    _loadNhanVienCongTrinhs();
  }
  Future<void> _loadNhanViens() async {
    nhanViens = await _nhanVienService.getAllNhanVien();
    setState(() => _isLoadingNhanViens = false);
  }
  Future<void> _loadNhanVienCongTrinhs() async {
    nhanVienCongTrinhs = await _nhanVienCongTrinhService.getAll();
    setState(() => _isLoadingNhanViens = false);
  }
  Future<void> _loadData() async {
    List<Ungluong> data;

    if (widget.idCongTrinh != null) {
      data = await service.getUngLuongCongTrinh(widget.idCongTrinh);
    } else {
      data = await service.getAllUngLuong();
    }

    setState(() => _list = data);
  }


  void _showForm({Ungluong? ungLuong}) {
    showDialog(
      context: context,
      builder: (_) => UngLuongFormDialog(
        ungLuong: ungLuong,
        nhanViens: nhanViens,
        nhanVienCongTrinhs: nhanVienCongTrinhs,
        onSave: (u) async {
          try{
            if (u.id == null) {
              await service.addUngLuong(u);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Thêm chi lương thành công", style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              await service.updateUngLuong(u);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Cập nhật chi lương thành công", style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Lỗi: ${e.toString()}")),
            );
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
        content: const Text('Bạn có chắc muốn xóa ứng lương này không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await service.deleteUngLuong(u.id!);
        setState(() {
          _list.removeWhere((item) => item.id == u.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Xóa ứng lương thành công", style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Xóa thất bại: ${e.toString()}",
                style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue,title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quản lý ứng lương",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (widget.idCongTrinh != null)
            Text(
              widget.tenCongTrinh ?? "",
              style: const TextStyle(fontSize: 13, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),),
      body: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (_, index) {
          final u = _list[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child:Slidable(key: ValueKey(u.id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(), // hiệu ứng trượt
                extentRatio: 0.4, // chiếm 40% chiều rộng
                children: [
                  SlidableAction(
                    onPressed: (_) async {
                      _showForm(ungLuong: u);
                    },
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Sửa',
                  ),
                  SlidableAction(
                    onPressed: (_) => _delete(u),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Xóa',
                  ),
                ],
              ),
              child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50, // nền nhẹ, dịu mắt
                borderRadius: BorderRadius.circular(12), // bo góc mềm
                border: Border.all(
                  color: Colors.grey.shade50, // border nhẹ nhàng
                  width: 1,
                ),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Text(u.nhanVien?.hoTen ?? 'Không tên'),
                subtitle: Text(
                    'Số tiền: ${currencyFormat.format(u.soTien ?? 0) }'
                        '\nCông trình: ${u.nhanVienCongTrinh?.congTrinh?.ten}'
                        '\nNgày ứng: ${u.ngayUng != null ? DateFormat('dd/MM/yyyy').format(u.ngayUng!) : "Chưa có"}'
                        '\nLý do: ${u.lyDo ?? ""}'),

              ),
            ),)

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
