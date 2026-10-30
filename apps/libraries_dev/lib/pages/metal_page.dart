import 'package:flutter/material.dart';
import 'package:metal_fx/metal_fx.dart';
import 'package:ui_kit/ui_kit.dart';

import '../site/site_shell.dart';

class MetalPage extends StatefulWidget {
  const MetalPage({super.key});

  @override
  State<MetalPage> createState() => _MetalPageState();
}

class _MetalPageState extends State<MetalPage> {
  String _tab = 'preview';
  String _platform = 'react';

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/metal',
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
            const _MetalPreview()
          else
            _MetalInstall(platform: _platform),
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
          child: Image.asset('assets/site/icons/tile-metal.png'),
        ),
        const SizedBox(height: 16),
        Text('Liquid metal', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 5),
        Text(
          'Liquid metal for buttons, icons, text and badges, with reflections.',
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

class _MetalPreview extends StatelessWidget {
  const _MetalPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 3 : 1;
            final examples = [
              const _MetalExample(
                label: 'Chrome button',
                preset: MetalFxPreset.silver,
                child: Text(
                  'Get started',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF141414),
                  ),
                ),
              ),
              _MetalExample(
                label: 'Gold circle',
                preset: MetalFxPreset.gold,
                circle: true,
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF141414),
                ),
              ),
              const _MetalExample(
                label: 'Chromatic badge',
                preset: MetalFxPreset.chromatic,
                child: Text(
                  'Pro',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF141414),
                  ),
                ),
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
        const _MetalPlayground(),
      ],
    );
  }
}

class _MetalExample extends StatelessWidget {
  const _MetalExample({
    required this.label,
    required this.preset,
    required this.child,
    this.circle = false,
  });

  final String label;
  final MetalFxPreset preset;
  final Widget child;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: Column(
        children: [
          const Spacer(),
          MetalFx(
            preset: preset,
            variant: circle ? MetalFxVariant.circle : MetalFxVariant.button,
            borderRadius: circle ? null : 50,
            child: child,
          ),
          const Spacer(),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _MetalPlayground extends StatefulWidget {
  const _MetalPlayground();

  @override
  State<_MetalPlayground> createState() => _MetalPlaygroundState();
}

class _MetalPlaygroundState extends State<_MetalPlayground> {
  MetalFxPreset _preset = MetalFxPreset.silver;
  MetalFxVariant _variant = MetalFxVariant.button;
  double _strength = 1;
  bool _paused = false;

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
        child: MetalFx(
          preset: _preset,
          variant: _variant,
          strength: _strength,
          paused: _paused,
          borderRadius: 50,
          child: Text(
            _variant == MetalFxVariant.circle ? 'M' : 'Liquid metal',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF141414),
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
          const SectionLabel('Preset'),
          const SizedBox(height: 8),
          PillTabs<MetalFxPreset>(
            options: const [
              PillOption(MetalFxPreset.silver, 'Silver'),
              PillOption(MetalFxPreset.gold, 'Gold'),
              PillOption(MetalFxPreset.chromatic, 'Chromatic'),
            ],
            value: _preset,
            compact: true,
            onChanged: (value) => setState(() => _preset = value),
          ),
          const SizedBox(height: 14),
          const SectionLabel('Variant'),
          const SizedBox(height: 8),
          PillTabs<MetalFxVariant>(
            options: const [
              PillOption(MetalFxVariant.button, 'Button'),
              PillOption(MetalFxVariant.circle, 'Circle'),
            ],
            value: _variant,
            compact: true,
            onChanged: (value) => setState(() => _variant = value),
          ),
          const SizedBox(height: 14),
          const SectionLabel('Strength'),
          const SizedBox(height: 8),
          Slider(
            min: 0,
            max: 1,
            value: _strength,
            onChanged: (value) => setState(() => _strength = value),
          ),
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
              "import { MetalFx } from 'metal-fx';\n\n<MetalFx preset=\"silver\">\n  <button>Get started</button>\n</MetalFx>",
        ),
      ],
    );
  }
}

class _MetalInstall extends StatelessWidget {
  const _MetalInstall({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    final install = switch (platform) {
      'rn' => 'npm install metal-fx-native @shopify/react-native-skia react-native-reanimated',
      'swift' => '// Add MetalFxKit from the Libraries.dev repository with Swift Package Manager.',
      _ => 'npm install metal-fx',
    };
    final usage = switch (platform) {
      'rn' =>
        "import { MetalFx } from 'metal-fx-native';\n\n<MetalFx preset=\"silver\"><Button /></MetalFx>",
      'swift' =>
        'import MetalFxKit\n\nMetalFx(preset: .silver) {\n  Button()\n}',
      _ =>
        "import { MetalFx } from 'metal-fx';\n\n<MetalFx preset=\"silver\">\n  <button>Get started</button>\n</MetalFx>",
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
