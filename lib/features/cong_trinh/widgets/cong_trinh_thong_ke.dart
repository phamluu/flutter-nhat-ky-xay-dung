import 'package:flutter/material.dart';

import '../../../controllers/thong_ke_controller.dart';

class ThongKeGrid extends StatelessWidget {
  final ThongKeController controller;
  final void Function()? onDiaryTap;
  final void Function()? onEmployeesTap;
  final void Function()? onChamCongTap;
  final void Function()? onThucChiTap;
  final void Function()? onUngLuongTap;
  const ThongKeGrid({
    Key? key,
    required this.controller,
    this.onDiaryTap,
    this.onEmployeesTap,
    this.onChamCongTap,
    this.onThucChiTap,
    this.onUngLuongTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2, // 2 cột
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.9,
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _StatCard(
          icon: Icons.note_alt_outlined,
          label: 'Nhật ký',
          value: controller.soLuongNhatKy.toString(),
          color: const Color(0xFFE67E22),
          onTap: onDiaryTap,
        ),
        _StatCard(
          icon: Icons.people,
          label: 'Nhân viên',
          value: controller.soLuongNhanVienCongTrinh.toString(),
          color: const Color(0xFF27AE60),
          onTap: onEmployeesTap,
        ),
        _StatCard(
          icon: Icons.people,
          label: 'Chấm công',
          value: controller.soLuongCoMat.toString(),
          color: const Color(0xFF2980B9),
          onTap: onChamCongTap,
        ),
        _StatCard(
          icon: Icons.attach_money,
          label: 'Thu chi',
          value: controller.soLanThuChi.toString(),
          color: const Color(0xFF8E44AD),
          onTap: onThucChiTap,
        ),
        _StatCard(
          icon: Icons.attach_money,
          label: 'Ứng lương',
          value: controller.soLanUngLuong.toString(),
          color: const Color(0xFF8E44AD),
          onTap: onUngLuongTap,
        ),
      ],
    );
  }

}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: color.withOpacity(0.15),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey[700],
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
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

    return onTap != null
        ? InkWell(borderRadius: BorderRadius.circular(16), onTap: onTap, child: card)
        : card;
  }
}
