import 'package:flutter/material.dart';

class NavItem {
  final IconData icon;
  final String label;
  final Widget page;
  final bool reloadAfterPop;
  final Color color;
  NavItem({
    required this.icon,
    required this.label,
    required this.page,
    this.reloadAfterPop = false,
    required this.color
  });
}
class CustomBottomNavBar extends StatelessWidget {
  final List<NavItem> items;
  final Function(NavItem) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            return _buildNavItem(
              context,
              icon: item.icon,
              label: item.label,
              color: item.color,
              onTap: () => onTap(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return SizedBox(
      width: 65,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color,),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11,), ),
          ],
        ),
      ),
    );
  }
}