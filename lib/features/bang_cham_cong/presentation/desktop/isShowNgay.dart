bool isShowNgay(int day, bool _show10Dau, bool _show10Giua, bool _show10Cuoi) {
  if (day <= 10 && !_show10Dau) {
    return false;
  }

  if (day >= 11 &&
      day <= 20 &&
      !_show10Giua) {
    return false;
  }

  if (day >= 21 && !_show10Cuoi) {
    return false;
  }

  return true;
}