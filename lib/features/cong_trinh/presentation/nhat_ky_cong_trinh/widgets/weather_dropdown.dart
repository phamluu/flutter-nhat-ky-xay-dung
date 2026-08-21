import 'package:flutter/material.dart';

DropdownButtonFormField<int> buildWeatherDropdown({
  required int? value,
  required String label,
  required Function(int?) onChanged,
}) {
  return DropdownButtonFormField<int>(
    value: value,
    decoration: InputDecoration(labelText: label),
    items: const [
      DropdownMenuItem(value: 0, child: Text("☀️ Nắng")),
      DropdownMenuItem(value: 1, child: Text("🌧️ Mưa")),
      DropdownMenuItem(value: 2, child: Text("☁️ Mây")),
    ],
    onChanged: onChanged,
  );
}
/// Map thời tiết từ int -> icon + text
IconData _getWeatherIcon(int? value) {
  switch (value) {
    case 0:
      return Icons.wb_sunny; // Nắng
    case 1:
      return Icons.umbrella; // Mưa
    case 2:
      return Icons.cloud; // Mây
    default:
      return Icons.help_outline;
  }
}
/// Hàm helper để convert từ int -> text
String getWeatherText(int? value) {
  switch (value) {
    case 0:
      return "Nắng";
    case 1:
      return "Mưa";
    case 2:
      return "Mây";
    default:
      return "-";
  }
}

Widget buildWeatherInfo(String title, int? value) {
  return Row(
    children: [
      Icon(_getWeatherIcon(value), color: Colors.blueGrey),
      const SizedBox(width: 6),
      Text("$title: ${getWeatherText(value)}"),
    ],
  );
}