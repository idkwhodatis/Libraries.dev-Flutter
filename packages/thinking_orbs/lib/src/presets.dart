import 'profiles.dart';
import 'spec.g.dart';
import 'spec_types.dart';
import 'types.dart';

class ResolvedOrbPreset {
  const ResolvedOrbPreset({
    required this.mode,
    required this.speed,
    required this.opts,
  });

  final String mode;
  final double speed;
  final ModeOpts opts;
}

const Map<String, OrbPresetSpec> kPreset32 = {
  'orbits': OrbPresetSpec(speed: 2.9072, count: 0.4251, size: 1.6849),
  'globe': OrbPresetSpec(
    speed: 2.3803,
    count: 0.1839,
    size: 1.4769,
    extra: {'scanMul': 4.2301, 'dimBase': 0.45},
  ),
  'rubik': OrbPresetSpec(speed: 1.8964, count: 0.1537, size: 1.4951),
  'wave': OrbPresetSpec(speed: 4.1512, count: 0.169, size: 1.3232),
  'web': OrbPresetSpec(speed: 5.0104, count: 0.4942, size: 1.2571),
  'braid': OrbPresetSpec(speed: 2.2234, count: 0.2056, size: 1.2011),
  'ribbon': OrbPresetSpec(
    speed: 2.7776,
    count: 0.0969,
    size: 0.9766,
    extra: {'spin': 0, 'bandMul': 4.49, 'wobMul': 1},
  ),
  'ring': OrbPresetSpec(
    speed: 3.5517,
    count: 0.0678,
    size: 1.31,
    extra: {'spin': 0, 'bandMul': 3.8265, 'wobMul': 0.4751},
  ),
  'morph': OrbPresetSpec(
    speed: 2.2057,
    count: 0.5937,
    size: 0.6916,
    extra: {'spread': 1.45},
  ),
};

final Map<String, ResolvedOrbPreset> _cache = {};

ResolvedOrbPreset resolvePreset(OrbState state, int size) {
  final key = '${state.name}-$size';
  final hit = _cache[key];
  if (hit != null) return hit;

  final mode = kStateToMode[state.name];
  if (mode == null) {
    throw ArgumentError.value(state, 'state', 'Unknown orb state');
  }
  final spec = size == 32 ? kPreset32[mode] : kOrbPresets[mode]?[size];
  if (spec == null) {
    throw ArgumentError.value(size, 'size', 'Unsupported orb size');
  }

  var opts = baseProfile(mode);
  if (spec.count != 1) opts = scaleCounts(opts, spec.count);
  if (spec.size != 1) opts = scaleRadii(opts, spec.size);
  if (spec.extra.isNotEmpty) opts = {...opts, ...spec.extra};

  final resolved = ResolvedOrbPreset(mode: mode, speed: spec.speed, opts: opts);
  _cache[key] = resolved;
  return resolved;
}
