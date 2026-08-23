import 'dart:ui';
import 'package:flutter/material.dart';
DataCell textCell(String text, {Color? color, bool isBold = false}) => DataCell(
  Text(text, style: TextStyle(color: color, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal)),
);