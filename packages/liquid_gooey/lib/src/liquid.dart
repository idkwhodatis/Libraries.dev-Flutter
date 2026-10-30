import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'types.dart';

class Liquid extends StatefulWidget {
  const Liquid({
    super.key,
    this.child,
    this.fill = Colors.white,
    this.background = const Color(0xFF171717),
    this.blur = 6,
    this.contrast = 18,
    this.borderRadius = 24,
    this.paused = false,
    this.blobs,
    this.effect = LiquidEffect.morph,
  });

  final Widget? child;
  final Color fill;
  final Color background;
  final double blur;
  final double contrast;
  final double borderRadius;
  final bool paused;
  final List<LiquidBlob>? blobs;
  final LiquidEffect effect;

  @override
  State<Liquid> createState() => _LiquidState();
}

class _LiquidState extends State<Liquid> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduced != _reduced) {
      _reduced = reduced;
      _sync();
    }
  }

  @override
  void didUpdateWidget(covariant Liquid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paused != widget.paused) _sync();
  }

  void _sync() {
    if (widget.paused || _reduced) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matrix = ColorFilter.matrix(<double>[
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, widget.contrast, -widget.contrast * 0.5,
    ]);
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: ColoredBox(
        color: widget.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return ColorFiltered(
                  colorFilter: matrix,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: widget.blur,
                      sigmaY: widget.blur,
                    ),
                    child: CustomPaint(
                      painter: _GooPainter(
                        time: _reduced || widget.paused
                            ? 0.4
                            : _controller.value,
                        fill: widget.fill,
                        blobs: widget.blobs,
                        effect: widget.effect,
                      ),
                    ),
                  ),
                );
              },
            ),
            if (widget.child != null) widget.child!,
          ],
        ),
      ),
    );
  }
}

class LiquidItem extends StatelessWidget {
  const LiquidItem({
    super.key,
    required this.child,
    this.fill = Colors.white,
    this.background = const Color(0xFF171717),
    this.borderRadius = 50,
  });

  final Widget child;
  final Color fill;
  final Color background;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Liquid(
      fill: fill,
      background: background,
      borderRadius: borderRadius,
      child: Center(child: child),
    );
  }
}

class _GooPainter extends CustomPainter {
  _GooPainter({
    required this.time,
    required this.fill,
    required this.blobs,
    required this.effect,
  });

  final double time;
  final Color fill;
  final List<LiquidBlob>? blobs;
  final LiquidEffect effect;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = time * math.pi * 2;
    final items = blobs ?? _defaults(size);
    for (var i = 0; i < items.length; i++) {
      final blob = items[i];
      final wobble = effect == LiquidEffect.morph
          ? math.sin(phase + i * 1.7)
          : math.sin(phase * 0.5 + i) * 0.5;
      final x = blob.x + wobble * (effect == LiquidEffect.move ? 0.06 : 0.02);
      final y = blob.y + math.cos(phase + i * 1.3) * 0.03;
      final paint = Paint()
        ..color = blob.color ?? fill
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        blob.radius * size.shortestSide,
        paint,
      );
    }
  }

  List<LiquidBlob> _defaults(Size size) {
    return const [
      LiquidBlob(x: 0.32, y: 0.55, radius: 0.22),
      LiquidBlob(x: 0.48, y: 0.42, radius: 0.26),
      LiquidBlob(x: 0.66, y: 0.54, radius: 0.2),
      LiquidBlob(x: 0.52, y: 0.68, radius: 0.13),
    ];
  }

  @override
  bool shouldRepaint(covariant _GooPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.fill != fill ||
        oldDelegate.blobs != blobs ||
        oldDelegate.effect != effect;
  }
}

