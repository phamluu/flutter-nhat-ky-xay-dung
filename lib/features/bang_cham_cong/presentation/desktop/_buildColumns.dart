import 'package:flutter/material.dart';

import 'isShowNgay.dart';


// --- NHÓM CỘT TỔNG CÔNG (3 CỘT) ---
const TextStyle headerTopStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 10,
  color: Colors.grey,
);
const TextStyle headerSubStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 11,
);

// Định nghĩa kiểu Style chung
const TextStyle headerTitleStyle = TextStyle(
  fontWeight: FontWeight.w700,
  fontSize: 12,
  color: Colors.black87,
);

List<DataColumn> buildColumns(int soNgay, bool _showChucVu, bool _show10Dau,  bool _show10Giua,  bool _show10Cuoi) {
  final columns = <DataColumn>[];
  columns.add(
    const DataColumn(
      label: SizedBox(
        width: 170,
        child: Text(
          "HỌ TÊN",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
  if (_showChucVu) {
    columns.add(
      const DataColumn(
        label: SizedBox(
          width: 110,
          child: Text(
            "CHỨC VỤ",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  for (int i = 1; i <= soNgay; i++) {
    if (isShowNgay(i, _show10Dau,  _show10Giua,  _show10Cuoi)) {
      columns.add(
        DataColumn(
          numeric: true,
          label: SizedBox(
            width: 35,
            child: Center(
              child: Text(
                "$i",
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
  // Thay thế DataColumn("TỔNG CÔNG") cũ bằng 3 DataColumn mới này:


// 1. Cột TỔNG CÔNG (Đã gộp chung 1 Header phía trên và 3 cột con phía dưới)
  columns.add(
    DataColumn(
      label: Container(
        width: 140, // Tổng chiều rộng cho cả 3 cột con (70 * 3)
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hàng 1: Tiêu đề dùng chung (Căn giữa hoàn toàn)
            const Text(
              "TỔNG CÔNG",
              style: headerTitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 4),
            // Hàng 2: Chia làm 3 cột con
            Row(
              children: const [
                Expanded(
                  child: Text("Tổng", style: headerSubStyle, textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text("Đã chốt", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.green), textAlign: TextAlign.center),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
// Gộp tổng lương
  columns.add(
    DataColumn(
      label: Container(
        width: 200, // Tổng chiều rộng cho cả 3 cột con (70 * 3)
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hàng 1: Tiêu đề dùng chung (Căn giữa hoàn toàn)
            const Text(
              "TỔNG LƯƠNG",
              style: headerTitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 4),
            // Hàng 2: Chia làm 3 cột con
            Row(
              children: const [
                Expanded(
                  child: Text("Dự kiến", style: headerSubStyle, textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text("Đã chốt", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.green), textAlign: TextAlign.center),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  // Gộp ứng lương
  columns.add(
    DataColumn(
      label: Container(
        width: 200, // Tổng chiều rộng cho cả 2 cột con (70 * 3)
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hàng 1: Tiêu đề dùng chung (Căn giữa hoàn toàn)
            const Text(
              "ỨNG LƯƠNG",
              style: headerTitleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 4),
            // Hàng 2: Chia làm 3 cột con
            Row(
              children: const [
                Expanded(
                  child: Text("Đã ứng", style: headerSubStyle, textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text("Trừ ứng", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.green), textAlign: TextAlign.center),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  columns.add(
    const DataColumn(
      label: Text( "THỰC NHẬN",style: TextStyle( fontWeight: FontWeight.w700, fontSize: 12, ),
      ),
    ),
  );
  columns.add(
    const DataColumn(
      label: Text(
        "CHI LƯƠNG", style: TextStyle( fontWeight: FontWeight.w700, fontSize: 12,
        ),
      ),
    ),
  );
  columns.add(
    DataColumn(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Còn phải trả',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: 'Số tiền khách hàng còn phải thanh toán',
            child: Container(
              width: 15,
              height: 15,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: const Text(
                '?',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
  return columns;
}