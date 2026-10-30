import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'types.dart';

class BotAvatar extends StatefulWidget {
  const BotAvatar({
    super.key,
    this.type = BotAvatarType.clover,
    this.state = BotAvatarState.idle,
    this.face = BotAvatarFace.eyes,
    this.size = 64,
    this.color,
    this.ink,
    this.speed = 1,
    this.paused = false,
    this.seed = 0,
    this.theme = BotAvatarTheme.auto,
    this.semanticLabel,
  });

  final BotAvatarType type;
  final BotAvatarState state;
  final BotAvatarFace face;
  final double size;
  final String? color;
  final String? ink;
  final double speed;
  final bool paused;
  final int seed;
  final BotAvatarTheme theme;
  final String? semanticLabel;

  @override
  State<BotAvatar> createState() => _BotAvatarState();
}

class _BotAvatarState extends State<BotAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
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
  void didUpdateWidget(covariant BotAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paused != widget.paused ||
        oldWidget.state != widget.state) {
      _sync();
    }
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
    final dark = switch (widget.theme) {
      BotAvatarTheme.dark => true,
      BotAvatarTheme.light => false,
      BotAvatarTheme.auto =>
        Theme.of(context).brightness == Brightness.dark,
    };
    return Semantics(
      image: true,
      label: widget.semanticLabel ?? 'Bot avatar',
      child: RepaintBoundary(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final time = _reduced || widget.paused
                  ? 0.3
                  : _controller.value * math.pi * 2 * widget.speed;
              return CustomPaint(
                painter: _BotPainter(
                  type: widget.type,
                  state: widget.state,
                  face: widget.face,
                  time: time,
                  seed: widget.seed,
                  dark: dark,
                  color: _parse(widget.color),
                  ink: _parse(widget.ink) ?? const Color(0xFF171717),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Color? _parse(String? value) {
    if (value == null) return null;
    final hex = RegExp(r'^#([0-9a-f]{3}|[0-9a-f]{6})$', caseSensitive: false)
        .firstMatch(value.trim());
    if (hex != null) {
      var digits = hex.group(1)!;
      if (digits.length == 3) {
        digits = digits.split('').map((c) => '$c$c').join();
      }
      return Color(int.parse('FF$digits', radix: 16));
    }
    final rgb = RegExp(r'^rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)')
        .firstMatch(value.trim());
    if (rgb != null) {
      return Color.fromARGB(
        255,
        double.parse(rgb.group(1)!).round(),
        double.parse(rgb.group(2)!).round(),
        double.parse(rgb.group(3)!).round(),
      );
    }
    return null;
  }
}

class _BotPainter extends CustomPainter {
  _BotPainter({
    required this.type,
    required this.state,
    required this.face,
    required this.time,
    required this.seed,
    required this.dark,
    required this.color,
    required this.ink,
  });

  final BotAvatarType type;
  final BotAvatarState state;
  final BotAvatarFace face;
  final double time;
  final int seed;
  final bool dark;
  final Color? color;
  final Color ink;

  Color get _base {
    if (color != null) return color!;
    final hue = (type.index * 37 + seed * 23) % 360;
    return HSLColor.fromAHSL(1, hue.toDouble(), 0.62, dark ? 0.58 : 0.6)
        .toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);
    final bob = switch (state) {
      BotAvatarState.working => math.sin(time * 2).abs() * s * 0.07,
      BotAvatarState.sleeping => 0.0,
      BotAvatarState.idle => math.sin(time) * s * 0.012,
    };
    final tilt = switch (state) {
      BotAvatarState.working => math.sin(time) * 0.05,
      BotAvatarState.sleeping => -0.08,
      BotAvatarState.idle => math.sin(time * 0.5) * 0.015,
    };
    canvas.save();
    canvas.translate(center.dx, center.dy - bob);
    canvas.rotate(tilt);

    final shadow = Paint()..color = const Color(0x33000000);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(0, s * 0.38 + bob),
        width: s * 0.48,
        height: s * 0.09,
      ),
      shadow,
    );

    final bodyWidth = s * 0.62;
    final bodyHeight = s * 0.66;
    final bodyRect = Rect.fromCenter(
      center: Offset.zero,
      width: bodyWidth,
      height: bodyHeight,
    );
    final body = _bodyPath(bodyRect, s);
    final base = _base;
    final light = Color.lerp(base, Colors.white, 0.18)!;
    final shade = Color.lerp(base, Colors.black, 0.18)!;
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [light, base, shade],
        stops: const [0, 0.52, 1],
      ).createShader(bodyRect);
    canvas.drawPath(body, bodyPaint);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, s * 0.012)
      ..color = Colors.white.withValues(alpha: 0.18);
    canvas.drawPath(body, rim);

    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.45, -0.5),
        radius: 0.65,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(bodyRect);
    canvas.drawPath(body, highlightPaint);

    _drawFace(canvas, s, bodyRect);
    canvas.restore();
  }

  Path _bodyPath(Rect rect, double s) {
    final w = rect.width / 2;
    final h = rect.height / 2;
    switch (type) {
      case BotAvatarType.circle:
      case BotAvatarType.pebble:
        return Path()..addOval(rect);
      case BotAvatarType.square:
      case BotAvatarType.mech:
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              rect,
              Radius.circular(rect.width * 0.2),
            ),
          );
      case BotAvatarType.pill:
      case BotAvatarType.droid:
        return Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset.zero,
                width: rect.width * 0.8,
                height: rect.height * 1.04,
              ),
              Radius.circular(rect.width * 0.32),
            ),
          );
      case BotAvatarType.triangle:
        return Path()
          ..moveTo(0, -h)
          ..lineTo(w, h * 0.72)
          ..lineTo(-w, h * 0.72)
          ..close();
      case BotAvatarType.hexagon:
        return _polygon(w, h, 6, -math.pi / 2);
      case BotAvatarType.star:
        return _star(w, h);
      case BotAvatarType.clover:
        return _cluster(rect, 4, w * 0.58, h * 0.58);
      case BotAvatarType.flower:
        return _cluster(rect, 6, w * 0.52, h * 0.52);
      case BotAvatarType.cloud:
        return _cluster(rect, 5, w * 0.5, h * 0.5);
      case BotAvatarType.drop:
        final path = Path()
          ..moveTo(0, -h)
          ..cubicTo(w * 0.85, -h * 0.2, w * 0.9, h * 0.45, 0, h)
          ..cubicTo(-w * 0.9, h * 0.45, -w * 0.85, -h * 0.2, 0, -h);
        return path;
      case BotAvatarType.ghost:
        final path = Path()
          ..moveTo(-w, h * 0.55)
          ..lineTo(-w, -h * 0.25)
          ..cubicTo(-w, -h, w, -h, w, -h * 0.25)
          ..lineTo(w, h * 0.55)
          ..quadraticBezierTo(w * 0.55, h * 0.85, w * 0.3, h * 0.55)
          ..quadraticBezierTo(0, h * 0.25, -w * 0.3, h * 0.55)
          ..quadraticBezierTo(-w * 0.55, h * 0.85, -w, h * 0.55)
          ..close();
        return path;
      case BotAvatarType.puddle:
      case BotAvatarType.blob:
      case BotAvatarType.cat:
      case BotAvatarType.alien:
        final path = Path()
          ..moveTo(0, -h)
          ..cubicTo(w * 0.65, -h, w, -h * 0.45, w, 0)
          ..cubicTo(w, h * 0.5, w * 0.55, h, 0, h)
          ..cubicTo(-w * 0.6, h, -w, h * 0.45, -w, 0)
          ..cubicTo(-w, -h * 0.5, -w * 0.55, -h, 0, -h);
        return path;
    }
  }

  Path _polygon(double w, double h, int sides, double start) {
    final path = Path();
    for (var i = 0; i < sides; i++) {
      final a = start + i * 2 * math.pi / sides;
      final p = Offset(math.cos(a) * w, math.sin(a) * h);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  Path _star(double w, double h) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final a = -math.pi / 2 + i * math.pi / 5;
      final scale = i.isEven ? 1.0 : 0.46;
      final p = Offset(
        math.cos(a) * w * scale,
        math.sin(a) * h * scale,
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  Path _cluster(Rect rect, int count, double lobeW, double lobeH) {
    final path = Path()..fillType = PathFillType.nonZero;
    final center = rect.center;
    final separation = math.min(lobeW, lobeH) * 0.72;
    for (var i = 0; i < count; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / count;
      final c = center + Offset(
        math.cos(a) * separation,
        math.sin(a) * separation,
      );
      path.addOval(
        Rect.fromCenter(center: c, width: lobeW, height: lobeH),
      );
    }
    path.addOval(
      Rect.fromCenter(
        center: center,
        width: lobeW * 1.35,
        height: lobeH * 1.35,
      ),
    );
    return path;
  }

  void _drawFace(Canvas canvas, double s, Rect body) {
    final eyeY = -body.height * 0.06;
    final eyeX = body.width * 0.16;
    final eyeW = s * 0.085;
    final eyeH = s * 0.115;
    final blink = state == BotAvatarState.sleeping ||
        (state != BotAvatarState.sleeping &&
            math.sin(time * 1.7 + seed) > 0.96);

    final eyePaint = Paint()..color = ink;
    if (blink) {
      final line = Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, s * 0.018)
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(-eyeX - eyeW / 2, eyeY),
        Offset(-eyeX + eyeW / 2, eyeY),
        line,
      );
      canvas.drawLine(
        Offset(eyeX - eyeW / 2, eyeY),
        Offset(eyeX + eyeW / 2, eyeY),
        line,
      );
    } else {
      for (final direction in const [-1, 1]) {
        final rect = Rect.fromCenter(
          center: Offset(direction * eyeX, eyeY),
          width: eyeW,
          height: eyeH,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(eyeW)),
          eyePaint,
        );
        canvas.drawCircle(
          Offset(
            direction * eyeX - eyeW * 0.16,
            eyeY - eyeH * 0.2,
          ),
          eyeW * 0.16,
          Paint()..color = Colors.white.withValues(alpha: 0.9),
        );
      }
    }

    if (face == BotAvatarFace.mouth) {
      final mouthPaint = Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, s * 0.018)
        ..strokeCap = StrokeCap.round;
      final mouthRect = Rect.fromCenter(
        center: Offset(0, body.height * 0.16),
        width: s * 0.14,
        height: state == BotAvatarState.working ? s * 0.07 : s * 0.035,
      );
      canvas.drawArc(
        mouthRect,
        state == BotAvatarState.working ? 0.1 : 0.15,
        state == BotAvatarState.working ? math.pi * 0.8 : math.pi * 0.7,
        false,
        mouthPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BotPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.state != state ||
        oldDelegate.face != face ||
        oldDelegate.time != time ||
        oldDelegate.seed != seed ||
        oldDelegate.dark != dark ||
        oldDelegate.color != color ||
        oldDelegate.ink != ink;
  }
}
