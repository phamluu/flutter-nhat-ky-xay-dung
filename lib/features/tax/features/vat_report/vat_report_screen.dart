import 'package:flutter/material.dart';

import '../../models/invoice_model.dart';
import '../../models/purchase_invoice_model.dart';
import '../../models/vat_engine.dart';
import '../../utils/period_utils.dart';

class VatReportScreen extends StatefulWidget {
  @override
  State<VatReportScreen> createState() => _VatReportScreenState();
}

class _VatReportScreenState extends State<VatReportScreen> {
  int year = 2026;
  int quarter = 1;

  List<Invoice> sales = [];
  List<PurchaseInvoice> purchases = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    sales = [
      Invoice(
        id: "1",
        number: "HD001",
        date: DateTime(2026, 1, 10),
        customerName: "Cty A",
        netAmount: 2000000,
        vatRate: 0.1,
      ),
      Invoice(
        id: "2",
        number: "HD002",
        date: DateTime(2026, 2, 10),
        customerName: "Cty B",
        netAmount: 3000000,
        vatRate: 0.1,
      ),
    ];

    purchases = [
      PurchaseInvoice(
        id: "P1",
        number: "NH001",
        date: DateTime(2026, 1, 5),
        supplierName: "Nhà cung cấp A",
        netAmount: 1000000,
        vatAmount: 100000,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filteredSales = sales
        .where((e) => PeriodUtils.inQuarter(e.date, year, quarter))
        .toList();

    final filteredPurchase = purchases
        .where((e) => PeriodUtils.inQuarter(e.date, year, quarter))
        .toList();

    final revenue = VatEngine.totalRevenue(filteredSales);
    final salesVat = VatEngine.totalSalesVat(filteredSales);
    final purchaseVat = VatEngine.totalPurchaseVat(filteredPurchase);
    final payable = salesVat - purchaseVat;

    return Scaffold(
      appBar: AppBar(
        title: Text("Báo cáo thuế GTGT"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => InvoiceDialog(
              onSave: (invoice) {
                addInvoice(invoice);
              },
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          // ================= FILTER =================
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                _dropdownQuarter(),
                SizedBox(width: 10),
                _dropdownYear(),
              ],
            ),
          ),

          // ================= SUMMARY =================
          Padding(
            padding: const EdgeInsets.all(10),
            child: _buildSummary(
              revenue,
              salesVat,
              purchaseVat,
              payable,
            ),
          ),

          // ================= LIST =================
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.blue,
                    tabs: [
                      Tab(text: "Hóa đơn bán ra"),
                      Tab(text: "Hóa đơn mua vào"),
                    ],
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSalesList(filteredSales),
                        _buildPurchaseList(filteredPurchase),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY CARD =================
  Widget _buildSummary(
      double revenue,
      double salesVat,
      double purchaseVat,
      double payable,
      ) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ===== ROW 1 =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem("Doanh thu", revenue, Colors.blue),
                _summaryItem("Thuế ra", salesVat, Colors.green),
                _summaryItem("Thuế vào", purchaseVat, Colors.orange),
                _summaryItem("Phải nộp", payable, Colors.red),
              ],
            ),

            SizedBox(height: 12),

            // ===== BUTTON EXPORT XML =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: exportXml,
                icon: Icon(Icons.file_download, color: Colors.white,),
                label: Text("Xuất XML 01/GTGT", style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, double value, Color color) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 5),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ================= SALES LIST =================
  Widget _buildSalesList(List<Invoice> list) {
    return ListView.separated(
      padding: EdgeInsets.all(10),
      itemCount: list.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, i) {
        final e = list[i];

        return ListTile(
          leading: Icon(Icons.arrow_upward, color: Colors.green),
          title: Text(e.number),
          subtitle: Text(e.customerName),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(e.netAmount.toStringAsFixed(0)),
              Text(
                "VAT: ${e.vatAmount.toStringAsFixed(0)}",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= PURCHASE LIST =================
  Widget _buildPurchaseList(List<PurchaseInvoice> list) {
    return ListView.separated(
      padding: EdgeInsets.all(10),
      itemCount: list.length,
      separatorBuilder: (_, __) => Divider(),
      itemBuilder: (context, i) {
        final e = list[i];

        return ListTile(
          leading: Icon(Icons.arrow_downward, color: Colors.red),
          title: Text(e.number),
          subtitle: Text(e.supplierName),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(e.netAmount.toStringAsFixed(0)),
              Text(
                "VAT: ${e.vatAmount.toStringAsFixed(0)}",
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= DROPDOWNS =================
  Widget _dropdownQuarter() {
    return DropdownButton<int>(
      value: quarter,
      items: [1, 2, 3, 4]
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text("Quý $e"),
      ))
          .toList(),
      onChanged: (v) => setState(() => quarter = v!),
    );
  }

  Widget _dropdownYear() {
    return DropdownButton<int>(
      value: year,
      items: [2025, 2026, 2027]
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text("Năm $e"),
      ))
          .toList(),
      onChanged: (v) => setState(() => year = v!),
    );
  }

  void addInvoice(Invoice invoice) {
    setState(() {
      sales.add(invoice);
    });
  }

  void deleteInvoice(String id) {
    setState(() {
      sales.removeWhere((e) => e.id == id);
    });
  }

  void updateInvoice(Invoice updated) {
    setState(() {
      final index = sales.indexWhere((e) => e.id == updated.id);
      if (index != -1) {
        sales[index] = updated;
      }
    });
  }
  void exportXml(){

  }
}

class InvoiceDialog extends StatefulWidget {
  final Function(Invoice) onSave;

  InvoiceDialog({required this.onSave});

  @override
  State<InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<InvoiceDialog> {
  final numberCtrl = TextEditingController();
  final customerCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Thêm hóa đơn"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: numberCtrl, decoration: InputDecoration(labelText: "Số HĐ")),
          TextField(controller: customerCtrl, decoration: InputDecoration(labelText: "Khách hàng")),
          TextField(controller: amountCtrl, decoration: InputDecoration(labelText: "Tiền")),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Huỷ"),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(
              Invoice(
                id: DateTime.now().toString(),
                number: numberCtrl.text,
                date: DateTime.now(),
                customerName: customerCtrl.text,
                netAmount: double.parse(amountCtrl.text),
                vatRate: 0.1,
              ),
            );
            Navigator.pop(context);
          },
          child: Text("Lưu"),
        ),
      ],
    );
  }
}