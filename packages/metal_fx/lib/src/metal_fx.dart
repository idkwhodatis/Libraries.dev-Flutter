import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'types.dart';

class MetalFx extends StatefulWidget {
  const MetalFx({
    super.key,
    required this.child,
    this.variant = MetalFxVariant.button,
    this.preset = MetalFxPreset.silver,
    this.theme = MetalFxTheme.auto,
    this.strength = 1,
    this.paused = false,
    this.borderRadius,
  });

  final Widget child;
  final MetalFxVariant variant;
  final MetalFxPreset preset;
  final MetalFxTheme theme;
  final double strength;
  final bool paused;
  final double? borderRadius;

  @override
  State<MetalFx> createState() => _MetalFxState();
}

class _MetalFxState extends State<MetalFx>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ui.FragmentProgram? _program;
  bool _reduced = false;
  Offset? _pointer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );
    _sync();
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      ui.FragmentProgram.fromAsset(
        'packages/metal_fx/shaders/metal.frag',
      ).then((program) {
        if (mounted) setState(() => _program = program);
      }).catchError((_) {});
    }
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
  void didUpdateWidget(covariant MetalFx oldWidget) {
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
    final dark = switch (widget.theme) {
      MetalFxTheme.dark => true,
      MetalFxTheme.light => false,
      MetalFxTheme.auto =>
        Theme.of(context).brightness == Brightness.dark,
    };
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final time = _reduced || widget.paused ? 0.28 : _controller.value;
        final shader = _program;
        final painter = shader == null
            ? _MetalPainter(
                variant: widget.variant,
                preset: widget.preset,
                dark: dark,
                time: time,
                strength: widget.strength.clamp(0.0, 1.0),
                radius: widget.borderRadius,
              )
            : _MetalShaderPainter(
                program: shader,
                preset: widget.preset,
                time: time,
                strength: widget.strength.clamp(0.0, 1.0),
                pointer: _pointer,
              );
        final child = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: widget.child,
        );
        final content = MouseRegion(
          onHover: (event) => setState(() => _pointer = event.localPosition),
          onExit: (_) => setState(() => _pointer = null),
          child: CustomPaint(painter: painter, child: child),
        );
        return widget.variant == MetalFxVariant.circle
            ? ClipOval(child: content)
            : ClipRRect(
                borderRadius: BorderRadius.circular(
                  widget.borderRadius ?? 24,
                ),
                child: content,
              );
      },
    );
  }
}

class MetalText extends StatefulWidget {
  const MetalText(
    this.text, {
    super.key,
    this.preset = MetalFxPreset.silver,
    this.style,
    this.paused = false,
  });

  final String text;
  final MetalFxPreset preset;
  final TextStyle? style;
  final bool paused;

  @override
  State<MetalText> createState() => _MetalTextState();
}

class _MetalTextState extends State<MetalText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 6000),
  );
  ui.FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    if (!widget.paused) _controller.repeat();
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      ui.FragmentProgram.fromAsset(
        'packages/metal_fx/shaders/metal.frag',
      ).then((program) {
        if (mounted) setState(() => _program = program);
      }).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ??
        Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            );
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            final program = _program;
            if (program != null) {
              final shader = program.fragmentShader();
              shader
                ..setFloat(0, bounds.width)
                ..setFloat(1, bounds.height)
                ..setFloat(2, _controller.value)
                ..setFloat(3, 1)
                ..setFloat(4, _presetIndex)
                ..setFloat(5, 0)
                ..setFloat(6, 0)
                ..setFloat(7, 0);
              return shader;
            }
            return SweepGradient(
              colors: _palette(widget.preset, true),
              transform: GradientRotation(_controller.value * math.pi * 2),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Text(widget.text, style: style),
    );
  }

  double get _presetIndex => switch (widget.preset) {
        MetalFxPreset.silver => 0,
        MetalFxPreset.gold => 1,
        MetalFxPreset.chromatic => 2,
      };
}

class MetalBadge extends StatelessWidget {
  const MetalBadge(
    this.label, {
    super.key,
    this.preset = MetalFxPreset.silver,
  });

