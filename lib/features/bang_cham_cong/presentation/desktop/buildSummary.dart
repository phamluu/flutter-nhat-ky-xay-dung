import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/summaryCard.dart';

Widget buildSummary(int countNhanVien, int soNgay, bool daKhoaCC, bool coChotLuong) {
  return Row(
    children: [
      Expanded(
        child: summaryCard(
          icon: Icons.people_alt_outlined,
          title: "Nhân viên",
          value: "${countNhanVien}",
          subtitle: "Nhân viên trong công trình",
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: summaryCard(
          icon: Icons.calendar_month_outlined,
          title: "Số ngày",
          value: "$soNgay",
          subtitle: "Ngày trong tháng",
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: summaryCard(
          icon: Icons.lock_outline,
          title: "Chấm công",
          value: daKhoaCC
              ? "Đã khóa"
              : "Chưa khóa",
          subtitle: "Trạng thái chấm công",
          valueColor: daKhoaCC
              ? Colors.green
              : Colors.orange,
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: summaryCard(
          icon: Icons.payments_outlined,
          title: "Chốt lương",
          value: coChotLuong
              ? "Đã chốt"
              : "Chưa chốt",
          subtitle: "Trạng thái bảng lương",
          valueColor: coChotLuong
              ? Colors.green
              : Colors.red,
        ),
      ),
    ],
  );
}