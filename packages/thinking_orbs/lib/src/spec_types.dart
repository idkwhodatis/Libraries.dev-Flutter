class OrbPresetSpec {
  const OrbPresetSpec({
    required this.speed,
    required this.count,
    required this.size,
    this.extra = const <String, double>{},
  });

  final double speed;
  final double count;
  final double size;
  final Map<String, double> extra;
}
