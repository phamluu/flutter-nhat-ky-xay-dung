import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/cham_cong/cham_cong_screen.dart';
import 'package:nhat_ky_xay_dung/features/danh_muc_thu_chi/screens/danh_sach_danh_muc_thu_chi_screen.dart';
import 'package:nhat_ky_xay_dung/features/home/widgets/NhatKyList.dart';
import 'package:nhat_ky_xay_dung/features/luong_co_ban/screens/luong_coban_screen.dart';
import 'package:nhat_ky_xay_dung/features/nhat_ky/screens/DanhSachNhatKyScreen.dart';
import 'package:nhat_ky_xay_dung/features/thu_chi/screens/thu_chi_screen.dart';
import 'package:nhat_ky_xay_dung/features/tool/screens/list.dart';

import '../../../core/utils/update_helper.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../services/cong_trinh_service.dart';
import '../../../services/thong_ke_service.dart';
import '../../cong_trinh/pages/DanhSachCongTrinhScreen.dart';
import '../../nhan_vien/screens/DanhSachNhanVienScreen.dart';
import '../../../controllers/thong_ke_controller.dart';
import '../../ung_luong/screens/UngLuongScreen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateHelper.checkForUpdate(context);
    });
  }

  @override
  void dispose() {
    controller.dispose(); // giải phóng bộ nhớ
    super.dispose();
  }
  @override

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hello Nhật ký xây dựng',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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
            const Text('Chào mừng đến với nhật ký công trình!'),
            const SizedBox(height: 16),

            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 2 / 1,
                child: Image.asset(
                  'assets/banner.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 12),

            // Danh sách dự án
            ProjectList(),
            const SizedBox(height: 20),
          // ThongKeGrid(
          //     controller: controller,
          //     onProjectsTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (_) => const DanhSachCongTrinhScreen()),
          //       ).then((_) => controller.loadCounts());
          //     },
          //     onDiaryTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (_) => const DanhSachNhatKyScreen()),
          //       ).then((_) => controller.loadCounts());
          //     },
          //     onEmployeesTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (_) => const DanhSachNhanVienScreen()),
          //       ).then((_) => controller.loadCounts());
          //     },
          //     onFinanceTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (_) => const DanhSachDanhMucThuChiScreen()),
          //       ).then((_) => controller.loadCounts());
          //     },
          //     onLuongCoBanTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (_) => const LuongCoBanScreen()),
          //       ).then((_) => controller.loadCounts());
          //     },
          //     onUngLuongTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (_) => const UngLuongScreen()),
          //       ).then((_) => controller.loadCounts());
          //     },
          //   ),

            // Nhật ký gần đây
            // NhatKyList(),
            // ToolList(),
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
          onEmployeesTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DanhSachNhanVienScreen()),
                  ).then((_) => controller.loadCounts());
                },
        // onDiaryTap: () {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => const DanhSachNhatKyScreen()),
        //   ).then((value) {
        //     // Khi quay về Home, load lại số liệu
        //     controller.loadCounts();
        //   });
        // },
        onFinanceTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ThuChiScreen()),
          );
        },
        onCheckInTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  ChamCongScreen(idCongTrinh: 0)),
          );
        },
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  HomePage()),
          );
        },
      ),
    );
  }

}
