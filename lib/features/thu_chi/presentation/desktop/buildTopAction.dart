import 'package:flutter/material.dart';

Widget buildTopAction({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(
      icon,
      size: 17,
    ),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xff475569),
      side: BorderSide(
        color: Colors.grey.shade300,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}