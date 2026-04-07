import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/pages/ChiTietCongTrinhScreen.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../services/cong_trinh_service.dart';
import '../../../controllers/thong_ke_controller.dart';
import 'SuaCongTrinhScreen.dart';
import 'ThemCongTrinhScreen.dart';

class DanhSachCongTrinhScreen extends StatefulWidget {
  const DanhSachCongTrinhScreen({super.key});

  @override
  State<DanhSachCongTrinhScreen> createState() =>
      _DanhSachCongTrinhScreenState();
}

class _DanhSachCongTrinhScreenState extends State<DanhSachCongTrinhScreen> {
  final _service = CongTrinhService();

  late Future<List<CongTrinh>> _futureCongTrinh;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureCongTrinh = _service.getDanhSachCongTrinh();
  }

  void _openThemCongTrinh() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ThemCongTrinhScreen(),
      ),
    );

    if (result == true) {
      setState(() {
        _loadData();
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công trình'),
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openThemCongTrinh,
          )
        ],
      ),
      body: FutureBuilder<List<CongTrinh>>(
        future: _futureCongTrinh,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Chưa có công trình nào.'));
          }
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ct = data[index];

              return Slidable(
                key: ValueKey(ct.id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(), // hiệu ứng trượt
                  extentRatio: 0.4, // chiếm 40% chiều rộng
                  children: [
                    SlidableAction(
                      onPressed: (_) async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SuaCongTrinhScreen(congTrinh: ct),
                          ),
                        );

                        if (result == true) {
                          setState(() {
                            _loadData();
                          });
                        }
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
                            content: Text("Bạn có chắc muốn xóa công trình '${ct.ten}'?"),
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
                          await _service.deleteCongTrinh(ct.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Xóa công trình thành công", style: TextStyle(color: Colors.white),),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
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
                child: conTrinh(ct),
              );
            },
          );
        },
      ),
    );
  }

  Widget conTrinh(CongTrinh ct) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChiTietCongTrinhScreen(congTrinh: ct),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              /// PHẦN THÔNG TIN (2/3)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ct.ten,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ct.diaChi!,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: 50 / 100,
                      color: Colors.orange,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 4),
                    Text("Tiến độ: 50%"),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              /// PHẦN HÌNH (1/3)
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ct.hinhAnh != null? Image.file(File(ct.hinhAnh!),fit: BoxFit.cover,): Image.asset(
                      'assets/noimage.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

