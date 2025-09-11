import 'package:flutter/material.dart';

import 'may_tinh.dart';
import 'website.dart';

class ToolList extends StatefulWidget {
  const ToolList({super.key});

  @override
  State<ToolList> createState() => _ToolListState();
}

class _ToolListState extends State<ToolList> {
  final List<Map<String, dynamic>> tools = [
    {"icon": Icons.language_outlined, "label": "Website"},
    {"icon": Icons.calculate_outlined, "label": "Máy tính"},
  ];

  void _navigateToTool(BuildContext context, String label) {
    if (label == "Website") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WebsiteScreen()),
      );
    } else if (label == "Máy tính") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CalculatorScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Công cụ",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _navigateToTool(context, tool["label"]),
                splashColor: Colors.blue.withOpacity(0.2),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tool["icon"],
                        size: 36,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        tool["label"],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
