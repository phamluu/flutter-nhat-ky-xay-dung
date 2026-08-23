import 'package:flutter/material.dart';

import '../../../../core/utils/trang_thai_luong.dart';

Widget buildTrangThai(
    TrangThaiLuong trangthai,
    ) {
  final isDaChot =
      trangthai == TrangThaiLuong.dachot;

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 9,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: isDaChot
          ? Colors.green.withOpacity(.09)
          : Colors.red.withOpacity(.08),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      isDaChot
          ? "Đã chốt lương"
          : "Chưa chốt lương",
      style: TextStyle(
        color: isDaChot
            ? Colors.green.shade700
            : Colors.red.shade700,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}