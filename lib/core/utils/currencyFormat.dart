import 'package:intl/intl.dart';
final currencyFormat =
NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);


double parseCurrency(String text) {
  final cleaned = text.replaceAll(RegExp(r'[.,]'), '');
  return double.tryParse(cleaned) ?? 0;
}