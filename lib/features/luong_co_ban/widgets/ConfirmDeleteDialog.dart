import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String message;
  final VoidCallback onConfirm;

  const ConfirmDeleteDialog({
    super.key,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Xác nhận"),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text("Xóa"),
        )
      ],
    );
  }
}
