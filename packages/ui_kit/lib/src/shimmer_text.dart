import 'package:flutter/material.dart';

import 'palette.dart';

class ShimmerText extends StatefulWidget {
  const ShimmerText(
    this.text, {
    super.key,
    this.style,
    this.duration = const Duration(seconds: 2),
    this.active = true,
  });

  final String text;
  final TextStyle? style;
  final Duration duration;
  final bool active;

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant ShimmerText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _controller.repeat();
    } else if (!widget.active && oldWidget.active) {
      _controller.stop();
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
        Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: SiteColors.text,
            );
    if (!widget.active) return Text(widget.text, style: style);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            final slide = _controller.value * 2.4 - 1.2;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFBDBDBD),
                Color(0xFFFFFFFF),
                Color(0xFFBDBDBD),
              ],
              stops: [
                (slide - 0.15).clamp(0.0, 1.0),
                slide.clamp(0.0, 1.0),
                (slide + 0.15).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Text(widget.text, style: style),
    );
  }
}
