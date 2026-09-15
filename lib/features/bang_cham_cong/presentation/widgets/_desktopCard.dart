import 'package:flutter/material.dart';

Widget desktopCard({
  required String title,
  required IconData icon,
  required Color iconColor,
  required Widget child,
  Widget? headerAction,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius:
      BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Column(
      crossAxisAlignment:
      CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor
                    .withOpacity(.10),
                borderRadius:
                BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            if (headerAction != null)
              headerAction,
          ],
        ),

        const SizedBox(height: 18),

        const Divider(height: 1),

        const SizedBox(height: 18),

        child,
      ],
    ),
  );
}