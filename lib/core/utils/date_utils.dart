import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtilsCore {
  static String formatDate(String? date) {
    if (date == null || date.isEmpty) return "";
    try {
      final d = DateTime.parse(date);
      return DateFormat("dd/MM/yyyy").format(d);
    } catch (e) {
      return date ?? "";
    }
  }
  static Future<void> pickDate(
      BuildContext context,
      TextEditingController controller, {
        String format = "yyyy-MM-dd",
      }) async {
    DateTime initial = DateTime.tryParse(controller.text) ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = DateFormat(format).format(picked);
    }
  }
}
