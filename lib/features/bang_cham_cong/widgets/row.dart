import 'package:flutter/material.dart';

Widget row(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  );
}