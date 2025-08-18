import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../data/models/LuongCoBan.dart';
import '../../../data/models/NhanVien.dart';
import '../../../services/luong_co_ban_service.dart';
import '../../../services/nhan_vien_service.dart';
import '../widgets/ConfirmDeleteDialog.dart';
import '../widgets/LuongCoBanFormDialog.dart';

class LuongCoBanScreen extends StatefulWidget {
  const LuongCoBanScreen({super.key});

  @override
  State<LuongCoBanScreen> createState() => _LuongCoBanScreenState();
}

class _LuongCoBanScreenState extends State<LuongCoBanScreen> {
  final LuongCoBanService _service = LuongCoBanService();
  final NhanVienService _nhanVienService = NhanVienService();
  final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");

  LuongCoBanViewModel _viewModel = LuongCoBanViewModel();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final vm = await _service.getAllGroupedByNhanVien();
      setState(() {
        _viewModel = vm;
      });
    } catch (e) {
      debugPrint("Lỗi load dữ liệu: $e");
    }
  }

  void _showForm({Luongcoban? luong}) {
    showDialog(
      context: context,
      builder: (_) => LuongCoBanFormDialog(
        luong: luong,
        nhanViens: _viewModel.luongNhanViens.map((e) => e.nhanVien).toList(),
        onSave: (newLuong) async {
          try {
            if (luong == null) {
              await _service.addLuongCoBan(newLuong);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Thêm lương thành công", style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              );
            } else {
              await _service.updateLuongCoBan(newLuong);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Cập nhật lương thành công", style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              );
            }
            _loadData();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Lỗi: ${e.toString()}")),
            );
          }
        },
      ),
    );
  }

  void _delete(int id) {
    showDialog(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        message: "Bạn có chắc chắn muốn xóa không?",
        onConfirm: () async {
          try {
            await _service.deleteLuongCoBan(id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Xóa lương thành công")),
            );
            _loadData();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Xóa thất bại: ${e.toString()}")),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lương cơ bản"),
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        itemCount: _viewModel.luongNhanViens.length,
        itemBuilder: (context, index) {
          final nvModel = _viewModel.luongNhanViens[index];
          return Column(
            children: [
              ExpansionTile(
                title: Text("${index + 1}. ${nvModel.nhanVien.hoTen ?? "Không có tên"}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // canh trái
                  children: [
                    Text('Mức lương hiện tại: ' + currencyFormat.format(nvModel.mucLuongHienTai ?? 0)),
                    Text('Số lần tăng lương: ' + nvModel.soLanTangLuong.toString()),
                  ],
                ),
                children: nvModel.luongCoBans.map((luong) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Slidable(
                      key: ValueKey(luong.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(), // hiệu ứng trượt
                        extentRatio: 0.4, // chiếm 40% chiều rộng
                        children: [
                          SlidableAction(
                            onPressed: (_) async {
                              _showForm(luong: luong);
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Sửa',
                          ),
                          SlidableAction(
                            onPressed: (_) async {
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
                                await _service.deleteLuongCoBan(luong.id!);
                                setState(() {
                                  _loadData();
                                });
                              }
                            },
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
                          title: Text("Mức lương: ${currencyFormat.format(luong.mucLuong ?? 0)}"),
                          subtitle: Text(
                            "Ngày áp dụng: ${luong.ngayApDung != null ? DateFormat("dd/MM/yyyy").format(luong.ngayApDung!) : "Chưa có"}\n"
                                "Ghi chú: ${luong.ghiChu ?? ""}",
                          )
                        ),
                      ),
                    )
                  );
                }).toList(),
              ),
              Divider(
                color: Colors.grey.shade300,
                thickness: 1,
                height: 1,
              ),
            ],
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