  final String label;
  final MetalFxPreset preset;

  @override
  Widget build(BuildContext context) {
    return MetalFx(
      preset: preset,
      borderRadius: 50,
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF141414),
        ),
      ),
    );
  }
}

class _MetalShaderPainter extends CustomPainter {
  _MetalShaderPainter({
    required this.program,
    required this.preset,
    required this.time,
    required this.strength,
    this.pointer,
  });

  final ui.FragmentProgram program;
  final MetalFxPreset preset;
  final double time;
  final double strength;
  final Offset? pointer;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, strength)
      ..setFloat(4, _presetIndex)
      ..setFloat(5, (pointer?.dx ?? 0) / math.max(size.width, 1))
      ..setFloat(6, (pointer?.dy ?? 0) / math.max(size.height, 1))
      ..setFloat(7, pointer == null ? 0 : 1);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  double get _presetIndex {
    return switch (preset) {
      MetalFxPreset.silver => 0,
      MetalFxPreset.gold => 1,
      MetalFxPreset.chromatic => 2,
    };
  }

  @override
  bool shouldRepaint(covariant _MetalShaderPainter oldDelegate) {
    return oldDelegate.program != program ||
        oldDelegate.preset != preset ||
        oldDelegate.time != time ||
        oldDelegate.strength != strength ||
        oldDelegate.pointer != pointer;
  }
}

class _MetalPainter extends CustomPainter {
  _MetalPainter({
    required this.variant,
    required this.preset,
    required this.dark,
    required this.time,
    required this.strength,
    required this.radius,
  });

  final MetalFxVariant variant;
  final MetalFxPreset preset;
  final bool dark;
  final double time;
  final double strength;
  final double? radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(
        variant == MetalFxVariant.circle
            ? size.shortestSide / 2
            : (radius ?? 24),
      ),
    );
    final colors = _palette(preset, dark);
    final shader = SweepGradient(
      colors: colors,
      transform: GradientRotation(time * math.pi * 2),
    ).createShader(rect);
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = shader
        ..color = Colors.white.withValues(alpha: strength),
    );

    final sheen = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.5 * strength),
        Colors.white.withValues(alpha: 0.04 * strength),
        Colors.white.withValues(alpha: 0.28 * strength),
        Colors.transparent,
      ],
      stops: const [0, 0.35, 0.62, 1],
    ).createShader(rect);
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = sheen
        ..blendMode = BlendMode.overlay,
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.4 * strength),
    );

    final shade = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..color = Colors.black.withValues(alpha: 0.22 * strength);
    canvas.drawRRect(rrect.deflate(2), shade);
  }

  @override
  bool shouldRepaint(covariant _MetalPainter oldDelegate) {
    return oldDelegate.variant != variant ||
        oldDelegate.preset != preset ||
        oldDelegate.dark != dark ||
        oldDelegate.time != time ||
        oldDelegate.strength != strength ||
        oldDelegate.radius != radius;
  }
}

List<Color> _palette(MetalFxPreset preset, bool dark) {
  return switch (preset) {
    MetalFxPreset.silver => const [
        Color(0xFF737A86),
        Color(0xFFF7F9FC),
        Color(0xFFBEC6D2),
        Color(0xFF5C6470),
        Color(0xFFE7EDF5),
        Color(0xFF939CAA),
        Color(0xFF737A86),
      ],
    MetalFxPreset.gold => const [
        Color(0xFF8A5A18),
        Color(0xFFFFE39A),
        Color(0xFFC98A2B),
        Color(0xFF6E430C),
        Color(0xFFFFF2C4),
        Color(0xFFA96B1A),
        Color(0xFF8A5A18),
      ],
    MetalFxPreset.chromatic => const [
        Color(0xFF54E6FF),
        Color(0xFFFF64D8),
        Color(0xFF7C5CFF),
        Color(0xFF55FFA7),
        Color(0xFFFFD166),
        Color(0xFF54E6FF),
      ],
  };
}



