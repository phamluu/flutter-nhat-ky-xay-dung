class PurchaseInvoice {
  final String id;
  final String number;
  final DateTime date;
  final String supplierName;

  final double netAmount;
  final double vatAmount;

  PurchaseInvoice({
    required this.id,
    required this.number,
    required this.date,
    required this.supplierName,
    required this.netAmount,
    required this.vatAmount,
  });
}