import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
final currencyFormat =
NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);


double parseCurrency(String text) {
  final cleaned = text
      .replaceAll('₫', '')
      .replaceAll(RegExp(r'[^\d]'), ''); // bỏ hết ký tự không phải số

  return double.tryParse(cleaned) ?? 0;
}

String formatCurrency(num value) {
  return currencyFormat.format(value);
}

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    String cleanText = newValue.text.replaceAll(',', '');
    final number = int.tryParse(cleanText);
    if (number == null) return oldValue;
    final newText = _formatter.format(number);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}