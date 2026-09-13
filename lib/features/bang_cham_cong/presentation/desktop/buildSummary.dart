import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/utils/currencyFormat.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/presentation/desktop/summaryCard.dart';

import '../../data/models/phien_chot_cong.dart';

Widget buildSummary(List<ChamCongLuongNhanVien> dataList, int soNgay) {
  return Row(
    children: [
      Expanded(
        child: summaryCard(
          icon: Icons.people_alt_outlined,
          title: "Nhân viên",
          value: "${dataList.length}",
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
          value: dataList.fold(0.0,(sum, item) => sum + item.soCong).toString(),
          subtitle: "Tổng số công dự kiến",
          valueColor: Colors.orange
        ),
      ),

      const SizedBox(width: 14),

      Expanded(
        child: summaryCard(
          icon: Icons.payments_outlined,
          title: "Lương",
          value: currencyFormat.format(dataList.fold(0.0,(sum, item) => sum + item.tongLuongDuKien)).toString(),
          subtitle: "Tổng lương dự kiến",
          valueColor:  Colors.orange
        ),
      ),
    ],
  );
}