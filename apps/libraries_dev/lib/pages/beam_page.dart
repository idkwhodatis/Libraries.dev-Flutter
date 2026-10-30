import 'package:border_beam/border_beam.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../site/site_shell.dart';

class BeamPage extends StatefulWidget {
  const BeamPage({super.key});

  @override
  State<BeamPage> createState() => _BeamPageState();
}

class _BeamPageState extends State<BeamPage> {
  String _tab = 'preview';
  String _platform = 'react';

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/beam',
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
            const _BeamPreview()
          else
            _BeamInstall(platform: _platform),
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
          child: Image.asset('assets/site/icons/tile-beam.png'),
        ),
        const SizedBox(height: 16),
        Text(
          'Border beam',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 5),
        Text(
          'An animated beam of light that travels around a card, button or input.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
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
            PillButton(
              label: 'Tune in Studio',
              icon: const Icon(Icons.auto_awesome, size: 15),
              onTap: () => context.go('/studio/app'),
            ),
          ],
        ),
      ],
    );
  }
}

class _BeamPreview extends StatelessWidget {
  const _BeamPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 3 : 1;
            final cards = [
              _ExampleCard(
                title: 'Card',
                subtitle: 'Full border glow',
                size: BorderBeamSize.md,
                variant: BorderBeamColorVariant.colorful,
                child: const _CardBody(label: 'Your content here'),
              ),
              _ExampleCard(
                title: 'Icon button',
                subtitle: 'Compact glow',
                size: BorderBeamSize.sm,
                variant: BorderBeamColorVariant.ocean,
                child: const SizedBox(
                  width: 64,
                  height: 64,
                  child: Icon(Icons.auto_awesome, color: SiteColors.muted),
                ),
              ),
              _ExampleCard(
                title: 'Search',
                subtitle: 'Bottom-only beam',
                size: BorderBeamSize.line,
                variant: BorderBeamColorVariant.sunset,
                child: const _CardBody(label: 'Search anything...'),
              ),
            ];
            if (columns == 1) {
              return Column(
                children: [
                  for (final card in cards) ...[
                    card,
                    const SizedBox(height: 12),
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: cards[i]),
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
        const _BeamPlayground(),
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.subtitle,
    required this.size,
    required this.variant,
    required this.child,
  });

  final String title;
  final String subtitle;
  final BorderBeamSize size;
  final BorderBeamColorVariant variant;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: BorderBeam(
                size: size,
                colorVariant: variant,
                borderRadius: 16,
                child: child,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _BeamPlayground extends StatefulWidget {
  const _BeamPlayground();

  @override
  State<_BeamPlayground> createState() => _BeamPlaygroundState();
}

class _BeamPlaygroundState extends State<_BeamPlayground> {
  BorderBeamSize _size = BorderBeamSize.md;
  BorderBeamColorVariant _variant = BorderBeamColorVariant.colorful;
  BorderBeamTheme _theme = BorderBeamTheme.dark;
  double _strength = 1;
  bool _active = true;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 900;
    final stage = Container(
      height: 380,
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: Center(
        child: BorderBeam(
          size: _size,
          colorVariant: _variant,
          theme: _theme,
          strength: _strength,
          active: _active,
          borderRadius: 16,
          child: Container(
            width: 250,
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1D1D1D),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SiteColors.lineStrong),
            ),
            child: Text(
              'BorderBeam',
              style: Theme.of(context).textTheme.titleMedium,
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
          const SectionLabel('Type'),
          const SizedBox(height: 8),
          PillTabs<BorderBeamSize>(
            options: const [
              PillOption(BorderBeamSize.md, 'md'),
              PillOption(BorderBeamSize.sm, 'sm'),
              PillOption(BorderBeamSize.line, 'line'),
              PillOption(BorderBeamSize.pulseInner, 'pulse in'),
              PillOption(BorderBeamSize.pulseOutside, 'pulse out'),
            ],
            value: _size,
            compact: true,
            onChanged: (value) => setState(() => _size = value),
          ),
          const SizedBox(height: 14),
          const SectionLabel('Color'),
          const SizedBox(height: 8),
          PillTabs<BorderBeamColorVariant>(
            options: const [
              PillOption(BorderBeamColorVariant.colorful, 'Colorful'),
              PillOption(BorderBeamColorVariant.mono, 'Mono'),
              PillOption(BorderBeamColorVariant.ocean, 'Ocean'),
              PillOption(BorderBeamColorVariant.sunset, 'Sunset'),
            ],
            value: _variant,
            compact: true,
            onChanged: (value) => setState(() => _variant = value),
          ),
          const SizedBox(height: 14),
          const SectionLabel('Theme'),
          const SizedBox(height: 8),
          PillTabs<BorderBeamTheme>(
            options: const [
              PillOption(BorderBeamTheme.dark, 'Dark'),
              PillOption(BorderBeamTheme.light, 'Light'),
            ],
            value: _theme,
            compact: true,
            onChanged: (value) => setState(() => _theme = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Strength',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: SiteColors.muted,
                  ),
                ),
              ),
              Text(
                '${(_strength * 100).round()}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          Slider(
            min: 0,
            max: 1,
            value: _strength,
            onChanged: (value) => setState(() => _strength = value),
          ),
          PillButton(
            label: _active ? 'Pause' : 'Play',
            icon: Icon(
              _active ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 16,
            ),
            onTap: () => setState(() => _active = !_active),
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
              "import { BorderBeam } from 'border-beam';\n\n<BorderBeam size=\"md\" colorVariant=\"colorful\">\n  <Card />\n</BorderBeam>",
        ),
      ],
    );
  }
}

class _BeamInstall extends StatelessWidget {
  const _BeamInstall({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    final install = switch (platform) {
      'rn' => 'npm install border-beam-native @shopify/react-native-skia react-native-reanimated',
      'swift' => '// Add BorderBeamKit from the Libraries.dev repository with Swift Package Manager.',
      _ => 'npm install border-beam',
    };
    final usage = switch (platform) {
      'rn' =>
        "import { BorderBeam } from 'border-beam-native';\n\n<BorderBeam><Card /></BorderBeam>",
      'swift' =>
        'import BorderBeamKit\n\nBorderBeam(size: .md, colorVariant: .colorful) {\n  Card()\n}',
      _ =>
        "import { BorderBeam } from 'border-beam';\n\n<BorderBeam>\n  <Card />\n</BorderBeam>",
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
