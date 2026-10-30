// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: packages/thinking_orbs/spec/orbs-spec.json
// Regenerate with: dart run tool/gen_orb_spec.dart

import 'spec_types.dart';

const String orbSpecVersion = '1.0.0';
const String orbSourceLibrary = 'thinking-orbs';
const String orbSourceVersion = '0.3.1';

const String kDefaultOrbState = 'working';
const int kDefaultOrbSize = 64;
const String kDefaultOrbTheme = 'auto';
const double kDefaultOrbSpeed = 1.0;
const bool kDefaultOrbPaused = false;

const Map<String, String> kStateToMode = {
  'breathing': 'ring',
  'composing': 'ribbon',
  'connecting': 'web',
  'listening': 'wave',
  'searching': 'globe',
  'shaping': 'morph',
  'solving': 'rubik',
  'weaving': 'braid',
  'working': 'orbits',
};

const Map<String, String> kOrbSemanticLabels = {
  'breathing': 'Thinking…',
  'composing': 'Composing…',
  'connecting': 'Connecting…',
  'listening': 'Listening…',
  'searching': 'Searching…',
  'shaping': 'Shaping…',
  'solving': 'Solving…',
  'weaving': 'Weaving…',
  'working': 'Working…',
};

const Map<String, Map<String, double>> kBaseProfiles = {
  'braid': {
    'ghostN': 150.0,
    'rBase': 1.2,
    'rDepth': 1.8,
    'rMin': 0.3,
    'rsPow': 0.6,
    'strandN': 52.0,
    'turns': 3.0,
  },
  'globe': {
    'inkFar': 0.62,
    'inkSpan': 0.54,
    'latRings': 17.0,
    'lonDensity': 44.0,
    'rBase': 0.6,
    'rBoost': 1.0,
    'rDepth': 1.7,
    'rMin': 0.3,
    'rsPow': 0.6,
  },
  'morph': {
    'iconD': 1.0,
    'rDot': 0.021,
    'rMin': 0.25,
  },
  'orbits': {
    'ghostA': 0.5,
    'ghostN': 40.0,
    'ghostR': 0.9,
    'orbitN': 12.0,
    'partR': 1.2,
    'partRDepth': 1.6,
    'particles': 3.0,
    'rMin': 0.3,
    'rsPow': 0.6,
  },
  'ribbon': {
    'ghostN': 150.0,
    'lanes': 5.0,
    'rBase': 1.1,
    'rDepth': 1.7,
    'rMin': 0.3,
    'rsPow': 0.6,
    'segs': 88.0,
  },
  'ring': {
    'faceOn': 1.0,
    'ghostN': 0.0,
    'lanes': 5.0,
    'rBase': 1.1,
    'rDepth': 1.7,
    'rMin': 0.3,
    'rsPow': 0.6,
    'segs': 88.0,
  },
  'rubik': {
    'inkFar': 0.62,
    'inkSpan': 0.54,
    'latRings': 15.0,
    'lonDensity': 40.0,
    'moveCount': 14.0,
    'rActive': 0.3,
    'rBase': 0.6,
    'rDepth': 1.7,
    'rMin': 0.3,
    'rsPow': 0.6,
  },
  'wave': {
    'lonDensity': 40.0,
    'rBase': 0.6,
    'rDepth': 1.7,
    'rMin': 0.3,
    'rings': 15.0,
    'rsPow': 0.6,
  },
  'web': {
    'lineW': 0.8,
    'nodeN': 30.0,
    'nodeR': 1.4,
    'nodeRDepth': 1.8,
    'rMin': 0.3,
    'rsPow': 0.6,
    'signals': 5.0,
    'thr': 0.72,
  },
};

const Map<String, Map<int, OrbPresetSpec>> kOrbPresets = {
  'braid': {
    20: OrbPresetSpec(speed: 2.75, count: 0.1125, size: 1.36),
    64: OrbPresetSpec(speed: 1.625, count: 0.5, size: 1.0),
  },
  'globe': {
    20: OrbPresetSpec(speed: 2.665, count: 0.105, size: 1.75, extra: {'dimBase': 0.45, 'scanMul': 4.335, }),
    64: OrbPresetSpec(speed: 2.015, count: 0.42, size: 1.15, extra: {'dimBase': 0.45, 'scanMul': 4.08, }),
  },
  'morph': {
    20: OrbPresetSpec(speed: 2.08, count: 0.53, size: 1.011, extra: {'spread': 1.45, }),
    64: OrbPresetSpec(speed: 2.405, count: 0.702, size: 0.395, extra: {'spread': 1.45, }),
  },
  'orbits': {
    20: OrbPresetSpec(speed: 3.9, count: 0.238, size: 2.4),
    64: OrbPresetSpec(speed: 1.885, count: 1.0, size: 1.0),
  },
  'ribbon': {
    20: OrbPresetSpec(speed: 3.12, count: 0.051, size: 1.073, extra: {'bandMul': 4.94, 'spin': 0.0, 'wobMul': 1.0, }),
    64: OrbPresetSpec(speed: 2.34, count: 0.25, size: 0.85, extra: {'bandMul': 3.9, 'spin': 0.0, 'wobMul': 1.0, }),
  },
  'ring': {
    20: OrbPresetSpec(speed: 3.78, count: 0.028, size: 1.622, extra: {'bandMul': 3.968, 'spin': 0.0, 'wobMul': 0.565, }),
    64: OrbPresetSpec(speed: 3.24, count: 0.25, size: 0.956, extra: {'bandMul': 3.627, 'spin': 0.0, 'wobMul': 0.368, }),
  },
  'rubik': {
    20: OrbPresetSpec(speed: 1.95, count: 0.088, size: 1.9),
    64: OrbPresetSpec(speed: 1.82, count: 0.35, size: 1.05),
  },
  'wave': {
    20: OrbPresetSpec(speed: 3.998, count: 0.105, size: 1.6),
    64: OrbPresetSpec(speed: 4.388, count: 0.341, size: 1.0),
  },
  'web': {
    20: OrbPresetSpec(speed: 6.63, count: 0.25, size: 1.52),
    64: OrbPresetSpec(speed: 3.315, count: 1.35, size: 0.95),
  },
};

const List<List<String>> kCountPairs = [
  ['latRings', 'lonDensity'],
  ['rings', 'lonDensity'],
  ['lanes', 'segs'],
];
const List<String> kCountKeys = [
  'orbitN',
  'ghostN',
  'nodeN',
  'strandN',
  'signals',
];
const List<String> kIconDensityKeys = [
  'iconD',
];
const List<String> kRadiusKeys = [
  'rBase',
  'rDepth',
  'rActive',
  'rDot',
  'ghostR',
  'partR',
  'partRDepth',
  'nodeR',
  'nodeRDepth',
];

const double kOrbCullAlphaBelow = 0.02;
const int kOrbDevicePixelRatioCap = 2;
const double kOrbReducedMotionTime = 0.6;

const double kMorphHold = 1.4;
const double kMorphMorph = 0.9;
const double kRubikSlotDuration = 0.42;
const double kRubikRest = 1.2;
