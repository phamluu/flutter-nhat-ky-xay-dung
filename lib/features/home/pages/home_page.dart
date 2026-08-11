import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/cong_trinh/presentation/pages/cong_trinh_list_page.dart';
import 'package:nhat_ky_xay_dung/features/luong_co_ban/screens/luong_coban_screen.dart';
import '../../../core/utils/AuthHelper.dart';
import '../../../core/utils/update_helper.dart';
import '../../auth/screens/LoginScreen.dart';
import '../../cong_trinh/pages/DanhSachCongTrinhScreen.dart';
import '../../nhan_vien/screens/DanhSachNhanVienScreen.dart';
import '../../../controllers/thong_ke_controller.dart';
import '../../settings/screens/SettingsScreen.dart' show SettingsScreen;
import '../../tax/features/vat_report/vat_report_screen.dart';
import '../widgets/ProjectList.dart';
import '../widgets/bottomNavigation.dart';

import 'package:shared_preferences/shared_preferences.dart';
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
        page: const DanhSachNhanVienScreen(),
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
      NavItem(
        icon: Icons.person,
        label: 'Thuế',
        //page: TaxReportScreen(),
        page:VatReportScreen(),
        color: Colors.grey,
      ),
      NavItem(
        icon: Icons.person,
        label: 'Tôi',
        page: const SettingsScreen(),
        color: Colors.grey,
      ),
    ];
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
        foregroundColor: Colors.white,
        actions: [
          const Icon(Icons.notifications_none),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              final isLoggedIn = await AuthHelper.isLoggedIn();
              if (isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              }
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
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        items: items,
        onTap: (item) => _navigate(context, item),
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

