import 'package:flutter/material.dart';

Widget summaryCardMobile({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
  required Color background,
}) {
  return Container(
    height: 60,
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.025),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 10,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            mainAxisAlignment:MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}