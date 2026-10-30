import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:ui_kit/ui_kit.dart';

class OrbsCarouselPage extends StatefulWidget {
  const OrbsCarouselPage({super.key});

  @override
  State<OrbsCarouselPage> createState() => _OrbsCarouselPageState();
}

class _OrbsCarouselPageState extends State<OrbsCarouselPage> {
  static const _slides = <List<(OrbState, String)>>[
    [
      (OrbState.searching, 'Searching'),
      (OrbState.breathing, 'Thinking'),
      (OrbState.solving, 'Solving'),
      (OrbState.listening, 'Listening'),
    ],
    [
      (OrbState.connecting, 'Connecting'),
      (OrbState.weaving, 'Planning'),
      (OrbState.composing, 'Composing'),
      (OrbState.working, 'Working'),
    ],
  ];

  int _slide = 0;
  Timer? _timer;
  bool _reduced = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted || _reduced) return;
      setState(() => _slide = (_slide + 1) % _slides.length);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduced != _reduced) _reduced = reduced;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 0 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 481,
                child: OverflowBox(
                  alignment: compact ? Alignment.centerLeft : Alignment.center,
                  minWidth: 670,
                  maxWidth: 670,
                  child: Container(
                    width: 670,
                    height: 481,
                    decoration: const BoxDecoration(color: Color(0xFF070707)),
                    clipBehavior: Clip.antiAlias,
                    child: AnimatedSwitcher(
                      duration: _reduced
                          ? Duration.zero
                          : const Duration(milliseconds: 1100),
                      switchInCurve: const Cubic(0.22, 1, 0.36, 1),
                      switchOutCurve: const Cubic(0.22, 1, 0.36, 1),
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0.18, 0),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: _SlideStack(
                        key: ValueKey<int>(_slide),
                        items: _slides[_slide],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideStack extends StatelessWidget {
  const _SlideStack({super.key, required this.items});

  final List<(OrbState, String)> items;

  @override
  Widget build(BuildContext context) {
    const widths = [280.0, 280.0, 280.0, 280.0];
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            for (var i = 0; i < items.length; i++)
              Positioned(
                left:
                    constraints.maxWidth / 2 +
                    (i - 1.5) * 60 +
                    (i - 1.5) * (i - 1.5) -
                    widths[i] / 2,
                top: constraints.maxHeight / 2 - (i - 1.5) * 94 - 37,
                child: _CarouselPill(
                  state: items[i].$1,
                  label: items[i].$2,
                  active: false,
                  width: widths[i],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CarouselPill extends StatelessWidget {
  const _CarouselPill({
    required this.state,
    required this.label,
    required this.active,
    required this.width,
  });

  final OrbState state;
  final String label;
  final bool active;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 74,
      padding: const EdgeInsets.fromLTRB(16, 0, 26, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: active ? SiteColors.lineStrong : SiteColors.line,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThinkingOrb(state: state, size: 64, displaySize: 56),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              '$label...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: active ? SiteColors.text : SiteColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
