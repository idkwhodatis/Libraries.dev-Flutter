import 'dart:math' as math;

import '../core.dart';
import '../profiles.dart';
import '../types.dart';

OrbFrame frameBraid(double size, double t, ModeOpts o) {
  final cx = size / 2;
  final cy = size / 2;
  final r = (size / 2) * 0.76;
  final pt = makeProj(t * 0.4, 0.3, cx, cy, 1);
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

  final strandN = optInt(o, 'strandN', 52);
  final turns = opt(o, 'turns', 3);
  for (var s = 0; s < 3; s++) {
    final phase = (s / 3) * 2 * math.pi;
    for (var i = 0; i < strandN; i++) {
      final u = (frac(i / strandN + t * 0.045) * 2 - 1) * 0.96;
      final surf = math.sqrt(math.max(0.0, 1 - u * u));
      final endFade = math.min(1.0, (1 - u.abs()) / 0.1);
      final a = u * math.pi * turns + phase;
      final weave =
          1 + 0.075 * math.sin(u * math.pi * turns * 2 + phase * 2 + t * 0.8);
      final rr = surf * r * weave;
      final p = pt.project(math.cos(a) * rr, u * r * weave, math.sin(a) * rr);
      final depth = (p.z / r + 1) / 2;
      dots.add(Dot(
        x: p.x,
        y: p.y,
        z: p.z,
        r: (opt(o, 'rBase', 1.2) + opt(o, 'rDepth', 1.8) * depth) * rs,
        white: 0.55 - 0.45 * depth,
        a: endFade * (0.45 + 0.55 * depth),
      ));
    }
  }
  return finalizeFrame(dots, const [], o['rMin']);
}
