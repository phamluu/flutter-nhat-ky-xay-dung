String formatDate(String? value) {
  if (value == null || value.isEmpty) {
    return '--';
  }

  final date = DateTime.tryParse(value);

  if (date == null) {
    return value;
  }

  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}