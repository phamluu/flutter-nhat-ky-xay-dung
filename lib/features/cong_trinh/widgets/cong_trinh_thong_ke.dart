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
      childAspectRatio: 1.2,
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
    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔹 Icon nhỏ + có nền
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),

          const SizedBox(height: 8),

          // 🔥 SỐ (trung tâm)
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return onTap != null
        ? InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: card,
    )
        : card;
  }
}