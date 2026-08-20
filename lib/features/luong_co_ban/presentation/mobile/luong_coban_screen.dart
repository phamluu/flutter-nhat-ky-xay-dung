import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nhat_ky_xay_dung/features/luong_co_ban/presentation/mobile/LuongCoBanNhanVien.dart';
import '../../data/models/LuongCoBan.dart';
import '../../data/services/luong_co_ban_service.dart';

class LuongCoBanScreen extends StatefulWidget {
  const LuongCoBanScreen({super.key});
  @override
  State<LuongCoBanScreen> createState() => _LuongCoBanScreenState();
}

class _LuongCoBanScreenState extends State<LuongCoBanScreen> {
  final LuongCoBanService _service = LuongCoBanService();
  final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");
  late Future<List<LuongCoBanModel>> _futureLuong;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureLuong = _service.getLuongCoBan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Lương cơ bản"),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: FutureBuilder<List<LuongCoBanModel>>(
            future: _futureLuong,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }
              final data = snapshot.data ?? [];
              if (data.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline,
                          size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'Chưa có nhân viên nào',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final luong = data[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(Icons.person, color: Colors.blue),
                      ),
                      title: Text(
                        luong.hoTen ?? "Không tên",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(luong.ngaySinh ?? "Chưa có ngày sinh"),
                      trailing: Text(
                        "${currencyFormat.format(luong.luongHienTai ?? 0)} đ",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    LuongCoBanNhanVienScreen(idNhanVien: luong.idNhanVien, hoTen: luong.hoTen,)
                            )
                        ).then((_) {
                          _loadData();
                        });
                      },
                    ),
                  );
                },
              );
            }));
  }
}
