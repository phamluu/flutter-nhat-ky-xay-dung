import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/danh_muc_thu_chi/screens/danh_sach_danh_muc_thu_chi_screen.dart';
import 'package:nhat_ky_xay_dung/features/nhat_ky/screens/DanhSachNhatKyScreen.dart';
import 'package:nhat_ky_xay_dung/features/thu_chi/screens/danh_sach_thu_chi_screen.dart';

import '../../cong_trinh/pages/DanhSachCongTrinhScreen.dart';
import '../../nhan_vien/screens/DanhSachNhanVienScreen.dart';
import '../widgets/bottomNavigation.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = [
      {'name': 'Dự án A', 'progress': 0.72, 'updated': '20/07/2025'},
      {'name': 'Dự án B', 'progress': 0.40, 'updated': '19/07/2025'},
    ];

    final recentLogs = [
      {'date': '20/07', 'project': 'Dự án A', 'title': 'Đổ bê tông tầng 2'},
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
                        fontWeight: FontWeight.w100
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

            // Thẻ thống kê
            Row(
              children: const [
                Expanded(child: _StatCard(icon: Icons.work_outline, label: 'Dự án', value: '12', color: Color(0xFF2E86C1))),
                SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.note_alt_outlined, label: 'Nhật ký', value: '5', color: Color(0xFFE67E22))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16), // hiệu ứng ripple
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DanhSachNhanVienScreen(),
                        ),
                      );
                    },
                    child: const _StatCard(
                      icon: Icons.people,
                      label: 'Nhân viên',
                      value: '72%',
                      color: const Color(0xFF27AE60),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16), // hiệu ứng ripple
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DanhSachDanhMucThuChiScreen(),
                        ),
                      );
                    },
                    child: const _StatCard(
                      icon: Icons.attach_money,
                      label: 'Loại thu chi',
                      value: '72%',
                      color: const Color(0xFFF39C12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: _StatCard(icon: Icons.trending_up, label: 'Tiến độ TB', value: '72%', color: Color(0xFF27AE60))),
                SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.schedule, label: 'Chậm tiến độ', value: '3', color: Color(0xFFF1C40F))),
              ],
            ),
            const SizedBox(height: 20),


            // Danh sách dự án
            _SectionHeader(title: 'Dự án', onViewAll: () {}),
            const SizedBox(height: 8),
            ...projects.map((p) => _ProjectItem(
              name: p['name'] as String,
              progress: p['progress'] as double,
              updatedAt: p['updated'] as String,
              progressColor: Theme.of(context).colorScheme.secondary,
            )),
            const SizedBox(height: 20),

            // Nhật ký gần đây
            _SectionHeader(title: 'Nhật ký gần đây', onViewAll: () {}),
            const SizedBox(height: 8),
            ...recentLogs.map((l) => Card(
              child: ListTile(
                leading: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                title: Text('${l['date']} • ${l['project']}'),
                subtitle: Text(l['title'] as String),
                onTap: () {},
              ),
            )),
          ],
        ),
      ),

        bottomNavigationBar: CustomBottomNavBar(
          onProjectsTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DanhSachCongTrinhScreen()),
            );
          },
          // Nhật ký
          onDiaryTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DanhSachNhatKyScreen()),
            );
          },
          // Thu chi
          onFinanceTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DanhSachThuChiScreen()),
            );
          },
          // Cham công
          onCheckInTap: () {
            print("Tôi");
          },
          onProfileTap: () {
            print("Tôi");
          },
        )
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cột icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, color: color, size: 20), // kích thước icon
            ),
            const SizedBox(width: 5), // gap
            // Cột tiêu đề + value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}

class _ProjectItem extends StatelessWidget {
  final String name;
  final double progress;
  final String updatedAt;
  final Color progressColor;
  const _ProjectItem({
    required this.name,
    required this.progress,
    required this.updatedAt,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Icon(Icons.apartment, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        color: progressColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('Cập nhật: $updatedAt', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(onPressed: onViewAll, child: const Text('Xem tất cả')),
      ],
    );
  }
}
