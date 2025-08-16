import 'package:flutter/material.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../services/cong_trinh_service.dart';
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
              return ListTile(
                title: Text(ct.ten),
                subtitle: Text(ct.diaChi ?? 'Không có địa chỉ'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(ct.ngayBatDau ?? ''),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
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
                          setState(() {
                            _loadData(); // load lại danh sách
                          });
                        }
                      },
                    ),
                  ],
                ),
                onTap: () async {
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
              );
            },
          );
        },
      ),
    );
  }
}

