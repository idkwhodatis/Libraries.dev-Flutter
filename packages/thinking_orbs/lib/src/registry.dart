import 'modes/braid.dart';
import 'modes/lattice.dart';
import 'modes/morph.dart';
import 'modes/orbits.dart';
import 'modes/ribbon.dart';
import 'modes/web.dart';
import 'types.dart';

typedef ModeFrame = OrbFrame Function(double size, double t, ModeOpts opts);

const Map<String, ModeFrame> kModeFrames = {
  'orbits': frameOrbits,
  'globe': frameGlobe,
  'rubik': frameRubik,
  'wave': frameWave,
  'web': frameWeb,
  'braid': frameBraid,
  'ribbon': frameRibbon,
  'ring': frameRibbon,
  'morph': frameMorph,
};

ModeFrame modeFrame(String mode) {
  final frame = kModeFrames[mode];
  if (frame == null) throw ArgumentError.value(mode, 'mode', 'Unknown orb mode');
  return frame;
}
