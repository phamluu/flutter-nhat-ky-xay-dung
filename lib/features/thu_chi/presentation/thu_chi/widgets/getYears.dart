List<int> getYears() {
  final currentYear = DateTime.now().year;

  return List.generate(
    21,
        (index) => currentYear - 10 + index,
  );
}