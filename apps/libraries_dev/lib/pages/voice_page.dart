import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:voice_glow/voice_glow.dart';

import '../site/site_shell.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  String _tab = 'preview';
  String _platform = 'react';

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/voice',
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
            const _VoicePreview()
          else
            _VoiceInstall(platform: _platform),
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
          child: Image.asset('assets/site/icons/tile-voice.png'),
        ),
        const SizedBox(height: 16),
        Text('Voice', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 5),
        Text(
          'A glow that rises with your voice from the bottom of a chat input or phone screen.',
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

class _VoicePreview extends StatelessWidget {
  const _VoicePreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 2 : 1;
            final examples = [
              const _VoiceExample(
                type: VoiceBeamType.defaultBeam,
                label: 'Chat input',
                level: 0.55,
              ),
              const _VoiceExample(
                type: VoiceBeamType.mobile,
                label: 'Phone screen',
                level: 0.72,
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
        const _VoicePlayground(),
      ],
    );
  }
}

class _VoiceExample extends StatelessWidget {
  const _VoiceExample({
    required this.type,
    required this.label,
    required this.level,
  });

  final VoiceBeamType type;
  final String label;
  final double level;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: VoiceBeam(
                type: type,
                level: level,
                borderRadius: type == VoiceBeamType.mobile ? 28 : 18,
                child: Center(
                  child: Text(
                    type == VoiceBeamType.mobile
                        ? 'Listening...'
                        : 'Ask anything...',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _VoicePlayground extends StatefulWidget {
  const _VoicePlayground();

  @override
  State<_VoicePlayground> createState() => _VoicePlaygroundState();
}

class _VoicePlaygroundState extends State<_VoicePlayground> {
  VoiceBeamType _type = VoiceBeamType.defaultBeam;
  VoiceBeamColorVariant _variant = VoiceBeamColorVariant.colorful;
  double _level = 0.55;
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
      child: VoiceBeam(
        type: _type,
        colorVariant: _variant,
        level: _level,
        paused: _paused,
        borderRadius: _type == VoiceBeamType.mobile ? 32 : 20,
        child: Center(
          child: Text(
            _type == VoiceBeamType.mobile ? 'Listening...' : 'Ask anything...',
            style: Theme.of(context).textTheme.bodyMedium,
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
          PillTabs<VoiceBeamType>(
            options: const [
              PillOption(VoiceBeamType.defaultBeam, 'Default'),
              PillOption(VoiceBeamType.pill, 'Pill'),
              PillOption(VoiceBeamType.mobile, 'Mobile'),
            ],
            value: _type,
            compact: true,
            onChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 14),
          const SectionLabel('Color'),
          const SizedBox(height: 8),
          PillTabs<VoiceBeamColorVariant>(
            options: const [
              PillOption(VoiceBeamColorVariant.colorful, 'Colorful'),
              PillOption(VoiceBeamColorVariant.mono, 'Mono'),
              PillOption(VoiceBeamColorVariant.ocean, 'Ocean'),
              PillOption(VoiceBeamColorVariant.sunset, 'Sunset'),
              PillOption(VoiceBeamColorVariant.mint, 'Mint'),
            ],
            value: _variant,
            compact: true,
            onChanged: (value) => setState(() => _variant = value),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Level',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: SiteColors.muted,
                  ),
                ),
              ),
              Text(
                '${(_level * 100).round()}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          Slider(
            value: _level,
            onChanged: (value) => setState(() => _level = value),
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
              "import { VoiceBeam } from 'voice-glow';\n\n<VoiceBeam level={0.55}>\n  <ChatInput />\n</VoiceBeam>",
        ),
      ],
    );
  }
}

class _VoiceInstall extends StatelessWidget {
  const _VoiceInstall({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    final install = switch (platform) {
      'rn' => 'npm install voice-glow-native',
      'swift' => '// Add VoiceGlowKit from the Libraries.dev repository with Swift Package Manager.',
      _ => 'npm install voice-glow',
    };
    final usage = switch (platform) {
      'rn' =>
        "import { VoiceBeam } from 'voice-glow-native';\n\n<VoiceBeam level={level}><ChatInput /></VoiceBeam>",
      'swift' =>
        'import VoiceGlowKit\n\nVoiceBeam(level: level) {\n  ChatInput()\n}',
      _ =>
        "import { VoiceBeam } from 'voice-glow';\n\n<VoiceBeam level={level}>\n  <ChatInput />\n</VoiceBeam>",
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
