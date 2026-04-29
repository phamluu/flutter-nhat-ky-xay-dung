class Invoice {
  final String id;
  final String number;
  final DateTime date;
  final String customerName;

  final double netAmount; // chưa thuế
  final double vatRate;   // 0.1 = 10%

  Invoice({
    required this.id,
    required this.number,
    required this.date,
    required this.customerName,
    required this.netAmount,
    required this.vatRate,
  });

  double get vatAmount => netAmount * vatRate;
  double get total => netAmount + vatAmount;
}