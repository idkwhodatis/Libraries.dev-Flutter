import 'dart:math' as math;

import '../core.dart';
import '../profiles.dart';
import '../types.dart';
import 'rubik_grid.g.dart';

class _Move {
  const _Move(this.axis, this.lo, this.hi, this.ang);

  final int axis;
  final double lo;
  final double hi;
  final double ang;
}

class _SolveCycle {
  const _SolveCycle(this.amount, this.active);

  final List<double> amount;
  final int active;
}

_SolveCycle _solveCycle(double time, int count, double slotDur, double rest) {
  final cyc = 2 * count * slotDur + rest;
  final tc = time % cyc;
  final amount = List<double>.filled(count, 0);
  var active = -1;
  if (tc < 2 * count * slotDur) {
    final slot = (tc / slotDur).floor();
    final p = (tc - slot * slotDur) / slotDur;
    final cl = math.min(1.0, p / 0.7);
    final ep = (1 - math.pow(1 - cl, 3)).toDouble();
    if (slot < count) {
      for (var i = 0; i < slot; i++) {
        amount[i] = 1;
      }
      amount[slot] = ep;
      active = slot;
    } else {
      final u = 2 * count - 1 - slot;
      for (var i = 0; i < u; i++) {
        amount[i] = 1;
      }
      amount[u] = (1 - ep).toDouble();
      active = u;
    }
  }
  return _SolveCycle(amount, active);
}

(Vec3, bool) _applyMoves(Vec3 pt, List<_Move> moves, _SolveCycle sc) {
  var x = pt.x;
  var y = pt.y;
  var z = pt.z;
  var inActive = false;
  for (var i = 0; i < moves.length; i++) {
    if (sc.amount[i] <= 0) continue;
    final mv = moves[i];
    final coord = mv.axis == 0 ? x : (mv.axis == 1 ? y : z);
    if (coord < mv.lo || coord >= mv.hi) continue;
    if (i == sc.active) inActive = true;
    final a = mv.ang * sc.amount[i];
    final ca = math.cos(a);
    final sa = math.sin(a);
    if (mv.axis == 0) {
      final y2 = y * ca - z * sa;
      z = y * sa + z * ca;
      y = y2;
    } else if (mv.axis == 1) {
      final x2 = x * ca + z * sa;
      z = -x * sa + z * ca;
      x = x2;
    } else {
      final x2 = x * ca - y * sa;
      y = x * sa + y * ca;
      x = x2;
    }
  }
  return ((x: x, y: y, z: z), inActive);
}

List<_Move> _makeMoves(int count) {
  final moves = <_Move>[];
  for (var i = 0; i < count; i++) {
    final axis = math.min(2, (hashD(i.toDouble(), 2.3) * 3).floor());
    final lo = -1.0 + 0.5 * math.min(3, (hashD(i.toDouble(), 5.9) * 4).floor());
    final dir = hashD(i.toDouble(), 7.7) < 0.5 ? 1 : -1;
    moves.add(_Move(axis, lo, lo + 0.5, (dir * math.pi) / 2));
  }
  return moves;
}

OrbFrame frameGlobe(double size, double t, ModeOpts o) {
  const spin = 0.5;
  final cx = size / 2;
  final cy = size / 2;
  final radius = (size / 2) * 0.82;
  final tilt = 0.4 + 0.06 * math.sin(t * 0.35);
  final pt = makeProj(t * spin, tilt, cx, cy, radius);
  final scan = t * (spin + (1.7 - spin) * opt(o, 'scanMul', 1));
  final rs = radiusScale(size, opt(o, 'rsPow', 0.6));
  final dimBase = opt(o, 'dimBase', 1);

  final dots = <Dot>[];
  final latRings = optInt(o, 'latRings', 17);
  final lonDensity = optInt(o, 'lonDensity', 44);
  for (var li = 0; li <= latRings; li++) {
    final lat = -math.pi / 2 + (li / latRings) * math.pi;
    final cosLat = math.cos(lat);
    final sinLat = math.sin(lat);
    final lonCount = math.max(1, (cosLat.abs() * lonDensity).round());
    for (var lj = 0; lj < lonCount; lj++) {
      final lon = (lj / lonCount) * 2 * math.pi;
      final p = pt.project(cosLat * math.cos(lon), sinLat, cosLat * math.sin(lon));
      final depth = (p.z + 1) / 2;
      final d = angleDelta(lon + t * spin, scan);
      final boost = math.exp(-(d * d) / 0.18) * math.max(0.0, p.z);
      dots.add(Dot(
        x: p.x,
        y: p.y,
        z: p.z,
        r: (opt(o, 'rBase', 0.6) +
                opt(o, 'rDepth', 1.7) * depth +
                opt(o, 'rBoost', 1) * boost) *
            rs,
        white: opt(o, 'inkFar', 0.62) - opt(o, 'inkSpan', 0.54) * depth,
        a: dimBase + (1 - dimBase) * math.min(1.0, boost),
      ));
    }
  }
  return finalizeFrame(dots, const [], o['rMin']);
}

