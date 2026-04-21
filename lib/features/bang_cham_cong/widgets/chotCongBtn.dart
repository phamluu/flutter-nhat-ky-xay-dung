import 'package:flutter/material.dart';
// Kiểm tra tồn tại chôt lương =? không cho mở
class ChotCongButton extends StatelessWidget {
  final bool daKhoa;
  final bool daChotLuong;
  final VoidCallback onPressed;

  const ChotCongButton({
    super.key,
    required this.daKhoa,
    required this.daChotLuong,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = daChotLuong;

    return ElevatedButton.icon(
      onPressed: isDisabled ? null : onPressed,
      icon: Icon(
        daKhoa ? Icons.lock_open : Icons.lock,
        color: Colors.white,
      ),
      label: Text(
        daKhoa ? "Mở khóa" : "Chốt công",
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled
            ? Colors.grey // đã chốt lương -> disabled
            : (daKhoa ? Colors.grey : Colors.red),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}