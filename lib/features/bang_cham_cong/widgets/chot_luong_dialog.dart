// import 'package:flutter/material.dart';
// import '../../../services/ChotChiLuongService.dart';
// import '../../../viewmodel/ChamCongModel.dart';
//
// class ChotLuongHelper {
//   static Future<void> showConfirmChot({
//     required BuildContext context,
//     required ChamCongModel nv,
//     required int thang,
//     required int nam,
//     required Chotchiluongservice service,
//     required VoidCallback onSuccess,
//   }) async {
//     final ok = await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Xác nhận"),
//         content: Text("Chốt lương cho ${nv.ten}?"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("Huỷ"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Chốt"),
//           ),
//         ],
//       ),
//     );
//
//     if (ok == true) {
//       await service.chotLuong(
//         nv: nv,
//         thang: thang,
//         nam: nam,
//       );
//
//       onSuccess();
//     }
//   }
//
//   static Future<void> showConfirmHuyChot({
//     required BuildContext context,
//     required int idBangLuong,
//     required Chotchiluongservice service,
//     required VoidCallback onSuccess,
//   }) async {
//     final ok = await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Xác nhận"),
//         content: const Text("Hủy chốt lương"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("Huỷ"),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Hủy chốt"),
//           ),
//         ],
//       ),
//     );
//
//     if (ok == true) {
//       await service.huyChot(idBangLuong: idBangLuong);
//       onSuccess();
//     }
//   }
// }