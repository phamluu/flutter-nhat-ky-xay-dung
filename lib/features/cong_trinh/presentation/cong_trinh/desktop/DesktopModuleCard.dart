import 'package:flutter/material.dart';

class DesktopModuleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const DesktopModuleCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  State<DesktopModuleCard> createState() =>
      _DesktopModuleCardState();
}

class _DesktopModuleCardState
    extends State<DesktopModuleCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,

      onEnter: (_) {
        setState(() {
          _hover = true;
        });
      },

      onExit: (_) {
        setState(() {
          _hover = false;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hover
              ? widget.color.withOpacity(.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hover
                ? widget.color.withOpacity(.35)
                : Colors.grey.shade200,
          ),
        ),

        child: Material(
          color: Colors.transparent,

          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,

            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,

                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                    ),

                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          widget.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: _hover
                        ? widget.color
                        : Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}