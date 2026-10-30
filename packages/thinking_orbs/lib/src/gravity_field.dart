import 'package:flutter/material.dart';

import 'thinking_orb.dart';
import 'types.dart';

class OrbGravityField extends StatefulWidget {
  const OrbGravityField({
    super.key,
    required this.state,
    required this.size,
    required this.displaySize,
    this.speed = 1,
    this.dots = 1,
    this.dotSize = 1,
    this.color,
    this.paused = false,
    this.enabled = false,
  });

  final OrbState state;
  final int size;
  final double displaySize;
  final double speed;
  final double dots;
  final double dotSize;
  final String? color;
  final bool paused;
  final bool enabled;

  @override
  State<OrbGravityField> createState() => _OrbGravityFieldState();
}

class _OrbGravityFieldState extends State<OrbGravityField> {
  Offset? _pointer;
  Size _size = Size.zero;

  bool get _desktop {
    return switch (Theme.of(context).platform) {
      TargetPlatform.windows || TargetPlatform.macOS || TargetPlatform.linux =>
        true,
      _ => false,
    };
  }

  Offset get _center => Offset(_size.width / 2, _size.height / 2);

  bool get _active {
    final pointer = _pointer;
    if (!widget.enabled || !_desktop || pointer == null) return false;
    return (pointer - _center).distance <= 160;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        return Stack(
          children: [
            Center(
              child: ThinkingOrb(
                state: widget.state,
                size: widget.size,
                displaySize: widget.displaySize,
                speed: widget.speed,
                dots: widget.dots,
                dotSize: widget.dotSize,
                color: widget.color,
                paused: widget.paused,
              ),
            ),
            Positioned.fill(
              child: MouseRegion(
                opaque: false,
                cursor: _active
                    ? SystemMouseCursors.none
                    : SystemMouseCursors.basic,
                onHover: (event) {
                  if (!widget.enabled || !_desktop) return;
                  setState(() => _pointer = event.localPosition);
                },
                onExit: (_) {
                  if (_pointer != null) setState(() => _pointer = null);
                },
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GravityCursorPainter(
                      pointer: _pointer,
                      center: _center,
                      active: _active,
                      reach: 160,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GravityCursorPainter extends CustomPainter {
  _GravityCursorPainter({
    required this.pointer,
    required this.center,
    required this.active,
    required this.reach,
  });

  final Offset? pointer;
  final Offset center;
  final bool active;
  final double reach;

  @override
  void paint(Canvas canvas, Size size) {
    final point = pointer;
    if (!active || point == null) return;
    final delta = center - point;
    final distance = delta.distance;
    final pull = (1 - distance / reach).clamp(0.0, 1.0);
    final direction = distance == 0
        ? const Offset(0, 1)
        : delta / distance;
    final bend = direction * (pull * 10);

    final path = Path()
      ..moveTo(point.dx, point.dy)
      ..lineTo(point.dx - 4 + bend.dx * 0.2, point.dy + 15 + bend.dy * 0.2)
      ..lineTo(point.dx + 7 + bend.dx * 0.5, point.dy + 11 + bend.dy * 0.5)
      ..lineTo(point.dx + 16 + bend.dx, point.dy + 17 + bend.dy)
      ..close();

    final fill = Paint()..color = const Color(0xFFFFFFFF);
    final outline = Paint()
      ..color = const Color(0x66000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawShadow(path, const Color(0xAA000000), 6, false);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, outline);

    final tail = Paint()
      ..color = const Color(0x88FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 + pull * 2);
    final tailStart = point + const Offset(2, 14) + bend * 0.4;
    final tailEnd = point + bend * 1.4 + direction * (pull * 18);
    final tailPath = Path()
      ..moveTo(tailStart.dx, tailStart.dy)
      ..quadraticBezierTo(
        (tailStart.dx + tailEnd.dx) / 2 + direction.dy * 8,
        (tailStart.dy + tailEnd.dy) / 2 - direction.dx * 8,
        tailEnd.dx,
        tailEnd.dy,
      );
    canvas.drawPath(tailPath, tail);

    final glow = Paint()
      ..color = const Color(0x22FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(point, 10 + pull * 8, glow);
  }

  @override
  bool shouldRepaint(covariant _GravityCursorPainter oldDelegate) {
    return oldDelegate.pointer != pointer ||
        oldDelegate.center != center ||
        oldDelegate.active != active ||
        oldDelegate.reach != reach;
  }
}
