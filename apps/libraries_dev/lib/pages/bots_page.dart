import 'package:bot_avatars/bot_avatars.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

import '../site/site_shell.dart';

class BotsPage extends StatefulWidget {
  const BotsPage({super.key});

  @override
  State<BotsPage> createState() => _BotsPageState();
}

class _BotsPageState extends State<BotsPage> {
  String _tab = 'preview';
  String _platform = 'react';

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/bots',
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
            const _BotsPreview()
          else
            _BotsInstall(platform: _platform),
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
          child: Image.asset('assets/site/icons/tile-bots.png'),
        ),
        const SizedBox(height: 16),
        Text('Bot avatars', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 5),
        Text(
          'Animated bot avatars with living faces, for AI agents.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 12,
          runSpacing: 10,
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
          ],
        ),
      ],
    );
  }
}

class _BotsPreview extends StatelessWidget {
  const _BotsPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 3 : 1;
            final examples = [
              const _BotExample(
                type: BotAvatarType.clover,
                state: BotAvatarState.idle,
                label: 'Clover · idle',
              ),
              const _BotExample(
                type: BotAvatarType.ghost,
                state: BotAvatarState.working,
                label: 'Ghost · working',
              ),
              const _BotExample(
                type: BotAvatarType.star,
                state: BotAvatarState.sleeping,
                label: 'Star · sleeping',
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
        const _BotPlayground(),
      ],
    );
  }
}

class _BotExample extends StatelessWidget {
  const _BotExample({
    required this.type,
    required this.state,
    required this.label,
  });

  final BotAvatarType type;
  final BotAvatarState state;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: Column(
        children: [
          const Spacer(),
          BotAvatar(type: type, state: state, size: 96),
          const Spacer(),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _BotPlayground extends StatefulWidget {
  const _BotPlayground();

  @override
  State<_BotPlayground> createState() => _BotPlaygroundState();
}

class _BotPlaygroundState extends State<_BotPlayground> {
  BotAvatarType _type = BotAvatarType.clover;
  BotAvatarState _state = BotAvatarState.idle;
  BotAvatarFace _face = BotAvatarFace.eyes;
  double _size = 96;
  bool _paused = false;
  String _color = '';

  static const _colors = <String>[
    '',
    '#7cd4ff',
    '#ffd28f',
    '#ff9ec9',
    '#9fe8a8',
  ];

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
      child: Stack(
        children: [
          Center(
            child: BotAvatar(
              type: _type,
              state: _state,
              face: _face,
              size: _size,
              paused: _paused,
              color: _color.isEmpty ? null : _color,
            ),
          ),
          Positioned(
            right: 14,
            bottom: 14,
            child: PillButton(
              label: _paused ? 'Play' : 'Pause',
              icon: Icon(
                _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                size: 16,
              ),
              onTap: () => setState(() => _paused = !_paused),
            ),
          ),
        ],
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
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final type in BotAvatarType.values)
                PillButton(
                  label: type.name,
                  active: type == _type,
                  compact: true,
                  onTap: () => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const SectionLabel('State'),
          const SizedBox(height: 8),
          PillTabs<BotAvatarState>(
            options: const [
              PillOption(BotAvatarState.idle, 'Idle'),
              PillOption(BotAvatarState.working, 'Working'),
              PillOption(BotAvatarState.sleeping, 'Sleeping'),
            ],
            value: _state,
            compact: true,
            onChanged: (value) => setState(() => _state = value),
          ),
          const SizedBox(height: 14),
          const SectionLabel('Face'),
          const SizedBox(height: 8),
          PillTabs<BotAvatarFace>(
            options: const [
              PillOption(BotAvatarFace.eyes, 'Eyes'),
              PillOption(BotAvatarFace.mouth, 'Mouth'),
            ],
            value: _face,
            compact: true,
            onChanged: (value) => setState(() => _face = value),
          ),
          const SizedBox(height: 14),
          const SectionLabel('Size'),
          const SizedBox(height: 8),
          PillTabs<double>(
            options: const [
              PillOption(96, '96px'),
              PillOption(64, '64px'),
              PillOption(32, '32px'),
            ],
            value: _size,
            compact: true,
            onChanged: (value) => setState(() => _size = value),
          ),
          const SizedBox(height: 14),
          const SectionLabel('Color'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final color in _colors)
                GestureDetector(
                  onTap: () => setState(() => _color = color),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: color.isEmpty
                          ? const Color(0xFF8B7CFF)
                          : _parseColor(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == color
                            ? SiteColors.text
                            : SiteColors.lineStrong,
                        width: 2,
                      ),
                    ),
                  ),
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
              "import { BotAvatar } from 'bot-avatars';\n\n<BotAvatar type=\"clover\" state=\"working\" size={64} />",
        ),
      ],
    );
  }

  Color _parseColor(String value) {
    final hex = value.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class _BotsInstall extends StatelessWidget {
  const _BotsInstall({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    final install = switch (platform) {
      'rn' => 'npm install bot-avatars-native @shopify/react-native-skia react-native-reanimated',
      'swift' => '// Add BotAvatarsKit from the Libraries.dev repository with Swift Package Manager.',
      _ => 'npm install bot-avatars',
    };
    final usage = switch (platform) {
      'rn' =>
        "import { BotAvatar } from 'bot-avatars-native';\n\n<BotAvatar type=\"clover\" state=\"working\" />",
      'swift' =>
        'import BotAvatarsKit\n\nBotAvatar(type: .clover, state: .working)',
      _ =>
        "import { BotAvatar } from 'bot-avatars';\n\n<BotAvatar type=\"clover\" state=\"working\" />",
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
