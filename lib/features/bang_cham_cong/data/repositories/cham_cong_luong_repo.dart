import 'package:nhat_ky_xay_dung/core/utils/trang_thai_khoa_cong.dart';
import 'package:nhat_ky_xay_dung/core/utils/trang_thai_luong.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_chi_tiet_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/cham_cong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/ky_luong_table.dart';
import 'package:nhat_ky_xay_dung/data/tables/phien_chot_cong_table.dart';
import 'package:nhat_ky_xay_dung/features/bang_cham_cong/data/models/phien_chot_cong.dart';
import 'package:nhat_ky_xay_dung/features/luong/data/enums.dart';

import '../../../../data/db_helper.dart';

class ChamCongLuongRepo {
  final _dbHelper = DBHelper.instance;

  Future<void>DeleteData(int? idBangChamCong) async{
    final db = await _dbHelper.database;
    // Kiểm tra bảng chấm công đang khóa => không được xóa
    // Kiểm tra tồn tại kỳ lương đã chốt => không được xóa
    final results = await Future.wait([
        db.query(ChamCongTable.tableName,
                columns: [ChamCongTable.id],
                where: '${ChamCongTable.id} = ? AND ${ChamCongTable.daKhoa} = ${TrangThaiKhoaChamCong.dakhoa.value}',
                whereArgs: [idBangChamCong],
                limit: 1
                ),
      db.query(KyLuongTable.tableName,
          columns: [KyLuongTable.id],
          where: '${KyLuongTable.idBangChamCong} = ? AND ${KyLuongTable.trangThai} = ?',
          whereArgs: [idBangChamCong, TrangThaiLuong.dachot.value],
          limit: 1
      )
    ]);
    if(results[0].isNotEmpty){
      throw Exception('Bảng chấm đã khóa. Hãy mở khóa chấm công trước');
    }
    if(results[1].isNotEmpty){
      throw Exception('Bảng chấm công còn tồn tại dữ liệu kỳ lương đã chốt. Hãy hủy chốt lương trước');
    }
    try{
      await db.delete(KyLuongTable.tableName, where: '${KyLuongTable.idBangChamCong} = ?',
          whereArgs: [idBangChamCong]);
      await db.delete(ChamCongChiTietTable.tableName, where: '${ChamCongChiTietTable.idChamCong} = ?',
          whereArgs: [idBangChamCong]);
    }catch(e){
      throw Exception('Lỗi: Không thể xóa');
    }
  }

  Future<void> setKhoaChamCong(int? idBangChamCong, DateTime? dateSelected, Set<int>? selectedNhanVienIds ) async {
    if (idBangChamCong == null || dateSelected == null) {
      throw Exception('Thông tin chốt công không hợp lệ');
    }
    final DateTime normalizedDate = DateTime(dateSelected.year, dateSelected.month, dateSelected.day);
    final String dateSelectedStr = normalizedDate.toIso8601String();
    final db = await _dbHelper.database;
    final phienChotCong = await db.query(
        PhienChotCongTable.tableName,
        columns: [PhienChotCongTable.id],
        where: '${PhienChotCongTable.idChamCong} = ? AND ${PhienChotCongTable.denNgay} = ?',
        whereArgs: [idBangChamCong, dateSelectedStr]
    );
    if (phienChotCong.isNotEmpty) {
      throw Exception('Đã tồn tại phiên chốt công cho ngày này');
    }
    try {
      await db.transaction((txn) async {
        final dotChotList = await txn.query(
            PhienChotCongTable.tableName,
            columns: [PhienChotCongTable.id],
            where: '${PhienChotCongTable.idChamCong} = ?',
            whereArgs: [idBangChamCong]
        );
        int dotChotIndex = dotChotList.length + 1;
        final phienChot = PhienChotCong(
          idChamCong: idBangChamCong,
          maDot: dotChotIndex.toString(),
          denNgay: dateSelectedStr,
        );
        final idPhienChot = await txn.insert(
            PhienChotCongTable.tableName,
            phienChot.toMapInsert()
        );

        if (selectedNhanVienIds != null && selectedNhanVienIds.isNotEmpty) {
          final batch = txn.batch();
          for (final idNV in selectedNhanVienIds) {
            batch.update(
                ChamCongChiTietTable.tableName,
                {
                  ChamCongChiTietTable.idPhienChot: idPhienChot
                },
                where: '${ChamCongChiTietTable
                    .idChamCong} = ? AND ${ChamCongChiTietTable
                    .idNhanVienCongTrinh} = ? '
                    'AND date(${ChamCongChiTietTable
                    .ngay}) <= date(?) AND ${ChamCongChiTietTable.idPhienChot} IS NULL',
                whereArgs: [idBangChamCong, idNV, dateSelectedStr]
            );
          }
          await batch.commit(noResult: true);
        }
      });
    }catch(e){
      throw Exception(e);
    }
  }
}