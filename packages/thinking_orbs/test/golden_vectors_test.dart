import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:thinking_orbs/thinking_orbs.dart';

File _goldenFile() {
  for (final path in const [
    'packages/thinking_orbs/spec/orbs-golden.json',
    'spec/orbs-golden.json',
  ]) {
    final file = File(path);
    if (file.existsSync()) return file;
  }
  throw StateError('Could not find orbs-golden.json');
}

List<Dot> _dots(List<dynamic> flat) {
  final out = <Dot>[];
  for (var i = 0; i < flat.length; i += 6) {
    out.add(Dot(
      x: (flat[i] as num).toDouble(),
      y: (flat[i + 1] as num).toDouble(),
      z: (flat[i + 2] as num).toDouble(),
      r: (flat[i + 3] as num).toDouble(),
      white: (flat[i + 4] as num).toDouble(),
      a: (flat[i + 5] as num).toDouble(),
    ));
  }
  return out;
}

List<Line> _lines(List<dynamic> flat) {
  final out = <Line>[];
  for (var i = 0; i < flat.length; i += 7) {
    out.add(Line(
      x1: (flat[i] as num).toDouble(),
      y1: (flat[i + 1] as num).toDouble(),
      x2: (flat[i + 2] as num).toDouble(),
      y2: (flat[i + 3] as num).toDouble(),
      white: (flat[i + 4] as num).toDouble(),
      a: (flat[i + 5] as num).toDouble(),
      w: (flat[i + 6] as num).toDouble(),
    ));
  }
  return out;
}

void _close(double actual, double expected, double tolerance, String where) {
  if ((actual - expected).abs() > tolerance) {
    fail('$where: expected $expected, got $actual');
  }
}

void _compareDotMultiset(
  List<Dot> actual,
  List<Dot> expected,
  double tolerance,
  String key,
) {
  expect(actual.length, expected.length, reason: '$key dot count');
  final matched = List<bool>.filled(expected.length, false);
  for (var i = 0; i < actual.length; i++) {
    final a = actual[i];
    var found = -1;
    for (var j = 0; j < expected.length; j++) {
      if (matched[j]) continue;
      final e = expected[j];
      if ((a.x - e.x).abs() <= tolerance &&
          (a.y - e.y).abs() <= tolerance &&
          (a.z - e.z).abs() <= tolerance &&
          (a.r - e.r).abs() <= tolerance &&
          (a.white - e.white).abs() <= tolerance &&
          ((a.a ?? 1) - (e.a ?? 1)).abs() <= tolerance) {
        found = j;
        break;
      }
    }
    if (found < 0) {
      fail('$key dot $i (${a.x}, ${a.y}, ${a.z}) has no matching golden dot');
    }
    matched[found] = true;
  }
}

void _compareLines(
  List<Line> actual,
  List<Line> expected,
  double tolerance,
  String key,
) {
  expect(actual.length, expected.length, reason: '$key line count');
  for (var i = 0; i < actual.length; i++) {
    final a = actual[i];
    final e = expected[i];
    _close(a.x1, e.x1, tolerance, '$key line $i x1');
    _close(a.y1, e.y1, tolerance, '$key line $i y1');
    _close(a.x2, e.x2, tolerance, '$key line $i x2');
    _close(a.y2, e.y2, tolerance, '$key line $i y2');
    _close(a.white, e.white, tolerance, '$key line $i white');
    _close(a.a ?? 1, e.a ?? 1, tolerance, '$key line $i alpha');
    _close(a.w, e.w, tolerance, '$key line $i width');
  }
}

void _compareResolved(
  Map<String, dynamic> expected,
  ResolvedOrbPreset actual,
  double tolerance,
  String key,
) {
  expect(actual.mode, expected['mode'], reason: '$key mode');
  _close(actual.speed, (expected['speed'] as num).toDouble(), tolerance,
      '$key speed');
  final expectedOpts = (expected['opts'] as Map<String, dynamic>);
  expect(actual.opts.keys.toSet(), expectedOpts.keys.toSet(),
      reason: '$key opts keys');
  for (final entry in expectedOpts.entries) {
    _close(actual.opts[entry.key]!, (entry.value as num).toDouble(), tolerance,
        '$key opts ${entry.key}');
  }
}

void main() {
  test('engine matches all golden vectors', () {
    final golden = jsonDecode(_goldenFile().readAsStringSync())
        as Map<String, dynamic>;
    final tolerance = (golden['tolerance'] as num).toDouble();
    final resolved = golden['resolved'] as Map<String, dynamic>;
    final cases = (golden['cases'] as List<dynamic>).cast<Map<String, dynamic>>();

    expect(cases, hasLength(72));

    for (final item in cases) {
      final key = item['key'] as String;
      final state = OrbState.values.byName(item['state'] as String);
      final size = item['size'] as int;
      final t = (item['t'] as num).toDouble();

      final preset = resolvePreset(state, size);
      _compareResolved(
        resolved['${state.name}-$size'] as Map<String, dynamic>,
        preset,
        tolerance,
        key,
      );

      final frame = modeFrame(preset.mode)(
        size.toDouble(),
        t,
        preset.opts,
      );
      final expectedDots = _dots(item['dots'] as List<dynamic>);
      final expectedLines = _lines(item['lines'] as List<dynamic>);

      expect(frame.dots, hasLength(item['dotCount'] as int),
          reason: '$key dotCount');
      expect(frame.lines, hasLength(item['lineCount'] as int),
          reason: '$key lineCount');

      _compareDotMultiset(frame.dots, expectedDots, tolerance, key);
      for (var i = 1; i < frame.dots.length; i++) {
        expect(frame.dots[i].z, greaterThanOrEqualTo(frame.dots[i - 1].z),
            reason: '$key dots are not sorted far to near at $i');
      }
      _compareLines(frame.lines, expectedLines, tolerance, key);
    }
  });

  test('resolved presets are cached and cover every state and size', () {
    for (final state in OrbState.values) {
      for (final size in const [64, 32, 20]) {
        final first = resolvePreset(state, size);
        final second = resolvePreset(state, size);
        expect(identical(first, second), isTrue);
        expect(first.opts, isNotEmpty);
      }
    }
  });
}
