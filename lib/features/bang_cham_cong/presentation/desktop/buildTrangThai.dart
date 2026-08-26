import 'package:flutter/material.dart';

import '../../../../core/utils/trang_thai_luong.dart';

Widget buildTrangThai( TrangThaiLuong trangthai) {
  final isDaChot = trangthai == TrangThaiLuong.dachot;
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

Widget buildTrangThaiChiLuong(TrangThaiChiLuong trangThai) {
  Color bgColor;
  Color textColor;
  switch (trangThai) {
    case TrangThaiChiLuong.daChi:
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green.shade700;
      break;
    case TrangThaiChiLuong.chi1Phan:
      bgColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange.shade800;
      break;
    case TrangThaiChiLuong.chuaChi:
    default:
      bgColor = Colors.grey.withOpacity(0.12);
      textColor = Colors.grey.shade700;
      break;
  }

  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 5,
    ),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      trangThai.label, // Tự động lấy "Chưa chi", "Đã chi 1 phần", hoặc "Đã chi đủ"
      style: TextStyle(
        color: textColor,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

