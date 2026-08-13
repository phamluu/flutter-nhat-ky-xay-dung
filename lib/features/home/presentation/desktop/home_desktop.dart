import 'package:flutter/material.dart';
import '../../../../controllers/thong_ke_controller.dart';
import '../../../../core/utils/update_helper.dart';
import 'desktop_recent_project.dart';

class HomeDesktop extends StatefulWidget {
  const HomeDesktop({super.key});

  @override
  State<HomeDesktop> createState() => _HomeDesktopState();
}

class _HomeDesktopState extends State<HomeDesktop> {
  final controller = ThongKeController();

  @override
  void initState() {
    super.initState();

    controller.addListener(_onControllerChanged);
    controller.loadCounts();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateHelper.checkForUpdate(context);
    });
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        title: const Text(
          'Tổng quan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),

          const SizedBox(width: 8),

          const CircleAvatar(
            radius: 17,
            child: Icon(
              Icons.person,
              size: 20,
            ),
          ),

          const SizedBox(width: 24),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcome(),

            const SizedBox(height: 24),

            _buildStatistics(),

            const SizedBox(height: 24),

            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chào mừng trở lại!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Theo dõi tình hình công trình và hoạt động hôm nay.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.business,
                title: 'Công trình',
                value: '${controller.soLuongCongTrinh}',
                subtitle: 'Tổng công trình',
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _statCard(
                icon: Icons.people,
                title: 'Nhân viên',
                value: '${controller.soLuongNhanVien}',
                subtitle: 'Đang quản lý',
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _statCard(
                icon: Icons.assignment,
                title: 'Nhật ký',
                value: '${controller.soLuongNhatKy}',
                subtitle: 'Nhật ký xây dựng',
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: _statCard(
                icon: Icons.sync,
                title: 'Đồng bộ',
                value: '0',
                subtitle: 'Chưa đồng bộ',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
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
              size: 26,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildProjects(),
        ),

        const SizedBox(width: 20),

      ],
    );
  }

  Widget _buildProjects() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesktopRecentProjects(),
        ],
      ),
    );
  }

}