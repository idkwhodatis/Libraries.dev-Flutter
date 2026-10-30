import 'dart:convert';

import 'package:flutter/services.dart';

class BeamBlob {
  const BeamBlob({
    required this.rx,
    required this.ry,
    required this.cx,
    required this.cy,
    required this.color,
  });

  final double rx;
  final double ry;
  final double cx;
  final double cy;
  final Color color;

  BeamBlob scaled(double sizeScale, double alphaScale) {
    return BeamBlob(
      rx: (rx * sizeScale).roundToDouble(),
      ry: (ry * sizeScale).roundToDouble(),
      cx: cx,
      cy: cy,
      color: color.withValues(alpha: color.a * alphaScale),
    );
  }
}

class BeamSpec {
  BeamSpec._(this.raw);

  final Map<String, dynamic> raw;

  static BeamSpec? _cached;

  static Future<BeamSpec?> load() async {
    if (_cached != null) return _cached;
    try {
      final text = await rootBundle
          .loadString('packages/border_beam/spec/beam-spec.json');
      _cached = BeamSpec._(jsonDecode(text) as Map<String, dynamic>);
      return _cached;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> get _sizePresets =>
      raw['sizePresets'] as Map<String, dynamic>;

  Map<String, dynamic> get _sizeTheme =>
      raw['sizeThemePresets'] as Map<String, dynamic>;

  Map<String, dynamic> get _palettes =>
      raw['palettes'] as Map<String, dynamic>;

  Map<String, dynamic> get _rotate => raw['rotate'] as Map<String, dynamic>;

  double borderRadius(String size) =>
      ((_sizePresets[size] as Map<String, dynamic>)['borderRadius'] as num)
          .toDouble();

  double borderWidth(String size) =>
      ((_sizePresets[size] as Map<String, dynamic>)['borderWidth'] as num)
          .toDouble();

  double strokeOpacity(String size, String theme) =>
      ((_sizeTheme[size][theme] as Map<String, dynamic>)['strokeOpacity'] as num)
          .toDouble();

  double innerOpacity(String size, String theme) =>
      ((_sizeTheme[size][theme] as Map<String, dynamic>)['innerOpacity'] as num)
          .toDouble();

  double bloomOpacity(String size, String theme) =>
      ((_sizeTheme[size][theme] as Map<String, dynamic>)['bloomOpacity'] as num)
          .toDouble();

  double saturation(String size, String theme) =>
      ((_sizeTheme[size][theme] as Map<String, dynamic>)['saturation'] as num)
          .toDouble();

  List<BeamBlob> borderBlobs(String size, String variant) {
    final palette = size == 'sm'
        ? _palettes['small'][variant] as Map<String, dynamic>
        : _palettes['border'][variant] as Map<String, dynamic>;
    return _blobs(palette['border'] as List<dynamic>);
  }

  List<BeamBlob> innerBlobs(String size, String variant, bool mono) {
    final palette = _palettes[size == 'sm' ? 'small' : 'border'][variant]
        as Map<String, dynamic>;
    if (size == 'sm') {
      return _blobs(palette['inner'] as List<dynamic>);
    }
    final derivation = _rotate['innerGradientDerivation']
        as Map<String, dynamic>;
    final scale = (derivation['sizeScale'] as num).toDouble();
    final alpha = ((mono ? derivation['monoAlpha'] : derivation['alpha'])
            as num)
        .toDouble();
    return _blobs(palette['border'] as List<dynamic>)
        .map((blob) => blob.scaled(scale, alpha))
        .toList(growable: false);
  }

  List<double> whiteStops(String theme) =>
      _flatStops(_rotate['whiteGradientStops'][theme] as List<dynamic>);

  List<double> bloomStops(String theme) =>
      _flatStops(_rotate['bloomGradientStops'][theme] as List<dynamic>);

  List<double> beamMaskStops() =>
      _flatStops(_rotate['beamMaskStops'] as List<dynamic>);

  List<double> smallMaskStops() =>
      _flatStops(_rotate['smallMaskStops'] as List<dynamic>);

  double get innerEdgeMaskPx =>
      (_rotate['innerEdgeMaskPx'] as num).toDouble();

  double innerShadowBlur(String size) =>
      (_rotate['innerShadowBlur'][size] as num).toDouble();

  double get bloomBlurPx => (_rotate['bloomBlurPx'] as num).toDouble();

  double get monoOpacityMultiplier =>
      ((raw['defaults']['monoOpacityMultiplier'] as num).toDouble());

  double get hueShiftPeriod =>
      ((raw['defaults']['rotateHueShiftPeriod'] as num).toDouble());

  double get hueRange =>
      ((raw['defaults']['hueRange'] as num).toDouble());

  List<BeamBlob> _blobs(List<dynamic> source) {
    return [
      for (final item in source)
        _blob(item as Map<String, dynamic>),
    ];
  }

  BeamBlob _blob(Map<String, dynamic> item) {
    final pos = _pair(item['pos'] as String);
    final size = _pair(item['size'] as String);
    return BeamBlob(
      rx: size.$1,
      ry: size.$2,
      cx: pos.$1 / 100,
      cy: pos.$2 / 100,
      color: _color(item['color'] as String),
    );
  }

  (double, double) _pair(String value) {
    final numbers = RegExp(r'-?[\d.]+')
        .allMatches(value)
        .map((m) => double.parse(m.group(0)!))
        .toList(growable: false);
    if (numbers.length < 2) return (0, 0);
    return (numbers[0], numbers[1]);
  }

  Color _color(String value) {
    final match = RegExp(
      r'rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)(?:\s*,\s*([\d.]+))?\s*\)',
    ).firstMatch(value);
    if (match == null) return const Color(0xFFFFFFFF);
    final r = double.parse(match.group(1)!).round();
    final g = double.parse(match.group(2)!).round();
    final b = double.parse(match.group(3)!).round();
    final a = match.group(4) == null
        ? 1.0
        : double.parse(match.group(4)!).clamp(0.0, 1.0);
    return Color.fromARGB((a * 255).round(), r, g, b);
  }

  List<double> _flatStops(List<dynamic> stops) {
    final out = <double>[];
    for (final stop in stops) {
      final pair = stop as List<dynamic>;
      out
        ..add((pair[0] as num).toDouble() / 100)
        ..add((pair[1] as num).toDouble());
    }
    return out;
  }
}

