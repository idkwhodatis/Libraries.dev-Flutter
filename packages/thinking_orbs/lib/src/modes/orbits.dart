import 'dart:math' as math;

import '../core.dart';
import '../profiles.dart';
import '../types.dart';

OrbFrame frameOrbits(double size, double t, ModeOpts o) {
  final cx = size / 2;
  final cy = size / 2;
  final r = (size / 2) * 0.82;
  final pt = makeProj(t * 0.12, 0.3, cx, cy, 1);
  final rs = radiusScale(size, opt(o, 'rsPow', 0.6));

  final dots = <Dot>[];
  final orbitN = optInt(o, 'orbitN', 12);
  final ghostN = optInt(o, 'ghostN', 40);
  final particles = optInt(o, 'particles', 3);

  for (var orb = 0; orb < orbitN; orb++) {
    final h1 = hashD(orb.toDouble(), 1.7);
    final h2 = hashD(orb.toDouble(), 5.2);
    final h3 = hashD(orb.toDouble(), 8.9);
    final ro = r * (0.45 + 0.52 * h1);
    final th = h1 * 2 * math.pi;
    final phi = math.acos(2 * h2 - 1);
    final nx = math.sin(phi) * math.cos(th);
    final ny = math.cos(phi);
    final nz = math.sin(phi) * math.sin(th);
    var ux = -ny;
    var uy = nx;
    const uz = 0.0;
    final ul = math.max(1e-6, math.sqrt(ux * ux + uy * uy));
    ux /= ul;
    uy /= ul;
    final vx = ny * uz - nz * uy;
    final vy = nz * ux - nx * uz;
    final vz = nx * uy - ny * ux;
    final speed = (0.25 + 0.55 * h3) * (h3 > 0.5 ? 1 : -1);

    for (var k = 0; k < ghostN; k++) {
      final a = (k / ghostN) * 2 * math.pi;
      final p = pt.project(
        (ux * math.cos(a) + vx * math.sin(a)) * ro,
        (uy * math.cos(a) + vy * math.sin(a)) * ro,
        (uz * math.cos(a) + vz * math.sin(a)) * ro,
      );
      final depth = (p.z / ro + 1) / 2;
      dots.add(Dot(
        x: p.x,
        y: p.y,
        z: p.z,
        r: opt(o, 'ghostR', 0.9) * rs,
        white: 0.72,
        a: opt(o, 'ghostA', 0.5) * (0.4 + 0.6 * depth),
      ));
    }

    for (var m = 0; m < particles; m++) {
      final a = t * speed + (m / particles) * 2 * math.pi + h2 * 6;
      final p = pt.project(
        (ux * math.cos(a) + vx * math.sin(a)) * ro,
        (uy * math.cos(a) + vy * math.sin(a)) * ro,
        (uz * math.cos(a) + vz * math.sin(a)) * ro,
      );
      final depth = (p.z / ro + 1) / 2;
      dots.add(Dot(
        x: p.x,
        y: p.y,
        z: p.z,
        r: (opt(o, 'partR', 1.2) + opt(o, 'partRDepth', 1.6) * depth) * rs,
        white: 0.3 - 0.22 * depth,
      ));
    }
  }

  return finalizeFrame(dots, const [], o['rMin']);
}
