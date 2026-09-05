import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DesktopSidebar extends StatefulWidget {
  const DesktopSidebar({super.key});

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _isExpanded ? 250 : 72,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 30),

// =========================
// HEADER
// =========================
          if (_isExpanded)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'NHẬT KÝ XÂY DỰNG',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263238),
                ),
              ),
            )
          else
            const Icon(
              Icons.construction_outlined,
              size: 28,
              color: Color(0xff263238),
            ),

          const SizedBox(height: 30),

// =========================
// MENU
// =========================
          _menuItem(
            context,
            currentPath,
            icon: Icons.dashboard_outlined,
            title: 'Tổng quan',
            route: '/',
          ),

          _menuItem(
            context,
            currentPath,
            icon: Icons.business_outlined,
            title: 'Công trình',
            route: '/cong-trinh',
          ),

          _menuItem(
            context,
            currentPath,
            icon: Icons.money,
            title: 'Hạng mục thu chi',
            route: '/danh-muc-thu-chi',
          ),

          _menuItem(
            context,
            currentPath,
            icon: Icons.people_outline,
            title: 'Nhân viên',
            route: '/nhan-vien',
          ),

          _menuItem(
            context,
            currentPath,
            icon: Icons.payments_outlined,
            title: 'Lương cơ bản',
            route: '/luong-co-ban',
          ),

          const Spacer(),

// =========================
// TOGGLE SIDEBAR
// =========================
          _toggleButton(),

          const SizedBox(height: 10),

// =========================
// SETTINGS
// =========================
          _menuItem(
            context,
            currentPath,
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            route: '/setting',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

// =========================================================
// MENU ITEM
// =========================================================

  Widget _menuItem(
    BuildContext context,
    String currentPath, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    final bool isActive = route == '/'
        ? currentPath == '/'
        : currentPath == route || currentPath.startsWith('$route/');

    final Color activeColor = Colors.blue.shade700;
    const Color normalColor = Color(0xff4b4850);

    final Widget item = Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color:
            isActive ? Colors.blue.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: _isExpanded ? 12 : 0,
        ),
        horizontalTitleGap: 12,
        leading: Icon(
          icon,
          color: isActive ? activeColor : normalColor,
        ),
        title: _isExpanded
            ? Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? activeColor : normalColor,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              )
            : null,
        onTap: () {
          if (!isActive) {
            context.go(route);
          }
        },
      ),
    );

// Khi sidebar đóng thì hiển thị tooltip
    if (!_isExpanded) {
      return Tooltip(
        message: title,
        waitDuration: const Duration(milliseconds: 300),
        child: item,
      );
    }

    return item;
  }

// =========================================================
// TOGGLE BUTTON
// =========================================================

  Widget _toggleButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Container(
            height: 44,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: _isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                Icon(
                  _isExpanded ? Icons.chevron_left : Icons.chevron_right,
                  color: const Color(0xff4b4850),
                ),
                if (_isExpanded) ...[
                  const SizedBox(width: 12),
                  const Text(
                    'Thu gọn',
                    style: TextStyle(
                      color: Color(0xff4b4850),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
