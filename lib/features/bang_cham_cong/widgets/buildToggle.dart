import 'package:flutter/material.dart';

Widget buildToggle(String text, bool value, Function(bool) onChanged) {
  return FilterChip(
    label: Text(text),
    selected: value,
    onSelected: onChanged,
    selectedColor: Colors.blue.shade100,
  );
}