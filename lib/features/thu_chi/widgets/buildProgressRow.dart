import 'package:flutter/material.dart';

import '../../../core/utils/currencyFormat.dart';

Widget buildProgressRow({
  required String title,
  required num value,
  required double percent,
  required Color color,
}) {
  final safePercent =
  percent.clamp(0.0, 1.0);

  return Column(
    crossAxisAlignment:
    CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xff475569),
              ),
            ),
          ),

          Text(
            currencyFormat.format(value),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),

      const SizedBox(height: 8),

      ClipRRect(
        borderRadius:
        BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: safePercent,
          minHeight: 7,
          backgroundColor:
          const Color(0xfff1f5f9),
          valueColor:
          AlwaysStoppedAnimation<Color>(
            color,
          ),
        ),
      ),
    ],
  );
}

