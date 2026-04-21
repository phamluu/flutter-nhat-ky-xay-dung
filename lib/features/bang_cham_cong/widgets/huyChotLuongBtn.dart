// import 'package:flutter/material.dart';
// import '../../../viewmodel/ChamCongModel.dart';
// import '../../../services/ChotChiLuongService.dart';
// import 'chot_luong_dialog.dart';
//
// class HuyChotLuongButton extends StatelessWidget {
//   final ChamCongModel nv;
//   final Chotchiluongservice service;
//   final Future<void> Function() onReload;
//
//   const HuyChotLuongButton({
//     super.key,
//     required this.nv,
//     required this.service,
//     required this.onReload,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () async {
//         await ChotLuongHelper.showConfirmHuyChot(
//           context: context,
//           idBangLuong: nv.idBangLuong!,
//           service: service,
//           onSuccess: () async {
//             await onReload();
//           },
//         );
//       },
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.red,
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         minimumSize: const Size(0, 30),
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),
//       child: const Text(
//         "Hủy chốt",
//         style: TextStyle(color: Colors.white),
//       ),
//     );
//   }
// }