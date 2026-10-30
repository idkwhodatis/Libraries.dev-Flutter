import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'types.dart';

class MagneticSurface extends StatefulWidget {
  const MagneticSurface({
    super.key,
    required this.child,
    this.strength = 0.18,
    this.reach = 220,
    this.axis = MagneticAxis.both,
    this.borderRadius = 20,
    this.onTap,
  });

  final Widget child;
  final double strength;
  final double reach;
  final MagneticAxis axis;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  State<MagneticSurface> createState() => _MagneticSurfaceState();
}

class _MagneticSurfaceState extends State<MagneticSurface> {
  Offset _offset = Offset.zero;

  void _onHover(PointerEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final center = box.size.center(Offset.zero);
    final delta = event.localPosition - center;
    final distance = delta.distance;
    if (distance > widget.reach) {
      if (_offset != Offset.zero) setState(() => _offset = Offset.zero);
      return;
    }
    final pull = (1 - distance / widget.reach).clamp(0.0, 1.0);
    final dx = widget.axis == MagneticAxis.vertical ? 0.0 : delta.dx;
    final dy = widget.axis == MagneticAxis.horizontal ? 0.0 : delta.dy;
    final target = Offset(
      dx * widget.strength * pull,
      dy * widget.strength * pull,
    );
    if ((target - _offset).distance > 0.2) {
      setState(() => _offset = target);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      onExit: (_) {
        if (_offset != Offset.zero) setState(() => _offset = Offset.zero);
      },
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: TweenAnimationBuilder<Offset>(
          tween: Tween<Offset>(begin: Offset.zero, end: _offset),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: value,
              child: Transform.rotate(
                angle: value.dx / math.max(1, widget.reach) * 0.12,
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
