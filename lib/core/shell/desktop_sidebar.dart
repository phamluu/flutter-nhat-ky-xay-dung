import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 30),

          const Text(
            'NHẬT KÝ XÂY DỰNG',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff263238),
            ),
          ),

          const SizedBox(height: 30),

          _menuItem(
            context,
            currentPath,
            icon: Icons.dashboard_outlined,
            title: 'Tổng quan',
            route: '/',
          ),

          _menuItem(
            context,
            currentPath,
            icon: Icons.business_outlined,
            title: 'Công trình',
            route: '/cong-trinh',
          ),
          _menuItem(
            context,
            currentPath,
            icon: Icons.money,
            title: 'Hạng mục thu chi',
            route: '/danh-muc-thu-chi',
          ),
          _menuItem(
            context,
            currentPath,
            icon: Icons.people_outline,
            title: 'Nhân viên',
            route: '/nhan-vien',
          ),

          _menuItem(
            context,
            currentPath,
            icon: Icons.payments_outlined,
            title: 'Lương cơ bản',
            route: '/luong-co-ban',
          ),

          const Spacer(),

          _menuItem(
            context,
            currentPath,
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            route: '/setting',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menuItem(
      BuildContext context,
      String currentPath, {
        required IconData icon,
        required String title,
        required String route,
      }) {
    final bool isActive = route == '/'
        ? currentPath == '/'
        : currentPath == route ||
        currentPath.startsWith('$route/');

    // Màu khi active
    final Color activeColor = Colors.blue.shade700;

    // Màu mặc định
    const Color normalColor = Color(0xff4b4850);

    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? activeColor : normalColor,
      ),

      title: Text(
        title,
        style: TextStyle(
          color: isActive ? activeColor : normalColor,
          fontWeight:
          isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),

      onTap: () {
        if (!isActive) {
          context.go(route);
        }
      },
    );
  }
}