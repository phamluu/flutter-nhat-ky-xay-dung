import 'dart:ui';

import 'package:flutter/material.dart';

DataCell badgeCell(String text, Color color) => DataCell(
  Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
  ),
);