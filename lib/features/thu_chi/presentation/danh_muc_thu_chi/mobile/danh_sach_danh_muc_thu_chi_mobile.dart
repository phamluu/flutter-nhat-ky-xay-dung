import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../data/models/DanhMucThuChi.dart';
import '../../../data/services/danh_muc_thu_chi_service.dart';
import '../widgets/DeleteDanhMucButton.dart';
import 'DanhMucActionButton.dart';
import 'them_danh_muc_thu_chi_mobile.dart';

class DanhSachDanhMucThuChiMobile extends StatefulWidget {
  const DanhSachDanhMucThuChiMobile({super.key});

  @override
  State<DanhSachDanhMucThuChiMobile> createState() => _DanhSachDanhMucThuChiMobileState();
}

class _DanhSachDanhMucThuChiMobileState extends State<DanhSachDanhMucThuChiMobile> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh mục thu chi"),
        elevation: 0,
        actions: [
          OpenFormButton(
            onUpdated: () => setState(() => _load()),
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
              return Slidable(
                key: ValueKey(dm.id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(), // hiệu ứng trượt
                  extentRatio: 0.4, // chiếm 40% chiều rộng
                  children: [
                    SlidableAction(
                      onPressed: (_) async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ThemDanhMucThuChiScreen(danhMuc: dm),
                          ),
                        );

                        if (result == true) {
                          setState(() {
                            _load();
                          });
                        }
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Sửa',
                    ),
                    SlidableAction(
                      onPressed: (_) => deleteDanhMuc(context, dm.id!, () => setState(() => _load())),
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
                    title: Text(dm.ten)
                  ),
                ),
              );

            },
          );
        },
      ),
    );
  }
}
