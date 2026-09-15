import 'package:flutter/material.dart';

Widget buildDropdown<T>({
  required double width,
  required IconData icon,
  required String label,
  required T value,
  required List<T> items,
  required String Function(T value) itemLabel,
  required ValueChanged<T?> onChanged,
}) {
  return SizedBox(
    width: width,
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius:
        BorderRadius.circular(9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
          ),
          items: items.map(
                (item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 17,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      itemLabel(item),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ).toList(),
          onChanged: onChanged,
        ),
      ),
    ),
  );
}