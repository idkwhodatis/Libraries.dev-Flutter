import 'dart:math' as math;

import 'spec.g.dart';
import 'types.dart';

double opt(ModeOpts opts, String key, double fallback) => opts[key] ?? fallback;

int optInt(ModeOpts opts, String key, int fallback) =>
    (opts[key] ?? fallback.toDouble()).round();

Map<String, double> baseProfile(String mode) {
  final profile = kBaseProfiles[mode];
  if (profile == null) {
    throw ArgumentError.value(mode, 'mode', 'Unknown orb mode');
  }
  return Map<String, double>.of(profile);
}

ModeOpts scaleCounts(ModeOpts opts, double scale) {
  final out = Map<String, double>.of(opts);
  final done = <String>{};
  final rt = math.sqrt(scale);
  for (final pair in kCountPairs) {
    final a = pair[0];
    final b = pair[1];
    final va = out[a];
    final vb = out[b];
    if (va != null && vb != null && !done.contains(a) && !done.contains(b)) {
      out[a] = math.max(2, (va * rt).round()).toDouble();
      out[b] = math.max(2, (vb * rt).round()).toDouble();
      done
        ..add(a)
        ..add(b);
    }
  }
  for (final key in kCountKeys) {
    final value = out[key];
    if (value != null && value != 0 && !done.contains(key)) {
      out[key] = math.max(1, (value * scale).round()).toDouble();
    }
  }
  for (final key in kIconDensityKeys) {
    final value = out[key];
    if (value != null) out[key] = math.max(0.02, value * scale);
  }
  return out;
}

ModeOpts scaleRadii(ModeOpts opts, double scale) {
  final out = Map<String, double>.of(opts);
  for (final key in kRadiusKeys) {
    final value = out[key];
    if (value != null) out[key] = value * scale;
  }
  out['rSizeMul'] = (out['rSizeMul'] ?? 1) * scale;
  return out;
}

int countDots(ModeOpts opts) {
  var total = 0.0;
  final done = <String>{};
  for (final pair in kCountPairs) {
    final a = pair[0];
    final b = pair[1];
    final va = opts[a];
    final vb = opts[b];
    if (va != null && vb != null && !done.contains(a) && !done.contains(b)) {
      total += va * vb;
      done
        ..add(a)
        ..add(b);
    }
  }
  for (final key in kCountKeys) {
    final value = opts[key];
    if (value != null && value != 0 && !done.contains(key)) total += value;
  }
  return total.round();
}
