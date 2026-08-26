// import 'package:flutter/material.dart';
// import '../../../core/utils/trang_thai_luong.dart';
// import '../../luong/presentation/chi_luong/pages/chi_luong_page.dart';
// import '../data/services/ChotChiLuongService.dart';
// import '../data/models/ChamCongModel.dart';
//
// // class BangLuongActionCell extends StatelessWidget {
// //   final ChamCongNhanVienModel nv;
// //   final int? idBangChamCong;
// //   final String? tenCongTrinh;
// //   final Chotchiluongservice service;
// //   final bool daKhoaCC;
// //   final Future<void> Function() onReload;
// //
// //   const BangLuongActionCell({
// //     super.key,
// //     required this.nv,
// //     this.idBangChamCong,
// //     this.tenCongTrinh,
// //     required this.service,
// //     required this.daKhoaCC,
// //     required this.onReload,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final trangthai = TrangThaiLuong.fromValue(nv.trangThaiChotLuong);
// //
// //     // Đã chốt lương
// //     if (trangthai == TrangThaiLuong.dachot) {
// //       if (nv.tongDaChi == 0) {
// //         return Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             HuyChotLuongButton(
// //               nv: nv,
// //               service: service,
// //               onReload: onReload,
// //             ),
// //             const SizedBox(width: 3),
// //             ChiLuongButton(
// //               nv: nv,
// //               idBangChamCong: idBangChamCong!,
// //               tenCongTrinh: tenCongTrinh,
// //               onReload: onReload,
// //             ),
// //           ],
// //         );
// //       }
// //
// //       return ChiLuongButton(
// //         nv: nv,
// //         idBangChamCong: idBangChamCong!,
// //         tenCongTrinh: tenCongTrinh,
// //         onReload: onReload,
// //       );
// //     }
// //
// //     // Chưa khóa chấm công thì không cho chốt lương
// //     if (!daKhoaCC) {
// //       return ElevatedButton(
// //         onPressed: () {
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             const SnackBar(
// //               content: Text(
// //                 'Vui lòng khóa chấm công trước khi chốt lương.',
// //               ),
// //             ),
// //           );
// //         },
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: Colors.grey,
// //           padding: const EdgeInsets.symmetric(
// //             horizontal: 8,
// //             vertical: 4,
// //           ),
// //           minimumSize: const Size(0, 20),
// //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// //         ),
// //         child: const Text(
// //           "Chưa khóa công",
// //           style: TextStyle(color: Colors.white),
// //         ),
// //       );
// //     }
// //
// //     // Đã khóa công -> cho phép chốt lương
// //     return ElevatedButton(
// //       onPressed: () async {
// //         try {
// //           await ChotLuongHelper.showConfirmChot(
// //             context: context,
// //             nv: nv,
// //             idBangChamCong: idBangChamCong!,
// //             service: service,
// //             onSuccess: onReload,
// //           );
// //         } catch (e) {
// //           if (!context.mounted) return;
// //
// //           ScaffoldMessenger.of(context).showSnackBar(
// //             SnackBar(
// //               content: Text(
// //                 'Lỗi chốt lương: $e',
// //               ),
// //             ),
// //           );
// //         }
// //       },
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor: Colors.green,
// //         padding: const EdgeInsets.symmetric(
// //           horizontal: 8,
// //           vertical: 4,
// //         ),
// //         minimumSize: const Size(0, 20),
// //         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
// //       ),
// //       child: const Text(
// //         "Chốt lương",
// //         style: TextStyle(color: Colors.white),
// //       ),
// //     );
// //   }
// // }
// class ChiLuongButton extends StatelessWidget {
//   final ChamCongNhanVienModel nv;
//   final int idBangChamCong;
//   final String? tenCongTrinh;
//   final Future<void> Function() onReload;
//
//   const ChiLuongButton({
//     super.key,
//     required this.nv,
//     required this.idBangChamCong,
//     this.tenCongTrinh,
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
//             builder: (_) => ChiLuongPage(
//               idBangLuong: nv.idBangLuong!,
//               tenNhanVien: nv.ten,
//               tenCongTrinh: tenCongTrinh,
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
//         minimumSize: const Size(0, 20),
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),
//       child: const Text(
//         "Chi lương",
//         style: TextStyle(color: Colors.white),
//       ),
//     );
//   }
// }
//
// class HuyChotLuongButton extends StatelessWidget {
//   final ChamCongNhanVienModel nv;
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
//         minimumSize: const Size(0, 20),
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),
//       child: const Text(
//         "Hủy chốt",
//         style: TextStyle(color: Colors.white),
//       ),
//     );
//   }
// }
//
// class ChotLuongHelper {
//   static Future<void> showConfirmChot({
//     required BuildContext context,
//     required ChamCongNhanVienModel nv,
//     required int idBangChamCong,
//     required Chotchiluongservice service,
//     required Future<void> Function() onSuccess,
//   }) async {
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text("Xác nhận"),
//         content: Text("Chốt lương cho ${nv.ten}?"),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(dialogContext, false);
//             },
//             child: const Text("Huỷ"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(dialogContext, true);
//             },
//             child: const Text("Chốt"),
//           ),
//         ],
//       ),
//     );
//
//     if (ok != true) return;
//
//     try {
//       await service.chotLuong(
//         nv: nv,
//         idBangChamCong: idBangChamCong
//       );
//
//       await onSuccess();
//     } catch (e) {
//       if (!context.mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Chốt lương thất bại: $e"),
//         ),
//       );
//     }
//   }
//
//   static Future<void> showConfirmHuyChot({
//     required BuildContext context,
//     required int idBangLuong,
//     required Chotchiluongservice service,
//     required Future<void> Function() onSuccess,
//   }) async {
//     final ok = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         title: const Text("Xác nhận"),
//         content: const Text("Bạn có chắc muốn hủy chốt lương?"),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(dialogContext, false);
//             },
//             child: const Text("Huỷ"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(dialogContext, true);
//             },
//             child: const Text("Hủy chốt"),
//           ),
//         ],
//       ),
//     );
//
//     if (ok != true) return;
//
//     try {
//       await service.huyChot(
//         idBangLuong: idBangLuong,
//       );
//
//       await onSuccess();
//     } catch (e) {
//       if (!context.mounted) return;
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Hủy chốt lương thất bại: $e"),
//         ),
//       );
//     }
//   }
// }