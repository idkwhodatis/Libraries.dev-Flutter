import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'types.dart';

class ImageGeneration extends StatefulWidget {
  const ImageGeneration({
    super.key,
    required this.images,
    this.preset = ImageGenerationPreset.organic,
    this.theme = ImageGenerationTheme.auto,
    this.strength = 1,
    this.speed = 1,
    this.borderRadius = 20,
    this.paused = false,
    this.autoReveal = true,
    this.onCycle,
  });

  final List<String> images;
  final ImageGenerationPreset preset;
  final ImageGenerationTheme theme;
  final double strength;
  final double speed;
  final double borderRadius;
  final bool paused;
  final bool autoReveal;
  final ValueChanged<int>? onCycle;

  @override
  State<ImageGeneration> createState() => _ImageGenerationState();
}

class _ImageGenerationState extends State<ImageGeneration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ui.Image? _image;
  List<Color>? _pixels;
  int _index = 0;
  Timer? _timer;
  bool _loading = false;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _sync();
    _load();
    if (widget.autoReveal) _scheduleCycle();
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
  void didUpdateWidget(covariant ImageGeneration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paused != widget.paused ||
        oldWidget.autoReveal != widget.autoReveal) {
      _sync();
      _scheduleCycle();
    }
    if (oldWidget.images != widget.images) {
      _index = 0;
      _load();
    }
  }

  void _sync() {
    if (widget.paused || _reduced) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  void _scheduleCycle() {
    _timer?.cancel();
    if (!widget.autoReveal || widget.images.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted || widget.paused) return;
      setState(() {
        _index = (_index + 1) % widget.images.length;
      });
      widget.onCycle?.call(_index);
      _load();
      _controller.forward(from: 0);
    });
  }

  Future<void> _load() async {
    if (_loading || widget.images.isEmpty) return;
    _loading = true;
    final path = widget.images[_index % widget.images.length];
    try {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final bytes = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (!mounted) return;
      setState(() {
        _image = image;
        _pixels = bytes == null ? null : _sample(image, bytes);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _image = null;
          _pixels = null;
        });
      }
    } finally {
      _loading = false;
    }
  }

  List<Color> _sample(ui.Image image, ByteData bytes) {
    const cols = 28;
    const rows = 34;
    final colors = <Color>[];
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        final px = ((x + 0.5) / cols * image.width)
            .clamp(0, image.width - 1)
            .floor();
        final py = ((y + 0.5) / rows * image.height)
            .clamp(0, image.height - 1)
            .floor();
        final offset = (py * image.width + px) * 4;
        colors.add(Color.fromARGB(
          bytes.getUint8(offset + 3),
          bytes.getUint8(offset),
          bytes.getUint8(offset + 1),
          bytes.getUint8(offset + 2),
        ));
      }
    }
    return colors;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    final pixels = _pixels;
    if (image == null || pixels == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: const ColoredBox(
          color: Color(0xFF171717),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final progress = _reduced || widget.paused
              ? 1.0
              : Curves.easeOutCubic.transform(
                  (_controller.value * widget.speed).clamp(0.0, 1.0),
                );
          return CustomPaint(
            painter: _MosaicPainter(
              image: image,
              pixels: pixels,
              progress: progress,
              strength: widget.strength.clamp(0.0, 1.0),
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

class _MosaicPainter extends CustomPainter {
  _MosaicPainter({
    required this.image,
    required this.pixels,
    required this.progress,
    required this.strength,
  });

  final ui.Image image;
  final List<Color> pixels;
  final double progress;
  final double strength;

  static const _cols = 28;
  static const _rows = 34;

  @override
  void paint(Canvas canvas, Size size) {
    final fitted = applyBoxFit(
      BoxFit.cover,
      Size(image.width.toDouble(), image.height.toDouble()),
      size,
    );
    final src = Alignment.center.inscribe(
      fitted.source,
      Offset.zero & Size(image.width.toDouble(), image.height.toDouble()),
    );
    final dst = Alignment.center.inscribe(fitted.destination, Offset.zero & size);
    canvas.drawImageRect(image, src, dst, Paint());

    final cellW = size.width / _cols;
    final cellH = size.height / _rows;
    for (var y = 0; y < _rows; y++) {
      for (var x = 0; x < _cols; x++) {
        final threshold = (x / _cols * 0.62 + y / _rows * 0.38);
        final reveal = ((progress * 2.1) - threshold).clamp(0.0, 1.0);
        final alpha = (1 - reveal) * strength;
        if (alpha <= 0.01) continue;
        final color = pixels[y * _cols + x];
        final rect = Rect.fromLTWH(
          x * cellW,
          y * cellH,
          cellW.ceilToDouble(),
          cellH.ceilToDouble(),
        ).deflate(0.6);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
          Paint()..color = color.withValues(alpha: alpha),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MosaicPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.progress != progress ||
        oldDelegate.strength != strength;
  }
}


