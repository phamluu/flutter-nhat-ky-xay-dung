import 'package:flutter/material.dart';

Widget salaryItem({
  required String title,
  required String value,
  required IconData icon,
  Color? valueColor,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius:
      BorderRadius.circular(10),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue
                .withOpacity(.08),
            borderRadius:
            BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
            valueColor ??
                Colors.blue.shade700,
          ),
        ),

        const SizedBox(width: 11),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color:
                  Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}