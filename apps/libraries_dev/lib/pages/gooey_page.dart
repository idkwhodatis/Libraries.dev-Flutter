import 'package:flutter/material.dart';
import 'package:liquid_gooey/liquid_gooey.dart';
import 'package:ui_kit/ui_kit.dart';

import '../site/site_shell.dart';

class GooeyPage extends StatefulWidget {
  const GooeyPage({super.key});

  @override
  State<GooeyPage> createState() => _GooeyPageState();
}

class _GooeyPageState extends State<GooeyPage> {
  String _tab = 'preview';
  String _platform = 'react';

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/gooey',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            tab: _tab,
            platform: _platform,
            onTab: (value) => setState(() => _tab = value),
            onPlatform: (value) => setState(() => _platform = value),
          ),
          const SizedBox(height: 24),
          if (_tab == 'preview')
            const _GooeyPreview()
          else
            _GooeyInstall(platform: _platform),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.tab,
    required this.platform,
    required this.onTab,
    required this.onPlatform,
  });

  final String tab;
  final String platform;
  final ValueChanged<String> onTab;
  final ValueChanged<String> onPlatform;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 26),
        Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SiteColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SiteColors.line),
          ),
          child: Image.asset('assets/site/icons/tile-gooey.png'),
        ),
        const SizedBox(height: 16),
        Text('Gooey', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 5),
        Text(
          'Pieces that merge like goo and morph like jelly while text stays crisp.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            PillTabs<String>(
              options: const [
                PillOption('preview', 'Preview'),
                PillOption('install', 'Install'),
              ],
              value: tab,
              onChanged: onTab,
            ),
            PillTabs<String>(
              options: const [
                PillOption('react', 'React'),
                PillOption('swift', 'SwiftUI'),
                PillOption('rn', 'React Native'),
              ],
              value: platform,
              onChanged: onPlatform,
            ),
          ],
        ),
      ],
    );
  }
}

class _GooeyPreview extends StatelessWidget {
  const _GooeyPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 2 : 1;
            final examples = [
              const _GooeyExample(
                label: 'Merge',
                fill: Color(0xFF9FE8A8),
                child: Text('Liquid'),
              ),
              const _GooeyExample(
                label: 'Morph',
                fill: Color(0xFF7CD4FF),
                child: Text('Gooey'),
              ),
            ];
            if (columns == 1) {
              return Column(
                children: [
                  for (final example in examples) ...[
                    example,
                    const SizedBox(height: 12),
                  ],
                ],
              );
            }
            return Row(
              children: [
                for (var i = 0; i < examples.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: examples[i]),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        Text(
          'Playground',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: SiteColors.subtle,
              ),
        ),
        const SizedBox(height: 12),
        const _GooeyPlayground(),
      ],
    );
  }
}

class _GooeyExample extends StatelessWidget {
  const _GooeyExample({
    required this.label,
    required this.fill,
    required this.child,
  });

  final String label;
  final Color fill;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: Column(
        children: [
          Expanded(
            child: Liquid(
              fill: fill,
              background: const Color(0xFF111111),
              borderRadius: 18,
              child: Center(
                child: Text(
                  child is Text ? (child as Text).data ?? '' : '',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101010),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _GooeyPlayground extends StatefulWidget {
  const _GooeyPlayground();

  @override
  State<_GooeyPlayground> createState() => _GooeyPlaygroundState();
}

class _GooeyPlaygroundState extends State<_GooeyPlayground> {
  double _blur = 6;
  double _contrast = 18;
  Color _fill = const Color(0xFF9FE8A8);
  bool _paused = false;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 900;
    final stage = Container(
      height: 380,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: Liquid(
        fill: _fill,
        background: const Color(0xFF111111),
        blur: _blur,
        contrast: _contrast,
        borderRadius: 20,
        paused: _paused,
        child: Center(
          child: Text(
            'Gooey',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF101010),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
    final controls = InsetSurface(
      color: SiteColors.panel,
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Blur'),
          Slider(
            min: 2,
            max: 14,
            value: _blur,
            onChanged: (value) => setState(() => _blur = value),
          ),
          const SectionLabel('Contrast'),
          Slider(
            min: 8,
            max: 26,
            value: _contrast,
            onChanged: (value) => setState(() => _contrast = value),
          ),
          const SectionLabel('Fill'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final color in const [
                Color(0xFF9FE8A8),
                Color(0xFF7CD4FF),
                Color(0xFFFFD28F),
                Color(0xFFFF9EC9),
              ])
                GestureDetector(
                  onTap: () => setState(() => _fill = color),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _fill == color
                            ? SiteColors.text
                            : SiteColors.lineStrong,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          PillButton(
            label: _paused ? 'Play' : 'Pause',
            icon: Icon(
              _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              size: 16,
            ),
            onTap: () => setState(() => _paused = !_paused),
          ),
        ],
      ),
    );
    return Column(
      children: [
        if (narrow)
          Column(children: [stage, const SizedBox(height: 12), controls])
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: stage),
              const SizedBox(width: 12),
              SizedBox(width: 300, child: controls),
            ],
          ),
        const SizedBox(height: 12),
        const CodeBlock(
          code:
              "import { Liquid } from 'liquid-gooey';\n\n<Liquid fill=\"#9fe8a8\">\n  <Liquid.Item>...</Liquid.Item>\n</Liquid>",
        ),
      ],
    );
  }
}

class _GooeyInstall extends StatelessWidget {
  const _GooeyInstall({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    final install = switch (platform) {
      'rn' => 'npm install liquid-gooey',
      'swift' => '// Liquid Gooey is web-first; no Swift package is published.',
      _ => 'npm install liquid-gooey',
    };
    final usage = switch (platform) {
      'rn' => "import { Liquid } from 'liquid-gooey';\n\n<Liquid><Liquid.Item /></Liquid>",
      'swift' => '// No native implementation yet.',
      _ =>
        "import { Liquid } from 'liquid-gooey';\n\n<Liquid>\n  <Liquid.Item>...</Liquid.Item>\n</Liquid>",
    };
    return InsetSurface(
      color: SiteColors.code,
      radius: 16,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Installation'),
          const SizedBox(height: 8),
          CodeBlock(code: install, dense: true),
          const SizedBox(height: 20),
          const SectionLabel('Usage'),
          const SizedBox(height: 8),
          CodeBlock(code: usage, dense: true),
        ],
      ),
    );
  }
}

