import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/cham_cong/cham_cong_screen.dart';
import 'package:nhat_ky_xay_dung/features/danh_muc_thu_chi/screens/danh_sach_danh_muc_thu_chi_screen.dart';
import 'package:nhat_ky_xay_dung/features/home/widgets/NhatKyList.dart';
import 'package:nhat_ky_xay_dung/features/nhat_ky/screens/DanhSachNhatKyScreen.dart';
import 'package:nhat_ky_xay_dung/features/thu_chi/screens/danh_sach_thu_chi_screen.dart';

import '../../../services/thong_ke_service.dart';
import '../../cong_trinh/pages/DanhSachCongTrinhScreen.dart';
import '../../nhan_vien/screens/DanhSachNhanVienScreen.dart';
import '../../../controllers/thong_ke_controller.dart';
import '../widgets/ProjectList.dart';
import '../widgets/bottomNavigation.dart';
import '../widgets/thong_ke.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = ThongKeController();
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {}); // rebuild UI khi count thay đổi
    });
    controller.loadCounts(); // load count lần đầu
  }

  @override
  void dispose() {
    controller.dispose(); // giải phóng bộ nhớ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projects = [
      {'name': 'Dự án Ba Làng', 'progress': 0.72, 'updated': '20/07/2025'},
      {'name': 'Dự án B', 'progress': 0.40, 'updated': '19/07/2025'},
    ];

    final recentLogs = [
      {'date': '20/07', 'project': 'Dự án Ba Làng', 'title': 'Đổ bê tông tầng 2'},
      {'date': '19/07', 'project': 'Dự án B', 'title': 'Lắp cốp pha'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật ký xây dựng'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 8),
          CircleAvatar(radius: 16, child: Icon(Icons.person)),
          SizedBox(width: 12),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tìm kiếm + Bộ lọc
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Tìm dự án hoặc nhật ký...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w100,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Bộ lọc'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ThongKeGrid(
              controller: controller,
              onProjectsTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DanhSachCongTrinhScreen()),
                ).then((_) => controller.loadCounts());
              },
              onDiaryTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DanhSachNhatKyScreen()),
                ).then((_) => controller.loadCounts());
              },
              onEmployeesTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DanhSachNhanVienScreen()),
                ).then((_) => controller.loadCounts());
              },
              onFinanceTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DanhSachDanhMucThuChiScreen()),
                ).then((_) => controller.loadCounts());
              },
            ),


            // Danh sách dự án
            ProjectList(),

            const SizedBox(height: 20),

            // Nhật ký gần đây
            NhatKyList(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        onProjectsTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DanhSachCongTrinhScreen()),
          ).then((value) {
            // Khi quay về Home, load lại số liệu
            controller.loadCounts();
          });
        },
        onDiaryTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DanhSachNhatKyScreen()),
          ).then((value) {
            // Khi quay về Home, load lại số liệu
            controller.loadCounts();
          });
        },
        onFinanceTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DanhSachThuChiScreen()),
          );
        },
        onCheckInTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  ChamCongScreen(idCongTrinh: 0, nhanViens: [],)),
          );
        },
        onProfileTap: () {
          print("Tôi");
        },
      ),
    );
  }
}
