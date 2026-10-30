import 'dart:math' as math;

import '../core.dart';
import '../profiles.dart';
import '../spec.g.dart';
import '../types.dart';

typedef MorphPath = Vec2 Function(double f);

double _smoothE(double x) => x * x * (3 - 2 * x);

MorphPath _polyPath(List<Vec2> verts) {
  final v = verts.length;
  final lengths = <double>[];
  var total = 0.0;
  for (var i = 0; i < v; i++) {
    final a = verts[i];
    final b = verts[(i + 1) % v];
    final l = math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2));
    lengths.add(l);
    total += l;
  }
  return (f) {
    var target = f * total;
    var i = 0;
    while (target > lengths[i] && i < v - 1) {
      target -= lengths[i];
      i++;
    }
    final a = verts[i];
    final b = verts[(i + 1) % v];
    final ff = lengths[i] != 0 ? math.min(1.0, target / lengths[i]) : 0.0;
    return (
      x: a.x + (b.x - a.x) * ff,
      y: a.y + (b.y - a.y) * ff,
    );
  };
}

Vec2 _circle(double f) {
  final a = -math.pi / 2 + f * 2 * math.pi;
  return (x: math.cos(a) * 0.24, y: math.sin(a) * 0.24);
}

final MorphPath _triangle = _polyPath([
  (x: 0.0, y: -0.26),
  (x: 0.24, y: 0.16),
  (x: -0.24, y: 0.16),
]);

final MorphPath _square = _polyPath([
  (x: 0.0, y: -0.2),
  (x: 0.2, y: -0.2),
  (x: 0.2, y: 0.2),
  (x: -0.2, y: 0.2),
  (x: -0.2, y: -0.2),
]);

final List<MorphPath> _cycle = [_circle, _triangle, _square];

int _morphN(double d) => math.max(6, (34 * d).round());

const double _seg = kMorphHold + kMorphMorph;

OrbFrame frameMorph(double size, double t, ModeOpts o) {
  const k = 3;
  final tc = t % (_seg * k);
  final shape = o['shape'];
  final held = shape != null && shape >= 0 && shape < k ? shape.floor() : -1;
  final ki = held >= 0 ? held : (tc / _seg).floor();
  final local = held >= 0 ? t % _seg : tc - ki * _seg;
  final m = held >= 0
      ? 0.0
      : local > kMorphHold
          ? _smoothE((local - kMorphHold) / kMorphMorph)
          : 0.0;
  final sprd = opt(o, 'spread', 1);

  final pA = _cycle[ki];
  final pB = held >= 0 ? pA : _cycle[(ki + 1) % k];
  const mCount = 160;
  final pts = <Vec2>[];
  for (var i = 0; i < mCount; i++) {
    final f = i / mCount;
    final a = pA(f);
    final b = pB(f);
    pts.add((
      x: (a.x + (b.x - a.x) * m) * sprd,
      y: (a.y + (b.y - a.y) * m) * sprd,
    ));
  }
  final lengths = <double>[];
  var total = 0.0;
  for (var i = 0; i < mCount; i++) {
    final a = pts[i];
    final b = pts[(i + 1) % mCount];
    final l = math.sqrt(math.pow(b.x - a.x, 2) + math.pow(b.y - a.y, 2));
    lengths.add(l);
    total += l;
  }

  final n = _morphN(opt(o, 'iconD', 1));
  final re = opt(o, 'rDot', 0.021) * 1.35 * sprd;
  final pulse = 1 + 0.02 * math.sin(local * 3.1);

  final dots = <Dot>[];
  final c2 = size / 2;
  var seg = 0;
  var acc = 0.0;
  for (var k2 = 0; k2 < n; k2++) {
    final target = (k2 / n) * total;
    while (acc + lengths[seg] < target && seg < mCount - 1) {
      acc += lengths[seg];
      seg++;
    }
    final a = pts[seg];
    final b = pts[(seg + 1) % mCount];
    final f = lengths[seg] != 0
        ? math.min(1.0, (target - acc) / lengths[seg])
        : 0.0;
    final x = (a.x + (b.x - a.x) * f) * pulse;
    final y = (a.y + (b.y - a.y) * f) * pulse;
    dots.add(Dot(
      x: c2 + x * size,
      y: c2 + y * size,
      z: 0,
      r: math.max(0.35, re * size),
      white: 0.1,
    ));
  }
  return finalizeFrame(dots, const [], o['rMin']);
}
