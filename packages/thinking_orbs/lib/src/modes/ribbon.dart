import 'dart:math' as math;

import '../core.dart';
import '../profiles.dart';
import '../types.dart';

OrbFrame frameRibbon(double size, double t, ModeOpts o) {
  final cx = size / 2;
  final cy = size / 2;
  final r = (size / 2) * 0.78;
  final spin = opt(o, 'spin', 1);
  const camTilt = 0.3;
  final pt = makeProj(t * 0.1 * spin, camTilt, cx, cy, 1);
  final rs = radiusScale(size, opt(o, 'rsPow', 0.6));

  final dots = <Dot>[];
  final ghostN = optInt(o, 'ghostN', 150);
  for (var i = 0; i < ghostN; i++) {
    final d = fibDir(i, ghostN);
    final p = pt.project(d.x * r, d.y * r, d.z * r);
    final depth = (p.z / r + 1) / 2;
    dots.add(Dot(
      x: p.x,
      y: p.y,
      z: p.z,
      r: 0.8 * rs,
      white: 0.78,
      a: 0.1 + 0.22 * depth,
    ));
  }

  final ya = t * 0.24 * spin;
  final faceOn = opt(o, 'faceOn', 0) != 0;
  final ta = faceOn ? -camTilt : 0.55 + 0.3 * math.sin(t * 0.18) * spin;
  final ux = math.cos(ya);
  const uy = 0.0;
  final uz = math.sin(ya);
  final vx = -uz * math.sin(ta);
  final vy = math.cos(ta);
  final vz = ux * math.sin(ta);
  final nx = uy * vz - uz * vy;
  final ny = uz * vx - ux * vz;
  final nz = ux * vy - uy * vx;

  final wobAmp = 0.23 * opt(o, 'wobMul', 1);
  final baseR = faceOn ? r / (1 + 0.85 * wobAmp) : r;

  final baseLanes = optInt(o, 'lanes', 5);
  final segs = optInt(o, 'segs', 88);
  final lanes = math.max(1, (baseLanes * opt(o, 'bandMul', 1)).round());
  for (var w = 0; w < lanes; w++) {
    final laneOff = (w - (lanes - 1) / 2) * 0.075;
    final edge =
        (w - (lanes - 1) / 2).abs() / math.max(1, (lanes - 1) / 2);
    for (var k = 0; k < segs; k++) {
      final a = (k / segs) * 2 * math.pi;
      final wob = (0.16 * math.sin(a * 3 - t * 1.7 + w * 0.22) +
              0.07 * math.sin(a * 5 + t * 1.1)) *
          opt(o, 'wobMul', 1);
      final radial = faceOn ? 1 + wob : 1;
      final off = faceOn ? laneOff : laneOff + wob;
      final x = ux * math.cos(a) + vx * math.sin(a) + nx * off;
      final y = uy * math.cos(a) + vy * math.sin(a) + ny * off;
      final z = uz * math.cos(a) + vz * math.sin(a) + nz * off;
      final l = math.sqrt(x * x + y * y + z * z);
      final rr = baseR * radial;
      final p = pt.project((x / l) * rr, (y / l) * rr, (z / l) * rr);
      final depth = (p.z / r + 1) / 2;
      dots.add(Dot(
        x: p.x,
        y: p.y,
        z: p.z,
        r: (opt(o, 'rBase', 1.1) + opt(o, 'rDepth', 1.7) * depth) *
            (1 - 0.25 * edge) *
            rs,
        white: 0.52 - 0.44 * depth + 0.18 * edge,
        a: 0.4 + 0.6 * depth,
      ));
    }
  }
  return finalizeFrame(dots, const [], o['rMin']);
}
