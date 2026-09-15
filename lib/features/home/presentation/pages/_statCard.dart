// import 'package:flutter/material.dart';
//
// Widget statCard({
//   required IconData icon,
//   required String title,
//   required String value,
//   required String subtitle,
// }) {
//   return Container(
//     height: 130,
//     padding: const EdgeInsets.all(20),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       border: Border.all(
//         color: Colors.grey.shade200,
//       ),
//     ),
//     child: Row(
//       children: [
//         Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: Colors.orange.withOpacity(.12),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(
//             icon,
//             color: Colors.orange,
//             size: 26,
//           ),
//         ),
//
//         const SizedBox(width: 16),
//
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                   fontSize: 14,
//                 ),
//               ),
//
//               const SizedBox(height: 6),
//
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2C3E50),
//                 ),
//               ),
//
//               Text(
//                 subtitle,
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: Colors.grey.shade500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }