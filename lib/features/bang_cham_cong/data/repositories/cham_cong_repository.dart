// import 'package:sqflite/sqflite.dart';
//
// import '../db_helper.dart';
// import '../models/ChamCong.dart';
// import '../models/NhanVien.dart';
// import '../models/NhanVienCongTrinh.dart';
//
// class ChamCongRepository {
//   final _dbHelper = DBHelper.instance;
//
//   Future<List<ChamCong>> getChamCongByDate(int idCongTrinh, String ngay) async {
//     final db = await _dbHelper.database;
//     final result = await db.rawQuery('''
//       SELECT cc.*
//       FROM cham_cong cc
//       INNER JOIN nhan_vien_cong_trinh nvct
//         ON cc.id_nhan_vien_cong_trinh = nvct.id
//       WHERE nvct.idCongTrinh = ? AND cc.ngay = ?
//     ''', [idCongTrinh, ngay]);
//     return result.map((e) => ChamCong.fromMap(e)).toList();
//   }
//
//   // Future<List<ChamCong>> getChamCong(int idCongTrinh) async {
//   //   final db = await _dbHelper.database;
//   //   final result = await db.rawQuery('''
//   //     SELECT cc.*
//   //     FROM cham_cong cc
//   //     INNER JOIN nhan_vien_cong_trinh nvct
//   //       ON cc.id_nhan_vien_cong_trinh = nvct.id
//   //     WHERE nvct.idCongTrinh = ?
//   //   ''', [idCongTrinh]);
//   //   return result.map((e) => ChamCong.fromMap(e)).toList();
//   // }
//
//   Future<List<ChamCong>> getChamCong(int idCongTrinh) async {
//     final db = await _dbHelper.database;
//
//     final result = await db.rawQuery('''
//     SELECT
//       -- ChamCong
//       cc.id AS cc_id, cc.id_nhan_vien_cong_trinh, cc.ngay, cc.trang_thai_sang,
//       cc.trang_thai_chieu, cc.tang_ca_bat_dau, cc.tang_ca_ket_thuc, cc.ghi_chu, cc.ngay_tao,
//
//       -- NhanVienCongTrinh
//       nvct.id AS nvct_id, nvct.idNhanVien AS nvct_idNhanVien, nvct.idCongTrinh AS nvct_idCongTrinh,
//       nvct.ngayBatDau, nvct.ngayKetThuc, nvct.vaiTro,
//
//       -- NhanVien
//       nv.id AS nv_id, nv.ho_ten, nv.email, nv.so_dien_thoai, nv.hinh_anh, nv.dia_chi, nv.ngay_sinh, nv.user_id
//     FROM cham_cong cc
//     INNER JOIN nhan_vien_cong_trinh nvct
//       ON cc.id_nhan_vien_cong_trinh = nvct.id
//     INNER JOIN nhan_vien nv
//       ON nv.id = nvct.idNhanVien
//     WHERE nvct.idCongTrinh = ?
//   ''', [idCongTrinh]);
//
//     return result.map((e) {
//       // Map ChamCong
//       final chamCong = ChamCong(
//         id: e['cc_id'] as int?,
//         idNhanVienCongTrinh: e['id_nhan_vien_cong_trinh'] as int,
//         ngay: e['ngay'] as String,
//         trangThaiSang: e['trang_thai_sang'] as int?,
//         trangThaiChieu: e['trang_thai_chieu'] as int?,
//         ghiChu: e['ghi_chu'] as String?,
//       );
//
//       // Map NhanVien
//       final nhanVien = NhanVien(
//         id: e['nv_id'] as int?,
//         hoTen: e['ho_ten'] as String?,
//         email: e['email'] as String?,
//         soDienThoai: e['so_dien_thoai'] as String?,
//         hinhAnh: e['hinh_anh'] as String?,
//         diaChi: e['dia_chi'] as String?,
//         ngaySinh: e['ngay_sinh'] as String?,
//         userId: e['user_id'] as int?,
//       );
//
//       // Map NhanVienCongTrinh
//       final nvct = NhanVienCongTrinh(
//         id: e['nvct_id'] as int?,
//         idNhanVien: e['nvct_idNhanVien'] as int,
//         idCongTrinh: e['nvct_idCongTrinh'] as int,
//         ngayBatDau: e['ngayBatDau'] as String?,
//         ngayKetThuc: e['ngayKetThuc'] as String?,
//         vaiTro: e['vaiTro'] as String?,
//         nhanVien: nhanVien,
//       );
//       chamCong.nhanVienCongTrinh = nvct;
//
//       return chamCong;
//     }).toList();
//   }
//
//
//   Future<int> insert(ChamCong cc) async {
//     final db = await _dbHelper.database;
//     return await db.insert('cham_cong', cc.toMap());
//   }
//
//   // giả sử gọi API hoặc DB
//   // SELECT nv.hoTen, cc.trangThaiSang, cc.trangThaiChieu
//   // FROM ChamCong cc
//   // JOIN NhanVienCongTrinh nvct ON nvct.id = cc.idNhanVienCongTrinh
//   // JOIN NhanVien nv ON nv.id = nvct.idNhanVien
//   // WHERE nvct.idCongTrinh = :idCongTrinh AND cc.ngay = :ngay
//
//   Future<int> update(ChamCong cc) async {
//     final db = await _dbHelper.database;
//     return await db.update(
//       'cham_cong',
//       cc.toMap(),
//       where: 'id = ?',
//       whereArgs: [cc.id],
//     );
//   }
// }
