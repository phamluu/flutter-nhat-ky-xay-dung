import '../core/utils/trang_thai_cham_cong.dart';
import '../data/db_helper.dart';
import '../viewmodel/ChamCongModel.dart';

class ChamCongService {
  final _dbHelper = DBHelper.instance;
  double _tinhCong(int? sang, int? chieu)
  {
    double cong = 0;
    if (TrangThaiChamCong.fromValue(sang) == TrangThaiChamCong.coMat) {
      cong += 0.5;
    }
    if (TrangThaiChamCong.fromValue(chieu) == TrangThaiChamCong.coMat) {
      cong += 0.5;
    }
    return cong;
  }
  Future<List<Map<String, dynamic>>> getChamCongThang(
      int idCongTrinh, int thang, int nam) async
  {
        final db = await _dbHelper.database;
        final firstDay = "$nam-${thang.toString().padLeft(2, '0')}-01";
        final lastDay = "$nam-${thang.toString().padLeft(2, '0')}-31";
        final result = await db.rawQuery('''
        SELECT 
          nvct.id as id_nvct,
          nv.ho_ten,
          nvct.vaiTro,
          cc.ngay,
          cc.trang_thai_sang,
          cc.trang_thai_chieu
        FROM nhan_vien_cong_trinh nvct
        JOIN nhan_vien nv ON nv.id = nvct.idNhanVien
        LEFT JOIN cham_cong cc 
          ON cc.id_nhan_vien_cong_trinh = nvct.id
          AND cc.ngay BETWEEN ? AND ?
        WHERE nvct.idCongTrinh = ?
        ORDER BY nv.ho_ten
      ''', [firstDay, lastDay, idCongTrinh]);
        return result;
  }

  Future<List<ChamCongModel>> loadChamCong(
      int idCongTrinh, int thang, int nam) async {

    final raw = await getChamCongThang(idCongTrinh, thang, nam);

    Map<int, ChamCongModel> map = {};
    Map<int, double> tongCongMap = {}; // 👈 lưu tổng công

    for (var row in raw) {
      final id = row['id_nvct'];

      if (!map.containsKey(id)) {
        map[id] = ChamCongModel(
          ten: row['ho_ten'],
          chucVu: row['vaiTro'],
          data: {},
          tongSoCong: 0,
          daUng: 0,
          trangThai: 0
        );
        tongCongMap[id] = 0;
      }

      if (row['ngay'] != null) {
        final sang = TrangThaiChamCong.fromValue(
            row['trang_thai_sang'] as int?);
        final chieu = TrangThaiChamCong.fromValue(
            row['trang_thai_chieu'] as int?);
        final ccNgay = ChamCongNgay(
          sang: sang,
          chieu: chieu,
        );
        // lưu data
        map[id]!.data[row['ngay']] = ccNgay;

        // 👇 tính công
        tongCongMap[id] = (tongCongMap[id] ?? 0) + ccNgay.soCong;
      }
    }

    // 👇 gán lại tongSoCong
    return map.entries.map((entry) {
      final model = entry.value;

      return ChamCongModel(
        ten: model.ten,
        chucVu: model.chucVu,
        data: model.data,
        tongSoCong: tongCongMap[entry.key] ?? 0,
        daUng: 0,
        trangThai: 0
      );
    }).toList();
  }
}
