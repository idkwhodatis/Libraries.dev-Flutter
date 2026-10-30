import 'dart:math' as math;

import 'magnet_bridge.dart';

class CalibrationSpot {
  const CalibrationSpot({required this.screen, required this.delta});

  final MagnetPoint screen;
  final List<double> delta;
}

class CalibrationFit {
  const CalibrationFit({
    required this.face,
    required this.strength,
    required this.sensor,
    required this.height,
    required this.error,
  });

  final int face;
  final double strength;
  final MagnetPoint sensor;
  final double height;
  final double error;
}

const _pixelsPerCm = 160 / 2.54;

List<double> _unitField(
  double offsetX,
  double offsetY,
  double height,
  int face,
) {
  final r = math.sqrt(
    offsetX * offsetX + offsetY * offsetY + height * height,
  );
  final rx = -offsetX / r;
  final ry = -offsetY / r;
  final rz = -height / r;
  final mDotR = face * rz;
  final k = 1 / (r * r * r);
  return [
    k * 3 * mDotR * rx,
    k * 3 * mDotR * ry,
    k * (3 * mDotR * rz - face),
  ];
}

CalibrationFit? fitCalibration(
  List<CalibrationSpot> spots,
  MagnetPoint screenDp,
) {
  if (spots.length < 3) return null;
  var norm = 0.0;
  for (final spot in spots) {
    norm += spot.delta[0] * spot.delta[0] +
        spot.delta[1] * spot.delta[1] +
        spot.delta[2] * spot.delta[2];
  }
  if (norm <= 0) return null;

  CalibrationFit? best;
  for (final face in const [1, -1]) {
    for (var sx = 0.0; sx <= screenDp.x; sx += 8) {
      for (var sy = -30.0; sy <= screenDp.y * 0.5; sy += 8) {
        for (var h = 0.6; h <= 5.01; h += 0.2) {
          var bg = 0.0;
          var gg = 0.0;
          final fields = <List<double>>[];
          for (final spot in spots) {
            final field = _unitField(
              (spot.screen.x - sx) / _pixelsPerCm,
              -(spot.screen.y - sy) / _pixelsPerCm,
              h,
              face,
            );
            bg += field[0] * spot.delta[0] +
                field[1] * spot.delta[1] +
                field[2] * spot.delta[2];
            gg += field[0] * field[0] +
                field[1] * field[1] +
                field[2] * field[2];
            fields.add(field);
          }
          final strength = bg / gg;
          if (!(strength > 0)) continue;
          var error = 0.0;
          for (var i = 0; i < spots.length; i++) {
            final field = fields[i];
            for (var axis = 0; axis < 3; axis++) {
              final diff = spots[i].delta[axis] - strength * field[axis];
              error += diff * diff;
            }
          }
          error /= norm;
          if (best == null || error < best.error) {
            best = CalibrationFit(
              face: face,
              strength: strength,
              sensor: MagnetPoint(sx, sy),
              height: h,
              error: error,
            );
          }
        }
      }
    }
  }
  return best;
}
