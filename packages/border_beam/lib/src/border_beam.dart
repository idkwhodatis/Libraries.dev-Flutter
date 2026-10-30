import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'beam_spec.dart';
import 'types.dart';

class BorderBeam extends StatefulWidget {
  const BorderBeam({
    super.key,
    required this.child,
    this.size = BorderBeamSize.md,
    this.colorVariant = BorderBeamColorVariant.colorful,
    this.theme = BorderBeamTheme.dark,
    this.duration,
    this.active = true,
    this.borderRadius,
    this.brightness = 1.3,
    this.saturation = 1.2,
    this.hueRange = 30,
    this.staticColors = false,
    this.strength = 1,
    this.onActivate,
    this.onDeactivate,
  });

  final Widget child;
  final BorderBeamSize size;
  final BorderBeamColorVariant colorVariant;
  final BorderBeamTheme theme;
  final double? duration;
  final bool active;
  final double? borderRadius;
  final double brightness;
  final double saturation;
  final double hueRange;
  final bool staticColors;
  final double strength;
  final VoidCallback? onActivate;
  final VoidCallback? onDeactivate;

  @override
  State<BorderBeam> createState() => _BorderBeamState();
}

class _BorderBeamState extends State<BorderBeam>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  BeamSpec? _spec;
  bool _reduced = false;

  double get _cycle {
    if (widget.duration != null) return widget.duration!;
    return switch (widget.size) {
      BorderBeamSize.line => 3.1,
      BorderBeamSize.pulseInner || BorderBeamSize.pulseOutside => 2.3,
      _ => 1.96,
    };
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (_cycle * 1000).round()),
    );
    if (widget.active) _controller.repeat();
    BeamSpec.load().then((spec) {
      if (mounted && spec != null) setState(() => _spec = spec);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduced != _reduced) {
      _reduced = reduced;
      _syncAnimation();
    }
  }

  @override
  void didUpdateWidget(covariant BorderBeam oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size ||
        oldWidget.duration != widget.duration) {
      _controller.duration =
          Duration(milliseconds: (_cycle * 1000).round());
    }
    if (oldWidget.active != widget.active) {
      _syncAnimation();
      if (widget.active) {
        widget.onActivate?.call();
      } else {
        widget.onDeactivate?.call();
      }
    }
  }

  void _syncAnimation() {
    if (widget.active && !_reduced) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _resolveDark(BuildContext context) {
    return switch (widget.theme) {
      BorderBeamTheme.dark => true,
      BorderBeamTheme.light => false,
      BorderBeamTheme.auto =>
        Theme.of(context).brightness == Brightness.dark,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dark = _resolveDark(context);
    final paintOnTop = widget.size != BorderBeamSize.pulseOutside;
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final opacity = widget.active
            ? widget.strength.clamp(0.0, 1.0)
            : 0.0;
        final painter = _BeamPainter(
          type: widget.size,
          variant: widget.colorVariant,
          dark: dark,
          time: _reduced ? 0.32 : _controller.value,
          opacity: opacity,
          radius: widget.borderRadius,
          staticColors: widget.staticColors,
          spec: _spec,
        );
        return CustomPaint(
          painter: paintOnTop ? null : painter,
          foregroundPainter: paintOnTop ? painter : null,
          child: child,
        );
      },
    );
  }
}

class _BeamPainter extends CustomPainter {
  _BeamPainter({
    required this.type,
    required this.variant,
    required this.dark,
    required this.time,
    required this.opacity,
    required this.radius,
    required this.staticColors,
    required this.spec,
  });

