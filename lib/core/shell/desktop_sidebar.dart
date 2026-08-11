import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context) {
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
            ),
          ),

          const SizedBox(height: 30),

          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Tổng quan'),
            onTap: () {
              context.go('/');
            },
          ),

          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text('Công trình'),
            onTap: () {
               context.go('/cong-trinh');
            },
          ),

          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Nhân viên'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Chấm công'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: const Text('Lương'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Chi phí'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: const Text('Nhật ký'),
            onTap: () {},
          ),

          const Spacer(),

          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt'),
            onTap: () {},
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}