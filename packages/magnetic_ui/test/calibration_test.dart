import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:magnetic_ui/magnetic_ui.dart';

const _ppcm = 160 / 2.54;

List<double> _field(
  double offsetX,
  double offsetY,
  double height,
  int face,
) {
  final r = math.sqrt(offsetX * offsetX + offsetY * offsetY + height * height);
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

void main() {
  test('recovers a synthetic dipole fit from calibration spots', () {
    const sensor = MagnetPoint(200, 394);
    const height = 1.6;
    const face = -1;
    const strength = 2.5;
    const screen = MagnetPoint(400, 800);

    final points = <MagnetPoint>[
      const MagnetPoint(100, 200),
      const MagnetPoint(300, 250),
      const MagnetPoint(200, 600),
      const MagnetPoint(350, 700),
    ];
    final spots = [
      for (final point in points)
        CalibrationSpot(
          screen: point,
          delta: [
            for (final value in _field(
              (point.x - sensor.x) / _ppcm,
              -(point.y - sensor.y) / _ppcm,
              height,
              face,
            ))
              value * strength,
          ],
        ),
    ];

    final fit = fitCalibration(spots, screen);

    expect(fit, isNotNull);
    expect(fit!.face, face);
    expect(fit.sensor.x, closeTo(sensor.x, 1e-6));
    expect(fit.sensor.y, closeTo(sensor.y, 1e-6));
    expect(fit.height, closeTo(height, 1e-6));
    expect(fit.strength, closeTo(strength, 1e-6));
    expect(fit.error, lessThan(1e-12));
  });

  test('requires enough spots and a non-zero field', () {
    expect(fitCalibration(const [], const MagnetPoint(400, 800)), isNull);
    expect(
      fitCalibration(
        const [
          CalibrationSpot(
            screen: MagnetPoint(1, 1),
            delta: [0, 0, 0],
          ),
          CalibrationSpot(
            screen: MagnetPoint(2, 2),
            delta: [0, 0, 0],
          ),
          CalibrationSpot(
            screen: MagnetPoint(3, 3),
            delta: [0, 0, 0],
          ),
        ],
        const MagnetPoint(400, 800),
      ),
      isNull,
    );
  });
}


