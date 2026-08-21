import 'package:flutter/material.dart';


class Item{
  final IconData icon;
  final String label;
  final Widget page;
  final String value;
  final Color color;
  final bool reloadAfterPop;
  Item({
    required this.icon,
    required this.label,
    required this.page,
    required this.value,
    required this.color,
    this.reloadAfterPop = false,
  });
}
class ThongKeGrid extends StatelessWidget {
  final List<Item> items;
  final Function(Item) onTap;
  const ThongKeGrid({
    Key? key,
    required this.items,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3, // 2 cột
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      childAspectRatio: 0.9,
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: items.map((item){
        return _StatCard(
          icon: item.icon,
          label: item.label,
          value: item.value,
          color: item.color,
          onTap: () => onTap(item));
      }).toList(),
    );
  }
}
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔹 Icon nhỏ + có nền
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),

          const SizedBox(height: 2),

          // 🔥 SỐ (trung tâm)
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 2),

          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    return onTap != null
        ? InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: card,
    )
        : card;
  }
}

