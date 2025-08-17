import 'package:flutter/material.dart';

import '../../../controllers/thong_ke_controller.dart';

class ThongKeGrid extends StatelessWidget {
  final ThongKeController controller;
  final void Function()? onDiaryTap;
  final void Function()? onEmployeesTap;

  const ThongKeGrid({
    Key? key,
    required this.controller,
    this.onDiaryTap,
    this.onEmployeesTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.note_alt_outlined,
                label: 'Nhật ký',
                value: controller.soLuongNhatKy.toString(),
                color: const Color(0xFFE67E22),
                onTap: onDiaryTap,
              ),
            ),
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                label: 'Nhân viên',
                value: controller.soLuongNhanVienCongTrinh.toString(), // hoặc controller.soLuongNhanVien
                color: const Color(0xFF27AE60),
                onTap: onEmployeesTap,
              ),
            )
          ],
        ),
        const SizedBox(height: 12)
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