OrbFrame frameRubik(double size, double t, ModeOpts o) {
  final cx = size / 2;
  final cy = size / 2;
  final r = (size / 2) * 0.82;
  final pt = makeProj(t * 0.55, 0.35 + 0.1 * math.sin(t * 0.9), cx, cy, r);
  final rs = radiusScale(size, opt(o, 'rsPow', 0.6));
  final moveCount = optInt(o, 'moveCount', 14);
  final moves = _makeMoves(moveCount);
  final sc = _solveCycle(t, moveCount, 0.42, 1.2);

  final dots = <Dot>[];
  final latRings = optInt(o, 'latRings', 15);
  final lonDensity = optInt(o, 'lonDensity', 40);
  final points = _rubikBasePoints(latRings, lonDensity);
  for (final point in points) {
    final moved = _applyMoves(point, moves, sc);
    final p = pt.project(moved.$1.x, moved.$1.y, moved.$1.z);
    final depth = (p.z + 1) / 2;
    dots.add(Dot(
      x: p.x,
      y: p.y,
      z: p.z,
      r: (opt(o, 'rBase', 0.6) +
              opt(o, 'rDepth', 1.7) * depth +
              (moved.$2 ? opt(o, 'rActive', 0.3) : 0)) *
          rs,
      white: opt(o, 'inkFar', 0.62) -
          opt(o, 'inkSpan', 0.54) * depth -
          (moved.$2 ? 0.14 : 0),
    ));
  }
  return finalizeFrame(dots, const [], o['rMin']);
}

List<Vec3> _rubikBasePoints(int latRings, int lonDensity) {
  final generated = kRubikGrids['${latRings}x$lonDensity'];
  if (generated != null) {
    return [
      for (final point in generated) (x: point[0], y: point[1], z: point[2]),
    ];
  }
  final points = <Vec3>[];
  for (var li = 0; li <= latRings; li++) {
    final lat = -math.pi / 2 + (li / latRings) * math.pi;
    final cosLat = math.cos(lat);
    final sinLat = math.sin(lat);
    final lonCount = math.max(1, (cosLat.abs() * lonDensity).round());
    for (var lj = 0; lj < lonCount; lj++) {
      final lon = (lj / lonCount) * 2 * math.pi;
      points.add((
        x: cosLat * math.cos(lon),
        y: sinLat,
        z: cosLat * math.sin(lon),
      ));
    }
  }
  return points;
}

OrbFrame frameWave(double size, double t, ModeOpts o) {
  final cx = size / 2;
  final cy = size / 2;
  final r = (size / 2) * 0.874;
  final pt = makeProj(t * 0.18, 0.38, cx, cy, 1);
  final rs = radiusScale(size, opt(o, 'rsPow', 0.6));

  final dots = <Dot>[];
  final rings = optInt(o, 'rings', 15);
  final lonDensity = optInt(o, 'lonDensity', 40);
  for (var ri = 0; ri <= rings; ri++) {
    final lat = -math.pi / 2 + (ri / rings) * math.pi;
    final cosLat = math.cos(lat);
    final sinLat = math.sin(lat);
    final w = 0.62 * math.sin(t * 2.1 - ri * 0.52) +
        0.38 * math.sin(t * 1.27 + ri * 0.83);
    final rr = r * (0.88 + 0.105 * w);
    final lonCount = math.max(1, (cosLat.abs() * lonDensity).round());
    for (var lj = 0; lj < lonCount; lj++) {
      final lon = (lj / lonCount) * 2 * math.pi;
      final p = pt.project(
        cosLat * math.cos(lon) * rr,
        sinLat * rr,
        cosLat * math.sin(lon) * rr,
      );
      final depth = (p.z / r + 1) / 2;
      final crest = math.max(0.0, w);
      dots.add(Dot(
        x: p.x,
        y: p.y,
        z: p.z,
        r: (opt(o, 'rBase', 0.6) + opt(o, 'rDepth', 1.7) * depth) *
            (1 + 0.4 * crest) *
            rs,
        white: 0.66 - 0.56 * depth - 0.1 * crest,
      ));
    }
  }
  return finalizeFrame(dots, const [], o['rMin']);
}