  final BorderBeamSize type;
  final BorderBeamColorVariant variant;
  final bool dark;
  final double time;
  final double opacity;
  final double? radius;
  final bool staticColors;
  final BeamSpec? spec;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.001 || size.isEmpty) return;
    final rect = Offset.zero & size;
    final maxRadius = math.min(size.width, size.height) / 2;
    final sizeKey = type == BorderBeamSize.sm ? 'sm' : 'md';
    final presetRadius = spec?.borderRadius(sizeKey);
    final corner = math.min(
      radius ?? presetRadius ?? (type == BorderBeamSize.sm ? 24 : 16),
      maxRadius,
    );
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.75),
      Radius.circular(corner),
    );

    switch (type) {
      case BorderBeamSize.md:
      case BorderBeamSize.sm:
        if (spec != null) {
          _paintRotateSpec(canvas, rect, rrect, size, spec!);
        } else {
          _paintRotate(canvas, rect, rrect, size);
        }
      case BorderBeamSize.line:
        _paintLine(canvas, rect, rrect);
      case BorderBeamSize.pulseInner:
        _paintPulse(canvas, rrect, outside: false);
      case BorderBeamSize.pulseOutside:
        _paintPulse(canvas, rrect.inflate(3), outside: true);
    }
  }

  void _paintRotateSpec(
    Canvas canvas,
    Rect rect,
    RRect rrect,
    Size size,
    BeamSpec beamSpec,
  ) {
    final sizeKey = type == BorderBeamSize.sm ? 'sm' : 'md';
    final themeKey = dark ? 'dark' : 'light';
    final variantKey = variant.name;
    final mono = variant == BorderBeamColorVariant.mono;
    final base = opacity * (mono ? beamSpec.monoOpacityMultiplier : 1);
    final angle = staticColors ? 0.0 : time * math.pi * 2;
    final borderWidth = beamSpec.borderWidth(sizeKey);
    final innerRrect = rrect.deflate(borderWidth);
    final outerPath = Path()..addRRect(rrect);
    final innerPath = Path()..addRRect(innerRrect);
    final ring = Path.combine(PathOperation.difference, outerPath, innerPath);

    // Inner glow.
    final innerOpacity = base * beamSpec.innerOpacity(sizeKey, themeKey);
    if (innerOpacity > 0.001) {
      canvas.saveLayer(rect, Paint());
      canvas.clipPath(innerPath);
      for (final blob in beamSpec
          .innerBlobs(sizeKey, variantKey, mono)
          .reversed) {
        _drawBlob(canvas, rect, blob, innerOpacity);
      }
      final innerMask = _conicShader(
        rect,
        angle,
        sizeKey == 'sm'
            ? beamSpec.smallMaskStops()
            : beamSpec.beamMaskStops(),
        Colors.white,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..shader = innerMask
          ..blendMode = BlendMode.dstIn,
      );
      canvas.restore();
    }

    // Stroke ring.
    final strokeOpacity = base * beamSpec.strokeOpacity(sizeKey, themeKey);
    if (strokeOpacity > 0.001) {
      canvas.saveLayer(rect, Paint());
      canvas.clipPath(ring);
      for (final blob in beamSpec
          .borderBlobs(sizeKey, variantKey)
          .reversed) {
        _drawBlob(canvas, rect, blob, strokeOpacity);
      }
      final highlight = _conicShader(
        rect,
        angle,
        beamSpec.whiteStops(themeKey),
        dark ? Colors.white : Colors.black,
        alphaScale: strokeOpacity,
      );
      canvas.drawRect(rect, Paint()..shader = highlight);
      final mask = _conicShader(
        rect,
        angle,
        beamSpec.beamMaskStops(),
        Colors.white,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..shader = mask
          ..blendMode = BlendMode.dstIn,
      );
      canvas.restore();
    }

    // Outer bloom.
    final bloomOpacity = base * beamSpec.bloomOpacity(sizeKey, themeKey);
    if (bloomOpacity > 0.001) {
      final bloom = _conicShader(
        rect,
        angle,
        beamSpec.bloomStops(themeKey),
        dark ? Colors.white : Colors.black,
        alphaScale: bloomOpacity,
      );
      canvas.saveLayer(
        rect.inflate(beamSpec.bloomBlurPx + 4),
        Paint(),
      );
      canvas.drawRRect(
        rrect,
        Paint()
          ..shader = bloom
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            beamSpec.bloomBlurPx,
          ),
      );
      canvas.restore();
    }
  }

  void _drawBlob(Canvas canvas, Rect rect, BeamBlob blob, double opacity) {
    final center = Offset(blob.cx * rect.width, blob.cy * rect.height);
    final oval = Rect.fromCenter(
      center: center,
      width: blob.rx * 2,
      height: blob.ry * 2,
    );
    if (oval.isEmpty) return;
    final color = blob.color.withValues(alpha: blob.color.a * opacity);
    final shader = RadialGradient(
      colors: [color, color.withValues(alpha: 0)],
      stops: const [0, 1],
    ).createShader(oval);
    canvas.drawOval(oval, Paint()..shader = shader);
  }

  Shader _conicShader(
    Rect rect,
    double angle,
    List<double> stops,
    Color color, {
    double alphaScale = 1,
  }) {
    final colors = <Color>[];
    final positions = <double>[];
    for (var i = 0; i < stops.length; i += 2) {
      positions.add(stops[i].clamp(0.0, 1.0));
      colors.add(color.withValues(
        alpha: (stops[i + 1] * alphaScale).clamp(0.0, 1.0),
      ));
    }
    return SweepGradient(
      colors: colors,
      stops: positions,
      transform: GradientRotation(angle),
    ).createShader(rect);
  }

  void _paintRotate(Canvas canvas, Rect rect, RRect rrect, Size size) {
    final colors = _palette(variant, dark);
    final angle = staticColors ? 0.0 : time * math.pi * 2;
    final opaque = colors
        .map((c) => c.withValues(alpha: c.a * opacity))
        .toList(growable: false);
    final transparent = colors.first.withValues(alpha: 0);

    final beam = SweepGradient(
      colors: [
        transparent,
        opaque[0],
        opaque[1],
        opaque[2],
        opaque[3 % opaque.length],
        transparent,
      ],
      stops: const [0.0, 0.16, 0.34, 0.52, 0.72, 1.0],
      transform: GradientRotation(angle),
    ).createShader(rect);

    final bloomPaint = Paint()
      ..shader = beam
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    canvas.drawRRect(rrect.inflate(1.5), bloomPaint);

    final strokePaint = Paint()
      ..shader = beam
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35;
    canvas.drawRRect(rrect, strokePaint);

    final white = SweepGradient(
      colors: [
        transparent,
        Colors.white.withValues(alpha: 0.9 * opacity),
        transparent,
      ],
      stops: const [0.0, 0.08, 0.2],
      transform: GradientRotation(angle),
    ).createShader(rect);
    final highlightPaint = Paint()
      ..shader = white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawRRect(rrect, highlightPaint);

    canvas.save();
    canvas.clipRRect(rrect);
    final innerPaint = Paint()
      ..shader = beam
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawRRect(rrect.deflate(2), innerPaint);
    canvas.restore();
  }

  void _paintLine(Canvas canvas, Rect rect, RRect rrect) {
    final colors = _palette(variant, dark);
    final width = rect.width;
    final shift = (time % 1) * (width * 1.8) - width * 0.4;
    final shader = LinearGradient(
      colors: [
        colors[0].withValues(alpha: 0),
        colors[0].withValues(alpha: 0.9 * opacity),
        colors[2 % colors.length].withValues(alpha: 0.95 * opacity),
        colors[0].withValues(alpha: 0),
      ],
      stops: const [0.0, 0.32, 0.55, 1.0],
    ).createShader(
      Rect.fromLTWH(shift, 0, width * 1.2, rect.height),
    );
    final linePaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawLine(
      Offset(0, rect.height - 1),
      Offset(rect.width, rect.height - 1),
      linePaint,
    );
    canvas.restore();

    final hairline = Paint()
      ..color = colors[0].withValues(alpha: 0.2 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, hairline);
  }

  void _paintPulse(Canvas canvas, RRect rrect, {required bool outside}) {
    final colors = _palette(variant, dark);
    final pulse = 0.5 + 0.5 * math.sin(time * math.pi * 2);
    final alpha = (0.35 + 0.65 * pulse) * opacity;
    final shader = SweepGradient(
      colors: [
        colors[0].withValues(alpha: alpha),
        colors[1 % colors.length].withValues(alpha: alpha),
        colors[2 % colors.length].withValues(alpha: alpha),
        colors[0].withValues(alpha: alpha),
      ],
      transform: GradientRotation(time * math.pi * 2 * 0.15),
    ).createShader(rrect.outerRect);

    final glow = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = outside ? 10 : 7
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        outside ? 10 : 5,
      );
    canvas.drawRRect(outside ? rrect.inflate(2) : rrect.deflate(2), glow);

    final line = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(rrect, line);
  }

  List<Color> _palette(BorderBeamColorVariant variant, bool dark) {
    final base = switch (variant) {
      BorderBeamColorVariant.colorful => const [
          Color(0xFFFF4FD8),
          Color(0xFF7C5CFF),
          Color(0xFF26D9FF),
          Color(0xFF6CFFB3),
          Color(0xFFFFE16B),
        ],
      BorderBeamColorVariant.mono => const [
          Color(0xFFFFFFFF),
          Color(0xFFBDBDBD),
          Color(0xFFFFFFFF),
        ],
      BorderBeamColorVariant.ocean => const [
          Color(0xFF4FACFE),
          Color(0xFF6A11CB),
          Color(0xFF00C6FF),
          Color(0xFF7F7FD5),
        ],
      BorderBeamColorVariant.sunset => const [
          Color(0xFFFFB86C),
          Color(0xFFFF5E62),
          Color(0xFFFF2E63),
          Color(0xFFFF9A3C),
        ],
    };
    if (!dark) return base;
    return [for (final c in base) c.withValues(alpha: c.a * 0.92)];
  }

  @override
  bool shouldRepaint(covariant _BeamPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.variant != variant ||
        oldDelegate.dark != dark ||
        oldDelegate.time != time ||
        oldDelegate.opacity != opacity ||
        oldDelegate.radius != radius ||
        oldDelegate.staticColors != staticColors ||
        oldDelegate.spec != spec;
  }
}



