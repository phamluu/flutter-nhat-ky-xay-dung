import 'package:flutter/material.dart';

Widget card({
  required Widget child,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xffe5e7eb),
      ),
    ),
    child: child,
  );
}