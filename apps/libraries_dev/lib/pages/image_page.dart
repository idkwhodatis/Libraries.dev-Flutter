import 'package:flutter/material.dart';
import 'package:img_fx/img_fx.dart';
import 'package:ui_kit/ui_kit.dart';

import '../site/site_shell.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  String _tab = 'preview';
  String _platform = 'react';

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/image',
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
            const _ImagePreview()
          else
            _ImageInstall(platform: _platform),
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
          child: Image.asset('assets/site/icons/tile-image.png'),
        ),
        const SizedBox(height: 16),
        Text(
          'Image generation',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 5),
        Text(
          'A pixel-mosaic loader that becomes the image it is revealing.',
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

class _ImagePreview extends StatelessWidget {
  const _ImagePreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 2 : 1;
            final examples = [
              const _ImageExample(
                label: 'Organic',
                preset: ImageGenerationPreset.organic,
                image: 'assets/site/images/gen-1.jpg',
              ),
              const _ImageExample(
                label: 'Mechanic',
                preset: ImageGenerationPreset.mechanic,
                image: 'assets/site/images/gen-2.jpg',
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
        const _ImagePlayground(),
      ],
    );
  }
}

class _ImageExample extends StatelessWidget {
  const _ImageExample({
    required this.label,
    required this.preset,
    required this.image,
  });

  final String label;
  final ImageGenerationPreset preset;
  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: Column(
        children: [
          Expanded(
            child: ImageGeneration(
              images: [image],
              preset: preset,
              borderRadius: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ImagePlayground extends StatefulWidget {
  const _ImagePlayground();

  @override
  State<_ImagePlayground> createState() => _ImagePlaygroundState();
}

class _ImagePlaygroundState extends State<_ImagePlayground> {
  ImageGenerationPreset _preset = ImageGenerationPreset.organic;
  double _strength = 1;
  bool _paused = false;
  int _cycle = 0;

  static const _images = [
    'assets/site/images/gen-1.jpg',
    'assets/site/images/gen-2.jpg',
    'assets/site/images/gen-3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 900;
    final stage = Container(
      height: 420,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: ImageGeneration(
        key: ValueKey(_cycle),
        images: _images,
        preset: _preset,
        strength: _strength,
        paused: _paused,
        borderRadius: 14,
        onCycle: (_) => setState(() {}),
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
          PillTabs<ImageGenerationPreset>(
            options: const [
              PillOption(ImageGenerationPreset.organic, 'Organic'),
              PillOption(ImageGenerationPreset.mechanic, 'Mechanic'),
              PillOption(ImageGenerationPreset.sweep, 'Sweep'),
            ],
            value: _preset,
            compact: true,
            onChanged: (value) => setState(() => _preset = value),
          ),
          const SizedBox(height: 14),
          const SectionLabel('Strength'),
          const SizedBox(height: 8),
          Slider(
            value: _strength,
            onChanged: (value) => setState(() => _strength = value),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PillButton(
                label: 'Reveal',
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                onTap: () => setState(() => _cycle++),
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
              "import { ImageGeneration } from 'img-fx';\n\n<ImageGeneration images={images} preset=\"pixels-organic\" />",
        ),
      ],
    );
  }
}

class _ImageInstall extends StatelessWidget {
  const _ImageInstall({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    final install = switch (platform) {
      'rn' => 'npm install img-fx',
      'swift' => '// ImageGeneration is web-first; a native port is not published.',
      _ => 'npm install img-fx three',
    };
    final usage = switch (platform) {
      'rn' =>
        "import { ImageGeneration } from 'img-fx';\n\n<ImageGeneration images={images} />",
      'swift' => '// No native implementation yet.',
      _ =>
        "import { ImageGeneration } from 'img-fx';\n\n<ImageGeneration images={images} />",
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
