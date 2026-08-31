import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showErrorToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showSuccessToast.dart';
import 'package:nhat_ky_xay_dung/core/widgets/showWarmToast.dart';

import 'package:nhat_ky_xay_dung/features/nhan_vien/data/services/nhan_vien_service.dart';

import '../../../../../core/utils/date_utils.dart';
import '../../../../nhan_vien/data/models/NhanVien.dart';
import '../../../data/models/CongTrinh.dart';
import '../../../data/models/NhanVienCongTrinh.dart';
import '../../../data/respositories/CongTrinhReponsitory.dart';
import '../../../data/services/nhan_vien_cong_trinh_service.dart';


class NhanhVienCongTrinhFormDesktop extends StatefulWidget {
  final NhanVienCongTrinh? item;
  final int? idCongTrinh;

  const NhanhVienCongTrinhFormDesktop({
    super.key,
    this.item,
    this.idCongTrinh,
  });

  @override
  State<NhanhVienCongTrinhFormDesktop> createState() =>
      _NhanhVienCongTrinhFormDesktopState();
}

class _NhanhVienCongTrinhFormDesktopState
    extends State<NhanhVienCongTrinhFormDesktop> {
  final _formKey = GlobalKey<FormState>();

  final _vaiTroController = TextEditingController();
  final _ngayBatDauController = TextEditingController();
  final _ngayKetThucController = TextEditingController();

  final _service = NhanVienCongTrinhService();

  final _nhanvienservice = NhanVienService();

  final _congtrinhservice = CongtrinhReponsitory();

  List<NhanVien> _nhanViens = [];
  List<CongTrinh> _conTrinhs = [];

  int? _selectedNhanVienId;
  int? _selectedCongTrinhId;

  bool _loading = true;
  bool _saving = false;

  bool get isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();

    _loadDropdownData();
  }

  @override
  void dispose() {
    _vaiTroController.dispose();
    _ngayBatDauController.dispose();
    _ngayKetThucController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadDropdownData() async {
    try {
      final nvs =
      await _nhanvienservice.getAllNhanVien();

      final cts =
      await _congtrinhservice.getDanhSachCongTrinh();

      if (!mounted) return;

      setState(() {
        _nhanViens = nvs;
        _conTrinhs = cts;

        if (widget.item != null) {
          _selectedNhanVienId =
              widget.item!.idNhanVien;

          _selectedCongTrinhId =
              widget.item!.idCongTrinh;

          _vaiTroController.text =
              widget.item!.vaiTro ?? '';

          _ngayBatDauController.text =
              widget.item!.ngayBatDau ?? '';

          _ngayKetThucController.text =
              widget.item!.ngayKetThuc ?? '';
        } else {
          _selectedCongTrinhId =
              widget.idCongTrinh;

          if (_nhanViens.isNotEmpty) {
            _selectedNhanVienId =
                _nhanViens.first.id;
          }
        }

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
showErrorToast(context, e, "Không thể tải dữ liệu: ");

    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedNhanVienId == null) {
showWarmToast(context, message: "Vui lòng chọn nhân viên");

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final obj = NhanVienCongTrinh(
        id: widget.item?.id,
        idNhanVien: _selectedNhanVienId!,
        idCongTrinh: _selectedCongTrinhId,
        vaiTro: _vaiTroController.text.trim().isEmpty
            ? null
            : _vaiTroController.text.trim(),
        ngayBatDau:
        _ngayBatDauController.text.trim().isEmpty
            ? null
            : _ngayBatDauController.text.trim(),
        ngayKetThuc:
        _ngayKetThucController.text.trim().isEmpty
            ? null
            : _ngayKetThucController.text.trim(),
      );

      if (isEdit) {
        await _service.update(obj);
      } else {
        await _service.insert(obj);
      }

      if (!mounted) return;
showSuccessToast(context,  isEdit
    ? "Đã cập nhật nhân viên"
    : "Đã thêm nhân viên vào công trình");

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
      });
showErrorToast(context, e,  "Không thể thêm nhân viên công trình: ");

    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xfff5f6f8),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),

            const SizedBox(height: 20),

            Expanded(
              child: _loading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius:
            BorderRadius.circular(10),
          ),
          child: Icon(
            isEdit
                ? Icons.edit_outlined
                : Icons.person_add_alt_1_outlined,
            color: Colors.blue.shade700,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                isEdit
                    ? "Sửa nhân viên công trình"
                    : "Thêm nhân viên công trình",
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff263238),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                isEdit
                    ? "Cập nhật thông tin phân công nhân viên"
                    : "Phân công nhân viên vào công trình",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        OutlinedButton.icon(
          onPressed: _saving
              ? null
              : () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            size: 18,
          ),
          label: const Text("Quay lại"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(8),
            ),
          ),
        ),

        const SizedBox(width: 10),

        ElevatedButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Icon(
            Icons.save_outlined,
            size: 18,
          ),
          label: Text(
            _saving ? "Đang lưu..." : "Lưu",
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 13,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_nhanViens.isEmpty) {
      return _buildNoEmployee();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1000,
        ),
        child: SingleChildScrollView(
          child: _buildFormCard(),
        ),
      ),
    );
  }

  // ============================================================
  // FORM CARD
  // ============================================================

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.stretch,
          children: [
            _sectionTitle(
              icon: Icons.assignment_ind_outlined,
              title: "Thông tin phân công",
              subtitle:
              "Chọn nhân viên và công trình cần phân công",
            ),

            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 650) {
                  return Column(
                    children: [
                      _buildNhanVienDropdown(),

                      const SizedBox(height: 18),

                      _buildCongTrinhDropdown(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                      _buildNhanVienDropdown(),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child:
                      _buildCongTrinhDropdown(),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            const Divider(),

            const SizedBox(height: 24),

            _sectionTitle(
              icon: Icons.work_outline,
              title: "Thông tin công việc",
              subtitle:
              "Vai trò và thời gian làm việc tại công trình",
            ),

            const SizedBox(height: 24),

            _buildVaiTro(),

            const SizedBox(height: 18),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 650) {
                  return Column(
                    children: [
                      _buildNgayBatDau(),

                      const SizedBox(height: 18),

                      _buildNgayKetThuc(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child:
                      _buildNgayBatDau(),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child:
                      _buildNgayKetThuc(),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Hủy",
                  ),
                ),

                const SizedBox(width: 10),

                ElevatedButton.icon(
                  onPressed:
                  _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                    width: 17,
                    height: 17,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.save_outlined,
                    size: 18,
                  ),
                  label: Text(
                    _saving
                        ? "Đang lưu..."
                        : "Lưu thông tin",
                  ),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.blue,
                    foregroundColor:
                    Colors.white,
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FIELDS
  // ============================================================

  Widget _buildNhanVienDropdown() {
    return DropdownSearch<int>(
      // Giá trị đang được chọn
      selectedItem: _selectedNhanVienId,
      enabled: !_saving,

      // Lọc tìm kiếm (hỗ trợ tìm kiếm không phân biệt hoa/thường)
      items: _nhanViens
          .where((nv) => nv.id != null)
          .map((nv) => nv.id!)
          .toList(),

      // Chuyển đổi ID sang Tên nhân viên để hiển thị trên Dropdown
      itemAsString: (int? id) {
        final nv = _nhanViens.firstWhere(
              (element) => element.id == id,
          orElse: () => NhanVien(hoTen: 'Không tên'),
        );
        return nv.hoTen ?? 'Không tên';
      },

      // Cấu hình ô nhập tìm kiếm và popup
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Nhập tên nhân viên cần tìm...",
            prefixIcon: const Icon(Icons.search),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // Giữ giao diện InputDecoration giống như cũ
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: _inputDecoration(
          label: "Nhân viên",
          hint: "Chọn nhân viên",
          icon: Icons.person_outline,
        ),
      ),

      // Xử lý sự kiện khi chọn
      onChanged: (value) {
        setState(() {
          _selectedNhanVienId = value;
        });
      },

      // Validation form
      validator: (value) {
        if (value == null) {
          return "Vui lòng chọn nhân viên";
        }
        return null;
      },
    );
  }

  Widget _buildCongTrinhDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCongTrinhId,
      isExpanded: true,
      decoration: _inputDecoration(
        label: "Công trình",
        hint: "Chọn công trình",
        icon: Icons.business_outlined,
      ),
      items: _conTrinhs.map((ct) {
        return DropdownMenuItem<int>(
          value: ct.id,
          child: Text(
            ct.ten ?? "Không tên",
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged:
      widget.idCongTrinh != null ||
          _saving
          ? null
          : (value) {
        setState(() {
          _selectedCongTrinhId =
              value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Vui lòng chọn công trình";
        }

        return null;
      },
    );
  }

  Widget _buildVaiTro() {
    return TextFormField(
      controller: _vaiTroController,
      enabled: !_saving,
      decoration: _inputDecoration(
        label: "Vai trò",
        hint: "Ví dụ: Kỹ sư, Giám sát, Công nhân...",
        icon: Icons.badge_outlined,
      ),
    );
  }

  Widget _buildNgayBatDau() {
    return TextFormField(
      controller: _ngayBatDauController,
      readOnly: true,
      enabled: !_saving,
      onTap: _saving
          ? null
          : () {
        DateUtilsCore.pickDate(
          context,
          _ngayBatDauController,
          format: "dd/MM/yyyy",
        );
      },
      decoration: _inputDecoration(
        label: "Ngày bắt đầu",
        hint: "Chọn ngày bắt đầu",
        icon: Icons.calendar_today_outlined,
      ),
    );
  }

  Widget _buildNgayKetThuc() {
    return TextFormField(
      controller: _ngayKetThucController,
      readOnly: true,
      enabled: !_saving,
      onTap: _saving
          ? null
          : () {
        DateUtilsCore.pickDate(
          context,
          _ngayKetThucController,
          format: "dd/MM/yyyy",
        );
      },
      decoration: _inputDecoration(
        label: "Ngày kết thúc",
        hint: "Chọn ngày kết thúc",
        icon: Icons.event_available_outlined,
      ),
    );
  }

  // ============================================================
  // COMMON UI
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xfffafbfc),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
    );
  }

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
            Colors.blue.withOpacity(0.1),
            borderRadius:
            BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade700,
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff263238),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildNoEmployee() {
    return Center(
      child: Container(
        width: 430,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color:
                Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 34,
                color: Colors.orange.shade600,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Chưa có nhân viên",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              "Vui lòng thêm nhân viên vào hệ thống "
                  "trước khi phân công vào công trình.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
              ),
              label: const Text(
                "Quay lại",
              ),
            ),
          ],
        ),
      ),
    );
  }
}