import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final VoidCallback onProjectsTap;  // Công trình
  final VoidCallback onEmployeesTap;     // Nhật ký
  final VoidCallback onFinanceTap;   // Thu chi
  final VoidCallback onCheckInTap;   // Chấm công
  final VoidCallback onProfileTap;   // Tôi

  const CustomBottomNavBar({
    Key? key,
    required this.onProjectsTap,
    required this.onEmployeesTap,
    required this.onFinanceTap,
    required this.onCheckInTap,
    required this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 70,
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
              children: [
                // Nhóm trái
                _buildNavItem(
                  context,
                  icon: Icons.apartment, // Công trình
                  label: 'Công trình',
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: onProjectsTap,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.person, // Nhân viên
                  label: 'Nhân viên',
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: onEmployeesTap,
                ),

                //const SizedBox(width: 75), // Chừa khoảng trống cho nút giữa
                _buildNavItem(
                  context,
                  icon: Icons.money, // Thu chi
                  label: 'Lương',
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: onFinanceTap,
                ),
                // Nhóm phải
                // _buildNavItem(
                //   context,
                //   icon: Icons.account_balance_wallet, // Thu chi
                //   label: 'Thu chi',
                //   color: Theme.of(context).colorScheme.secondary,
                //   onTap: onFinanceTap,
                // ),
                _buildNavItem(
                  context,
                  icon: Icons.person, // Tôi
                  label: 'Tôi',
                  color: Colors.grey[500]!,
                  onTap: onProfileTap,
                ),
              ],
            ),
          ),

          // Nút giữa
          // _buildCenterButton(context, onCheckInTap),
        ],
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context, VoidCallback onTap) {
    return Positioned(
      top: -20,
      left: MediaQuery.of(context).size.width / 2 - 28,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.access_time, // Chấm công
                color: Colors.pink,
                size: 35,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Chấm công",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
