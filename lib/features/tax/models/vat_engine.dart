import '../models/invoice_model.dart';
import '../models/purchase_invoice_model.dart';

class VatEngine {
  static double totalSalesVat(List<Invoice> invoices) {
    return invoices.fold(
      0,
          (sum, e) => sum + e.vatAmount,
    );
  }

  static double totalPurchaseVat(List<PurchaseInvoice> invoices) {
    return invoices.fold(
      0,
          (sum, e) => sum + e.vatAmount,
    );
  }

  static double payableVat(
      List<Invoice> sales,
      List<PurchaseInvoice> purchase,
      ) {
    return totalSalesVat(sales) - totalPurchaseVat(purchase);
  }

  static double totalRevenue(List<Invoice> invoices) {
    return invoices.fold(
      0,
          (sum, e) => sum + e.netAmount,
    );
  }
}