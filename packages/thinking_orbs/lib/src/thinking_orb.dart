import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'core.dart';
import 'orb_clock.dart';
import 'presets.dart';
import 'profiles.dart';
import 'registry.dart';
import 'spec.g.dart';
import 'types.dart';

@visibleForTesting
int debugOrbCappedRasterCount = 0;

class ThinkingOrb extends StatefulWidget {
  const ThinkingOrb({
    super.key,
    this.state = OrbState.working,
    this.size = 64,
    this.theme = OrbTheme.auto,
    this.speed = 1,
    this.paused = false,
    this.color,
    this.dots = 1,
    this.dotSize = 1,
    this.opts,
    this.gravity = false,
    this.displaySize,
    this.semanticLabel,
    this.debugTime,
  });

  final OrbState state;
  final int size;
  final OrbTheme theme;
  final double speed;
  final bool paused;
  final String? color;
  final double dots;
  final double dotSize;
  final ModeOpts? opts;
  final bool gravity;
  final double? displaySize;
  final String? semanticLabel;

  /// Freezes geometry time for parity captures and tests.
  final double? debugTime;

  @override
  State<ThinkingOrb> createState() => _ThinkingOrbState();
}

class _ThinkingOrbState extends State<ThinkingOrb> {
  late ResolvedOrbPreset _preset;
  late ModeFrame _frame;
  late ModeOpts _opts;
  OrbTint? _tint;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);
  bool _visible = true;
  bool _clockAttached = false;
  bool _reducedMotion = false;
  late double _pausedTime;

  @override
  void initState() {
    super.initState();
    _refreshPreset();
    _pausedTime = OrbClock.instance.elapsedSeconds * _effectiveSpeed;
  }

  @override
  void didUpdateWidget(covariant ThinkingOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state ||
        oldWidget.size != widget.size ||
        oldWidget.dots != widget.dots ||
        oldWidget.dotSize != widget.dotSize ||
        oldWidget.opts != widget.opts ||
        oldWidget.color != widget.color) {
      _refreshPreset();
    }
    if (oldWidget.paused != widget.paused) {
      if (widget.paused) {
        _pausedTime = OrbClock.instance.elapsedSeconds * _effectiveSpeed;
      }
      _syncClock();
    }
  }

  double get _effectiveSpeed => _preset.speed * widget.speed;

  void _refreshPreset() {
    _preset = resolvePreset(widget.state, widget.size);
    _frame = modeFrame(_preset.mode);
    var opts = Map<String, double>.of(_preset.opts);
    if (widget.dots != 1) {
      opts = scaleCounts(opts, math.max(0.1, widget.dots));
    }
    if (widget.dotSize != 1) {
      opts = scaleRadii(opts, math.max(0.1, widget.dotSize));
    }
    final overrides = widget.opts;
    if (overrides != null) opts = {...opts, ...overrides};
    _opts = opts;
    _tint = _parseTint(widget.color);
  }

  OrbTint? _parseTint(String? value) {
    if (value == null) return null;
    final hex = RegExp(r'^#([0-9a-f]{3}|[0-9a-f]{6})$', caseSensitive: false)
        .firstMatch(value.trim());
    if (hex != null) {
      var digits = hex.group(1)!;
      if (digits.length == 3) {
        digits = digits.split('').map((c) => '$c$c').join();
      }
      final number = int.parse(digits, radix: 16);
      return OrbTint(
        (number >> 16) & 255,
        (number >> 8) & 255,
        number & 255,
      );
    }
    final rgb = RegExp(r'^rgba?\(\s*([\d.]+)\s*,\s*([\d.]+)\s*,\s*([\d.]+)',
            caseSensitive: false)
        .firstMatch(value.trim());
    if (rgb != null) {
      return OrbTint(
        double.parse(rgb.group(1)!).round(),
        double.parse(rgb.group(2)!).round(),
        double.parse(rgb.group(3)!).round(),
      );
    }
    return null;
  }

  bool _resolveDark(BuildContext context) {
    switch (widget.theme) {
      case OrbTheme.dark:
        return true;
      case OrbTheme.light:
        return false;
      case OrbTheme.auto:
        return Theme.of(context).brightness == Brightness.dark;
    }
  }

  bool _resolveReducedMotion(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    if (media?.disableAnimations == true) return true;
    return WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations;
  }

  void _syncClock() {
    final shouldRun = !widget.paused && _visible && !_reducedMotion;
    if (shouldRun && !_clockAttached) {
      OrbClock.instance.add(_tick);
      _clockAttached = true;
    } else if (!shouldRun && _clockAttached) {
      OrbClock.instance.remove(_tick);
      _clockAttached = false;
    }
  }

  void _tick() {
    _repaint.value++;
  }

  @override
  void dispose() {
    if (_clockAttached) OrbClock.instance.remove(_tick);
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _reducedMotion = _resolveReducedMotion(context);
    _syncClock();
    final dark = _resolveDark(context);
    final display = widget.displaySize ?? widget.size.toDouble();
    final label = widget.semanticLabel ??
        kOrbSemanticLabels[widget.state.name] ??
        widget.state.name;
    final effectivePausedTime = widget.paused ? _pausedTime : 0.0;

    return VisibilityDetector(
      key: ValueKey<Object>(this),
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0;
        if (visible != _visible) {
          _visible = visible;
          _syncClock();
        }
      },
      child: RepaintBoundary(
        child: Semantics(
          image: true,
          label: label,
          child: SizedBox(
            width: display,
            height: display,
            child: CustomPaint(
              painter: _OrbPainter(
                frame: _frame,
                size: widget.size.toDouble(),
                displaySize: display,
                opts: _opts,
                dark: dark,
                tint: _tint,
                speed: _effectiveSpeed,
                paused: widget.paused,
                pausedTime: effectivePausedTime,
                reducedMotion: _reducedMotion,
                debugTime: widget.debugTime,
                devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                repaint: _repaint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.frame,
    required this.size,
    required this.displaySize,
    required this.opts,
    required this.dark,
    required this.tint,
    required this.speed,
    required this.paused,
    required this.pausedTime,
    required this.reducedMotion,
    required this.debugTime,
    required this.devicePixelRatio,
    required this.repaint,
  }) : super(repaint: repaint);

  final ModeFrame frame;
  final double size;
  final double displaySize;
  final ModeOpts opts;
  final bool dark;
  final OrbTint? tint;
  final double speed;
  final bool paused;
  final double pausedTime;
  final bool reducedMotion;
  final double? debugTime;
  final double devicePixelRatio;
  final ValueNotifier<int> repaint;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (devicePixelRatio > 2 && displaySize > 0) {
      try {
        _paintCapped(canvas);
        return;
      } catch (_) {}
    }
    _paint(canvas);
  }

  void _paintCapped(Canvas canvas) {
    final recorder = ui.PictureRecorder();
    final recorded = Canvas(recorder);
    recorded.scale(2);
    _paint(recorded);
    final picture = recorder.endRecording();
    late final ui.Image image;
    try {
      final pixels = (displaySize * 2).ceil();
      image = picture.toImageSync(pixels, pixels);
      debugOrbCappedRasterCount++;
    } finally {
      picture.dispose();
    }
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, displaySize, displaySize),
      Paint()..filterQuality = FilterQuality.medium,
    );
    image.dispose();
  }

  void _paint(Canvas canvas) {
    final t = debugTime ??
        (reducedMotion
            ? kOrbReducedMotionTime
            : paused
                ? pausedTime
                : OrbClock.instance.elapsedSeconds * speed);
    final scale = displaySize / size;
    canvas
      ..save()
      ..scale(scale);
    final orb = frame(size, t, opts);
    final linePaint = Paint()..style = PaintingStyle.stroke;
    for (final line in orb.lines) {
      final ink = inkFor(line.white, line.a ?? 1, dark, tint);
      linePaint
        ..color = Color.fromARGB(
          (ink.a.clamp(0.0, 1.0) * 255).round(),
          ink.r,
          ink.g,
          ink.b,
        )
        ..strokeWidth = line.w;
      canvas.drawLine(
        Offset(line.x1, line.y1),
        Offset(line.x2, line.y2),
        linePaint,
      );
    }
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (final dot in orb.dots) {
      final ink = inkFor(dot.white, dot.a ?? 1, dark, tint);
      dotPaint.color = Color.fromARGB(
        (ink.a.clamp(0.0, 1.0) * 255).round(),
        ink.r,
        ink.g,
        ink.b,
      );
      canvas.drawCircle(Offset(dot.x, dot.y), dot.r, dotPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) {
    return oldDelegate.frame != frame ||
        oldDelegate.size != size ||
        oldDelegate.displaySize != displaySize ||
        oldDelegate.opts != opts ||
        oldDelegate.dark != dark ||
        oldDelegate.tint != tint ||
        oldDelegate.speed != speed ||
        oldDelegate.paused != paused ||
        oldDelegate.pausedTime != pausedTime ||
        oldDelegate.reducedMotion != reducedMotion ||
        oldDelegate.debugTime != debugTime ||
        oldDelegate.devicePixelRatio != devicePixelRatio;
  }
}




