import 'package:flutter/material.dart';

Widget buildDropdown<T>({
  required T value,
  required List<T> items,
  required String Function(T) itemLabel,
  required ValueChanged<T?> onChanged,
}) {
  return Container(
    height: 38,
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(
        color: Colors.grey.shade300,
      ),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: items.contains(value)
            ? value
            : items.first,
        isDense: true,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          size: 18,
        ),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xff334155),
        ),
        items: items.map(
              (item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
              ),
            );
          },
        ).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}