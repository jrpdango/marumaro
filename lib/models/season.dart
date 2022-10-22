class Season {
  final String? name;
  final int? year;

  Season({
    this.name,
    this.year,
  });

  @override
  String toString() {
    switch (name) {
      case 'winter':
        return 'Winter $year';
      case 'spring':
        return 'Spring $year';
      case 'summer':
        return 'Summer $year';
      case 'fall':
        return 'Fall $year';
      default:
        return 'Not Yet Aired';
    }
  }
}
