import 'package:flutter/material.dart';

Widget infoBox({
  required IconData icon,
  required String title,
  required String value,
  Color? valueColor,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 13,
      vertical: 11,
    ),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius:
      BorderRadius.circular(9),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey.shade600,
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),

        const Spacer(),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
              FontWeight.w700,
              color:
              valueColor ??
                  Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}