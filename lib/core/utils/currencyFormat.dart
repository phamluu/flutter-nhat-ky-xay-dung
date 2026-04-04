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