import 'package:flutter/material.dart';
import '../../nhat_ky_cong_trinh/data/models/NhatKy.dart';
import '../../nhat_ky_cong_trinh/data/services/nhat_ky_service.dart';
import '../../nhat_ky_cong_trinh/presentation/mobile/DanhSachNhatKyScreen.dart';
import '../../nhat_ky_cong_trinh/presentation/mobile/XemChiTietNhatKyScreen.dart';
import '_SectionHeader.dart';

class NhatKyList extends StatefulWidget {
  const NhatKyList({super.key});

  @override
  State<NhatKyList> createState() => _NhatKyListState();
}

class _NhatKyListState extends State<NhatKyList> {
  List<NhatKyViewModel> logs = [];
  bool isLoading = true;
  final _service = NhatKyService(); // Giả sử service load nhật ký

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => isLoading = true);
    try {
      final result = await _service.getAllNhatKy();
      // Lấy tối đa 5 nhật ký gần đây
      setState(() => logs = result.take(5).toList());
    } catch (e) {
      print('Lỗi load nhật ký: $e');
      setState(() => logs = []);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSectionHeader(title: 'Nhật ký gần đây', onViewAll: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DanhSachNhatKyScreen(),
            ),
          );
        }),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (logs.isEmpty)
          const Text('Không có nhật ký nào')
        else
          ...logs.map((l) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.calendar_month,
                  color: Theme.of(context).colorScheme.primary),
              title: Text('${l.nhatKy.ngayTrienKhai.toString() ?? ''}  ${l.nhatKy.tenNhatKy}'),
              subtitle: Text(l.nhatKy.congTrinh?.ten ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => XemChiTietNhatKyScreen(nhatKy: l.nhatKy),
                  ),
                );
              },
            ),
          )),
      ],
    );
  }
}
