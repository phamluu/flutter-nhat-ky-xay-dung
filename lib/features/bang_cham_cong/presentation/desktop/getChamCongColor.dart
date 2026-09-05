import 'package:flutter/material.dart';

/// 1. Hàm lấy màu nền (Background)
Color getChamCongColor(String value, bool chotCong) {
  // TRẠNG THÁI: ĐÃ CHỐT CÔNG (Khóa / Read-Only)
  // Ép toàn bộ về tông Xám chì / Nhạt để vô hiệu hóa thị giác
  if (chotCong) {
    if (value.isEmpty) {
      return Colors.grey.shade200; // Ô trống đã khóa: Xám xỉn
    }
    // Tất cả mã công đã chốt đều dùng xám nhạt đồng bộ (Disabled look)
    return Colors.grey.shade300;
  }

  // TRẠNG THÁI: CHƯA CHỐT CÔNG (Active / Đang làm việc)
  if (value.isEmpty) {
    return Colors.white; // Ô trống chưa khóa: Trắng sạch để chờ nhập
  }

  // Sử dụng màu sắc tươi sáng, rõ ràng cho các ô đang chấm
  switch (value.toUpperCase()) {
    case "X":
      return const Color(0xFFC8E6C9); // Green nhạt rực (Green 100)
    case "P":
      return const Color(0xFFFFE0B2); // Orange nhạt rực (Orange 100)
    case "CT":
      return const Color(0xFFBBDEFB); // Blue nhạt rực (Blue 100)
    case "L":
      return const Color(0xFFFFCDD2); // Red nhạt rực (Red 100)
    case "O":
      return const Color(0xFFE1BEE7); // Purple nhạt rực (Purple 100)
    default:
      return Colors.grey.shade100;
  }
}

/// 2. Hàm lấy màu chữ (Text Color)
Color getChamCongTextColor(String value, bool chotCong) {
  // TRẠNG THÁI: ĐÃ CHỐT CÔNG
  // Chữ xám mờ (Disabled Text)
  if (chotCong) {
    return Colors.grey.shade600;
  }

  if (value.isEmpty) return Colors.black87;

  // TRẠNG THÁI: CHƯA CHỐT CÔNG
  // Chữ tông cực đậm, tương phản cao để tạo điểm nhấn
  switch (value.toUpperCase()) {
    case "X":
      return const Color(0xFF1B5E20); // Dark Green
    case "P":
      return const Color(0xFFE65100); // Dark Orange
    case "CT":
      return const Color(0xFF0D47A1); // Dark Blue
    case "L":
      return const Color(0xFFB71C1C); // Dark Red
    case "O":
      return const Color(0xFF4A148C); // Dark Purple
    default:
      return Colors.black87;
  }
}

/// 3. Hàm lấy màu viền (Border Color)
Color getChamCongBorderColor(String value, bool chotCong) {
  // TRẠNG THÁI: ĐÃ CHỐT CÔNG
  // Viền mờ hoặc chìm hẳn vào nền
  if (chotCong) {
    return Colors.grey.shade400;
  }

  // TRẠNG THÁI: CHƯA CHỐT CÔNG
  // Viền đậm nét, nổi bật giúp phân định ô đang tương tác
  if (value.isEmpty) {
    return Colors.blue.shade300; // Ô trống chưa chốt có viền xanh nhạt gợi ý nhập
  }

  switch (value.toUpperCase()) {
    case "X":
      return Colors.green.shade600;
    case "P":
      return Colors.orange.shade600;
    case "CT":
      return Colors.blue.shade600;
    case "L":
      return Colors.red.shade600;
    case "O":
      return Colors.purple.shade600;
    default:
      return Colors.grey.shade500;
  }
}