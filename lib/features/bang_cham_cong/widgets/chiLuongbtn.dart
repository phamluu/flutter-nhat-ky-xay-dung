// import 'package:flutter/material.dart';
// import '../../chi_luong/ChiLuongScreen.dart';
// import '../../../viewmodel/ChamCongModel.dart';
//
// class ChiLuongButton extends StatelessWidget {
//   final ChamCongModel nv;
//   final Future<void> Function() onReload;
//
//   const ChiLuongButton({
//     super.key,
//     required this.nv,
//     required this.onReload,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () async {
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ChiLuongScreen(
//               idBangLuong: nv.idBangLuong!,
//               tenNhanVien: nv.ten,
//               tongPhaiTra: nv.thucNhanHienThi ?? 0,
//             ),
//           ),
//         );
//
//         if (result == true) {
//           await onReload();
//         }
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.blue,
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         minimumSize: const Size(0, 30),
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),
//       child: const Text(
//         "Chi lương",
//         style: TextStyle(color: Colors.white),
//       ),
//     );
//   }
// }