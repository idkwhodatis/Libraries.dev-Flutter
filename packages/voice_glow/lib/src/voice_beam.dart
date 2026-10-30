import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'types.dart';

class VoiceBeam extends StatefulWidget {
  const VoiceBeam({
    super.key,
    this.child,
    this.type = VoiceBeamType.defaultBeam,
    this.level = 0.45,
    this.colorVariant = VoiceBeamColorVariant.colorful,
    this.theme = VoiceBeamTheme.auto,
    this.active = true,
    this.paused = false,
    this.borderRadius = 24,
    this.sensitivity = 1,
  });

  final Widget? child;
  final VoiceBeamType type;
  final double level;
  final VoiceBeamColorVariant colorVariant;
  final VoiceBeamTheme theme;
  final bool active;
  final bool paused;
  final double borderRadius;
  final double sensitivity;

  @override
  State<VoiceBeam> createState() => _VoiceBeamState();
}

class _VoiceBeamState extends State<VoiceBeam>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
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
  void didUpdateWidget(covariant VoiceBeam oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paused != widget.paused ||
        oldWidget.active != widget.active) {
      _sync();
    }
  }

  void _sync() {
    if (widget.paused || !widget.active || _reduced) {
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
      VoiceBeamTheme.dark => true,
      VoiceBeamTheme.light => false,
      VoiceBeamTheme.auto =>
        Theme.of(context).brightness == Brightness.dark,
    };
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final time = _reduced || widget.paused ? 0.35 : _controller.value;
        return CustomPaint(
          painter: _VoicePainter(
            type: widget.type,
            level: (widget.level * widget.sensitivity).clamp(0.0, 1.0),
            variant: widget.colorVariant,
            dark: dark,
            time: time,
            active: widget.active,
            radius: widget.borderRadius,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _VoicePainter extends CustomPainter {
  _VoicePainter({
    required this.type,
    required this.level,
    required this.variant,
    required this.dark,
    required this.time,
    required this.active,
    required this.radius,
  });

  final VoiceBeamType type;
  final double level;
  final VoiceBeamColorVariant variant;
  final bool dark;
  final double time;
  final bool active;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final colors = _palette(variant, dark);
    final phase = time * math.pi * 2;
    final breathe = 0.5 + 0.5 * math.sin(phase);
    final intensity = active ? (0.28 + level * 0.72) : 0.12;
    final body = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    canvas.save();
    canvas.clipRRect(body);

    // Soft stacked lobes rising from the bottom edge.
    for (var i = 0; i < 7; i++) {
      final f = i / 6;
      final w = size.width * (0.42 + f * 0.62);
      final h = size.height * (0.12 + intensity * 0.42 + f * 0.045);
      final center = Offset(
        size.width * (0.5 + math.sin(phase + i * 0.7) * 0.06),
        size.height + h * 0.35,
      );
      final color = colors[i % colors.length]
          .withValues(alpha: (0.16 - f * 0.015) * intensity);
      canvas.drawOval(
        Rect.fromCenter(center: center, width: w, height: h * 2),
        Paint()
          ..color = color
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            18 + f * 8 + breathe * 6,
          ),
      );
    }

    // The band follows the voice level.
    final bandY =
        size.height * (0.78 - intensity * 0.38 + math.sin(phase) * 0.012);
    final path = Path();
    for (var i = 0; i <= 96; i++) {
      final x = size.width * i / 96;
      final taper = math.sin(math.pi * i / 96);
      final y = bandY +
          math.sin(i * 0.18 + phase * 1.8) *
              size.height *
              0.018 *
              intensity *
              taper;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    final bandPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 + intensity * 2.2
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [
          colors[0].withValues(alpha: 0.1 * intensity),
          colors[1 % colors.length].withValues(alpha: 0.95 * intensity),
          colors[2 % colors.length].withValues(alpha: 0.75 * intensity),
          colors[0].withValues(alpha: 0.1 * intensity),
        ],
      ).createShader(Offset.zero & size)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);
    canvas.drawPath(path, bandPaint);

    final bloom = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = colors[1 % colors.length].withValues(alpha: 0.12 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawPath(path, bloom);

    // A clean edge and a faint inner wash keep the surface readable.
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = colors.first.withValues(alpha: 0.25 * intensity),
    );
    canvas.restore();

    if (type == VoiceBeamType.mobile) {
      final notch = Paint()..color = const Color(0xFF070707);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height * 0.06),
            width: size.width * 0.28,
            height: size.height * 0.025,
          ),
          const Radius.circular(20),
        ),
        notch,
      );
    }
  }

  List<Color> _palette(VoiceBeamColorVariant variant, bool dark) {
    final colors = switch (variant) {
      VoiceBeamColorVariant.colorful => const [
          Color(0xFF6C5CE7),
          Color(0xFF00D2FF),
          Color(0xFFFF5E9E),
          Color(0xFFFFD166),
          Color(0xFF00FFB2),
        ],
      VoiceBeamColorVariant.mono => const [
          Color(0xFFFFFFFF),
          Color(0xFFCCCCCC),
          Color(0xFF8A8A8A),
        ],
      VoiceBeamColorVariant.ocean => const [
          Color(0xFF4FACFE),
          Color(0xFF00C6FF),
          Color(0xFF6A11CB),
          Color(0xFF2575FC),
        ],
      VoiceBeamColorVariant.sunset => const [
          Color(0xFFFF9A3C),
          Color(0xFFFF5E62),
          Color(0xFFFF2E63),
          Color(0xFFFFB86C),
        ],
      VoiceBeamColorVariant.mint => const [
          Color(0xFF9FE8A8),
          Color(0xFF4ADE80),
          Color(0xFF22D3EE),
          Color(0xFFB8F5D0),
        ],
    };
    return dark ? colors : [for (final c in colors) c.withValues(alpha: 0.8)];
  }

  @override
  bool shouldRepaint(covariant _VoicePainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.level != level ||
        oldDelegate.variant != variant ||
        oldDelegate.dark != dark ||
        oldDelegate.time != time ||
        oldDelegate.active != active ||
        oldDelegate.radius != radius;
  }
}
