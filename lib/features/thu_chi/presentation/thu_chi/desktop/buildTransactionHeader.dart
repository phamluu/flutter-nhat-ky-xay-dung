import 'package:flutter/material.dart';

Widget buildTransactionHeader(
    countDM,
    ) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 17,
    ),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xffeff6ff),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: Color(0xff2563eb),
            size: 19,
          ),
        ),

        const SizedBox(width: 11),

        const Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Các khoản thu chi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff172033),
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Chi tiết các giao dịch theo danh mục và thời gian',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xff64748b),
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xfff8fafc),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${countDM} danh mục',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xff475569),
            ),
          ),
        ),
      ],
    ),
  );
}