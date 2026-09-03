import 'package:flutter/material.dart';

/// 1. Hàm lấy màu nền (Background)
Color getChamCongColor(String value, bool chotCong) {
  if (value.isEmpty) {
    return chotCong ? Colors.grey.shade100 : Colors.transparent;
  }

  final String code = value.toUpperCase();

  // TRẠNG THÁI: ĐÃ CHỐT CÔNG (Khóa/Read-Only)
  // Dùng tông pastel siêu nhạt, dịu mắt
  if (chotCong) {
    switch (code) {
      case "X":
        return const Color(0xFFE8F5E9); // Green nhạt (Green 50)
      case "P":
        return const Color(0xFFFFF3E0); // Orange nhạt (Orange 50)
      case "CT":
        return const Color(0xFFE3F2FD); // Blue nhạt (Blue 50)
      case "L":
        return const Color(0xFFFFEBEE); // Red nhạt (Red 50)
      case "O":
        return const Color(0xFFF3E5F5); // Purple nhạt (Purple 50)
      default:
        return Colors.grey.shade200;
    }
  }

  // TRẠNG THÁI: CHƯA CHỐT CÔNG (Đang hoạt động/Cho phép sửa)
  // Dùng màu tươi, rực rỡ và có độ tương phản tốt hơn
  switch (code) {
    case "X":
      return Colors.green.shade100; // Xanh lá nổi
    case "P":
      return Colors.orange.shade100; // Cam nổi
    case "CT":
      return Colors.blue.shade100; // Xanh dương nổi
    case "L":
      return Colors.red.shade100; // Đỏ nổi
    case "O":
      return Colors.purple.shade100; // Tím nổi
    default:
      return Colors.grey.shade300;
  }
}

/// 2. Hàm lấy màu chữ (Text Color)
Color getChamCongTextColor(String value, bool chotCong) {
  if (value.isEmpty) return Colors.black87;

  // TRẠNG THÁI: ĐÃ CHỐT CÔNG
  // Ép toàn bộ chữ về xám chì / xám đậm để tạo cảm giác tĩnh (Disabled/Locked)
  if (chotCong) {
    return Colors.grey.shade700;
  }

  // TRẠNG THÁI: CHƯA CHỐT CÔNG
  // Chữ theo đúng tông màu đậm của từng ký hiệu để tạo điểm nhấn tương phản
  switch (value.toUpperCase()) {
    case "X":
      return Colors.green.shade900;
    case "P":
      return Colors.orange.shade900;
    case "CT":
      return Colors.blue.shade900;
    case "L":
      return Colors.red.shade900;
    case "O":
      return Colors.purple.shade900;
    default:
      return Colors.black87;
  }
}

/// 3. Hàm bổ sung: Lấy màu viền (Border) giúp phân biệt rõ ràng hơn
Color getChamCongBorderColor(String value, bool chotCong) {
  if (value.isEmpty) return Colors.grey.shade300;

  if (chotCong) {
    // Viền xám mảnh tạo cảm giác các ô đã được "đóng băng"
    return Colors.grey.shade300;
  }

  // Viền đậm cùng tông màu khi chưa chốt công
  switch (value.toUpperCase()) {
    case "X":
      return Colors.green.shade400;
    case "P":
      return Colors.orange.shade400;
    case "CT":
      return Colors.blue.shade400;
    case "L":
      return Colors.red.shade400;
    case "O":
      return Colors.purple.shade400;
    default:
      return Colors.grey.shade400;
  }
}