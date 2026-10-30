import 'dart:math' as math;

import 'types.dart';

double lerp(double a, double b, double f) => a + (b - a) * f;

double frac(double x) => x - x.floorToDouble();

double vnoise(double x, double y) {
  final xi = x.floorToDouble();
  final yi = y.floorToDouble();
  var fx = x - xi;
  var fy = y - yi;
  fx = fx * fx * (3 - 2 * fx);
  fy = fy * fy * (3 - 2 * fy);
  final a = hashD(xi, yi);
  final b = hashD(xi + 1, yi);
  final c = hashD(xi, yi + 1);
  final d = hashD(xi + 1, yi + 1);
  return a + (b - a) * fx + (c - a) * fy + (a - b - c + d) * fx * fy;
}

double hashD(double a, double b) {
  final h = math.sin(a * 12.9898 + b * 78.233) * 43758.5453;
  return h - h.floorToDouble();
}

Vec3 fibDir(int i, int n) {
  final golden = math.pi * (3 - math.sqrt(5));
  final y = 1 - (2 * (i + 0.5)) / n;
  final rad = math.sqrt(1 - y * y);
  final a = i * golden;
  return (x: rad * math.cos(a), y: y, z: rad * math.sin(a));
}

double angleDelta(double a, double b) {
  return math.atan2(math.sin(a - b), math.cos(a - b));
}

class Projected {
  double x = 0;
  double y = 0;
  double z = 0;
}

class Projector {
  Projector({
    required double yaw,
    required double tilt,
    required this.cx,
    required this.cy,
    required this.scale,
  })  : _st = math.sin(tilt),
        _ct = math.cos(tilt),
        _sy = math.sin(yaw),
        _cy = math.cos(yaw);

  final double cx;
  final double cy;
  final double scale;
  final double _st;
  final double _ct;
  final double _sy;
  final double _cy;
  final Projected _out = Projected();

  Projected project(double x, double y, double z) {
    final x1 = x * _cy + z * _sy;
    final z1 = -x * _sy + z * _cy;
    final y1 = y * _ct - z1 * _st;
    final z2 = y * _st + z1 * _ct;
    _out
      ..x = cx + x1 * scale
      ..y = cy - y1 * scale
      ..z = z2;
    return _out;
  }
}

Projector makeProj(double yaw, double tilt, double cx, double cy, double scale) {
  return Projector(yaw: yaw, tilt: tilt, cx: cx, cy: cy, scale: scale);
}

OrbInk inkFor(double white, double alpha, bool dark, [OrbTint? tint]) {
  final w = white.clamp(0.0, 1.0);
  if (tint == null) {
    final g = ((dark ? 1 - w : w) * 255).round();
    return OrbInk(g, g, g, alpha);
  }
  int ramp(int c) => (dark ? c * (1 - w) : c + (255 - c) * w).round();
  return OrbInk(ramp(tint.r), ramp(tint.g), ramp(tint.b), alpha);
}

OrbFrame finalizeFrame(List<Dot> dots, List<Line> lines, [double? rMin]) {
  final floor = rMin ?? 0.3;
  final visible = <Dot>[];
  for (final d in dots) {
    if ((d.a ?? 1) < 0.02) continue;
    d.r = math.max(floor, d.r);
    visible.add(d);
  }
  final ordered = visible.asMap().entries.toList(growable: false)
    ..sort((a, b) {
      final byDepth = a.value.z.compareTo(b.value.z);
      return byDepth != 0 ? byDepth : a.key.compareTo(b.key);
    });
  return OrbFrame(
    ordered.map((entry) => entry.value).toList(growable: false),
    lines.where((l) => (l.a ?? 1) >= 0.02).toList(growable: false),
  );
}

double radiusScale(double size, double power) {
  return math.pow(size / 300, power).toDouble();
}
