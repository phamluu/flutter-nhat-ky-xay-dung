import 'package:flutter/material.dart';

class SummaryData {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color iconColor;
  final Color backgroundColor;

  const SummaryData({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.iconColor,
    required this.backgroundColor,
  });
}