import 'dart:math' as math;

import '../core.dart';
import '../profiles.dart';
import '../types.dart';

OrbFrame frameWeb(double size, double t, ModeOpts o) {
  final cx = size / 2;
  final cy = size / 2;
  final r = (size / 2) * 0.8 * opt(o, 'spread', 1);
  final pt = makeProj(t * 0.12, 0.32, cx, cy, r);
  final rs = radiusScale(size, opt(o, 'rsPow', 0.6));

  final nodeN = optInt(o, 'nodeN', 30);
  final thr = opt(o, 'thr', 0.72);
  final nodeR = opt(o, 'nodeR', 1.4);
  final nodeRDepth = opt(o, 'nodeRDepth', 1.8);

  final nodes = <Vec3>[];
  for (var i = 0; i < nodeN; i++) {
    final d = fibDir(i, nodeN);
    final x = d.x + 0.3 * (vnoise(i * 0.31 + 9, t * 0.24) - 0.5) * 2;
    final y = d.y + 0.3 * (vnoise(i * 0.53 + 27, t * 0.21) - 0.5) * 2;
    final z = d.z + 0.3 * (vnoise(i * 0.77 + 55, t * 0.27) - 0.5) * 2;
    final l = math.sqrt(x * x + y * y + z * z);
    nodes.add((x: x / l, y: y / l, z: z / l));
  }

  final lines = <Line>[];
  final dots = <Dot>[];

  for (var i = 0; i < nodeN; i++) {
    for (var j = i + 1; j < nodeN; j++) {
      final dx = nodes[i].x - nodes[j].x;
      final dy = nodes[i].y - nodes[j].y;
      final dz = nodes[i].z - nodes[j].z;
      final dist = math.sqrt(dx * dx + dy * dy + dz * dz);
      if (dist >= thr) continue;
      final p1 = pt.project(nodes[i].x, nodes[i].y, nodes[i].z);
      final x1 = p1.x;
      final y1 = p1.y;
      final z1 = p1.z;
      final p2 = pt.project(nodes[j].x, nodes[j].y, nodes[j].z);
      final x2 = p2.x;
      final y2 = p2.y;
      final z2 = p2.z;
      final depth = ((z1 + z2) / 2 + 1) / 2;
      lines.add(Line(
        x1: x1,
        y1: y1,
        x2: x2,
        y2: y2,
        white: 0.42,
        a: (1 - dist / thr) * (0.3 + 0.55 * depth),
        w: math.max(0.6, opt(o, 'lineW', 0.8) * rs),
      ));
    }
  }

  for (var i = 0; i < nodeN; i++) {
    final p = pt.project(nodes[i].x, nodes[i].y, nodes[i].z);
    final depth = (p.z + 1) / 2;
    final pulse = 1 + 0.25 * math.sin(t * 1.4 + i * 2.7);
    dots.add(Dot(
      x: p.x,
      y: p.y,
      z: p.z,
      r: (nodeR + nodeRDepth * depth) * pulse * rs,
      white: 0.55 - 0.45 * depth,
    ));
  }

  final signals = optInt(o, 'signals', 5);
  for (var s = 0; s < signals; s++) {
    final seg = (t * 0.55 + s * 7.31).floor();
    final a = (hashD(seg.toDouble(), s * 3.1 + 1.7) * nodeN).floor();
    final b = (hashD(seg.toDouble(), s * 5.7 + 4.2) * nodeN).floor();
    if (a == b) continue;
    if (a < 0 || a >= nodeN || b < 0 || b >= nodeN) continue;
    final f = frac(t * 0.55 + s * 7.31);
    final x = lerp(nodes[a].x, nodes[b].x, f);
    final y = lerp(nodes[a].y, nodes[b].y, f);
    final z = lerp(nodes[a].z, nodes[b].z, f);
    final l = math.max(1e-6, math.sqrt(x * x + y * y + z * z));
    final p = pt.project(x / l, y / l, z / l);
    final depth = (p.z + 1) / 2;
    dots.add(Dot(
      x: p.x,
      y: p.y,
      z: p.z,
      r: (nodeR * 1.5 + nodeRDepth * depth) * rs,
      white: 0.05,
      a: 0.5 + 0.5 * depth,
    ));
  }

  return finalizeFrame(dots, lines, o['rMin']);
}
