import 'package:flutter/material.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  const HomeSectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold)),
        TextButton(onPressed: onViewAll, child: const Text('Xem tất cả')),
      ],
    );
  }
}
