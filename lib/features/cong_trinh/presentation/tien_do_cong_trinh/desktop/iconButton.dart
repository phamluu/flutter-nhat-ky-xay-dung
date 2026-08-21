import 'package:flutter/material.dart';

Widget iconButton({
  required IconData icon,
  required String tooltip,
  required VoidCallback onPressed,
}) {
  return Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xffe2e8f0),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: const Color(0xff475569),
        ),
      ),
    ),
  );
}