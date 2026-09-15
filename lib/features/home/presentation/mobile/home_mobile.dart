import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/auth/presentation/mobile/login_mobile.dart';
import 'package:nhat_ky_xay_dung/features/nhan_vien/presentation/mobile/nhan_vien_list_mobile.dart';
import 'package:nhat_ky_xay_dung/features/thu_chi/presentation/danh_muc_thu_chi/mobile/danh_sach_danh_muc_thu_chi_mobile.dart';
import '../../../../controllers/thong_ke_controller.dart';
import '../../../../core/utils/AuthHelper.dart';
import '../../../../core/utils/update_helper.dart';
import '../../../cong_trinh/presentation/cong_trinh/pages/cong_trinh_list_page.dart';
import '../../../luong/presentation/luong_co_ban/mobile/luong_coban_screen.dart';
import '../../../settings/screens/SettingsScreen.dart';
import '../../../tax/features/vat_report/vat_report_screen.dart';
import 'ProjectList.dart';
import '../../widgets/bottomNavigation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../pages/_statCard.dart';
class HomeMobile extends StatefulWidget {
  const HomeMobile({super.key});

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
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
  Widget build(BuildContext context) {
    final List<NavItem> items = [
      NavItem(
        icon: Icons.apartment,
        label: 'Công trình',
        page: const CongTrinhListPage(),
        color: Colors.blue,
        reloadAfterPop: true,
      ),
      NavItem(
        icon: Icons.person,
        label: 'Nhân viên',
        page: const NhanVienListMobile(),
        color: Theme.of(context).colorScheme.secondary,
        reloadAfterPop: true,
      ),
      NavItem(
        icon: Icons.money,
        label: 'Lương',
        page: const LuongCoBanScreen(),
        color: Theme.of(context).colorScheme.secondary,
        reloadAfterPop: true,
      ),
      // NavItem(
      //   icon: Icons.person,
      //   label: 'Thuế',
      //   //page: TaxReportScreen(),
      //   page:VatReportScreen(),
      //   color: Colors.grey,
      // ),
      NavItem(
        icon: Icons.money,
        label: 'DM thu chi',
        page: const DanhSachDanhMucThuChiMobile(),
        color: Colors.grey,
      ),
    ];
    return Scaffold(
      primary: false,
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text(
          'Hello Nhật ký xây dựng',
        ),
        actions: [
          const Icon(Icons.notifications_none),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
              // final isLoggedIn = await AuthHelper.isLoggedIn();
              // if (isLoggedIn) {
              // } else {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => const LoginMobile(),
              //     ),
              //   );
              // }
            },
            child: const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Chào mừng trở lại!'),
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
            _buildStatistics(),
            // Danh sách dự án
            ProjectList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: items,
        onTap: (item) => _navigate(context, item),
      ),
    );
  }

  Widget _buildStatistics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: statCard(
                icon: Icons.business,
                title: 'Công trình',
                value: '${controller.soLuongCongTrinh}',
                subtitle: 'Tổng công trình',
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: statCard(
                icon: Icons.people,
                title: 'Nhân viên',
                value: '${controller.soLuongNhanVien}',
                subtitle: 'Đang quản lý',
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: statCard(
                icon: Icons.assignment,
                title: 'Nhật ký',
                value: '${controller.soLuongNhatKy}',
                subtitle: 'Nhật ký xây dựng',
              ),
            ),
            // const SizedBox(width: 5),
            // Expanded(
            //   child: statCard(
            //     icon: Icons.sync,
            //     title: 'Đồng bộ',
            //     value: '0',
            //     subtitle: 'Chưa đồng bộ',
            //   ),
            // ),
          ],
        );
      },
    );
  }
  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.orange,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
  void _navigate(BuildContext context, NavItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => item.page),
    ).then((_) {
      if (item.reloadAfterPop) {
        controller.loadCounts();
      }
    });
  }
}

