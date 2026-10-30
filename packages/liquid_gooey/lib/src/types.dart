import 'package:flutter/material.dart';

enum LiquidEffect { morph, move, melt, bend }

class LiquidBlob {
  const LiquidBlob({
    required this.x,
    required this.y,
    required this.radius,
    this.color,
  });

  final double x;
  final double y;
  final double radius;
  final Color? color;
}
