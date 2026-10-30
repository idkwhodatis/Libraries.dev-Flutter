import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:ui_kit/ui_kit.dart';

import '../site/site_shell.dart';

class OrbsPage extends StatelessWidget {
  const OrbsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SiteShell(
      currentPath: '/orbs',
      child: _OrbsBody(),
    );
  }
}

class _OrbsBody extends StatefulWidget {
  const _OrbsBody();

  @override
  State<_OrbsBody> createState() => _OrbsBodyState();
}

class _OrbsBodyState extends State<_OrbsBody> {
  String _tab = 'preview';
  String _platform = 'react';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 900;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (desktop) const _OrbsTopBar(),
        const _OrbsHeader(),
        SizedBox(height: desktop ? 26 : 46),
        _HeaderRow(
          tab: _tab,
          onTab: (value) => setState(() => _tab = value),
          platform: _platform,
          onPlatform: (value) => setState(() => _platform = value),
          onCopyPrompt: () => _copyPrompt(context),
        ),
        const SizedBox(height: 22),
        if (_tab == 'preview')
          const _OrbPreview()
        else
          _OrbInstall(
            platform: _platform,
            onPlatformChanged: (value) => setState(() => _platform = value),
          ),
      ],
    );

    if (!desktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          const _DocsChips(),
          const SizedBox(height: 24),
          content,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 200, child: _DocsSidebar()),
        const SizedBox(width: 56),
        Expanded(child: content),
      ],
    );
  }

  Future<void> _copyPrompt(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: _agentPrompt));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Agent prompt copied'),
        duration: Duration(milliseconds: 1400),
      ),
    );
  }
}

const _agentPrompt = '''Add the Orb effect from Libraries.dev to my React app.

Install:
npm install thinking-orbs

Usage:
import { ThinkingOrb } from 'thinking-orbs';

<ThinkingOrb state="searching" size={64} />

Props:
- state: "working" | "searching" | "solving" | "listening" | "connecting" | "weaving" | "composing" | "breathing" | "shaping"
- size: 64 (chat-avatar scale) or 20 (inline-text scale) - each is separately tuned
- speed: multiplies the animation clock, default 1
- dark: boolean, picks the light or dark tuning
- paused: boolean, freezes the animation

Orb replaces the spinner in an AI "thinking" state with nine hand-tuned animated
states. It ships zero runtime dependencies and needs React 18 or newer.
Docs: https://libraries.dev/orbs.html''';

class _OrbsTopBar extends StatelessWidget {
  const _OrbsTopBar();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconPill(
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            tooltip: 'Previous library - Beam',
            onTap: () => context.go('/beam'),
          ),
          const SizedBox(width: 8),
          IconPill(
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            tooltip: 'Next library - Gooey',
            onTap: () => context.go('/gooey'),
          ),
        ],
      ),
    );
  }
}

class _OrbsHeader extends StatelessWidget {
  const _OrbsHeader();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: compact ? 7 : 26),
        Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: SiteColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SiteColors.line),
          ),
          child: SvgPicture.asset('assets/site/icons/figma-orbs.svg'),
        ),
        const SizedBox(height: 16),
        Text(
          'Thinking orbs',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: compact ? 30 : 36,
              ),
        ),
        const SizedBox(height: 5),
        Text(
          'Thought-orb loading indicators for AI interfaces, with nine hand-tuned animated states.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.tab,
    required this.onTab,
    required this.platform,
    required this.onPlatform,
    required this.onCopyPrompt,
  });

  final String tab;
  final ValueChanged<String> onTab;
  final String platform;
  final ValueChanged<String> onPlatform;
  final VoidCallback onCopyPrompt;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 900;
    final narrow = width < 480;
    final tabs = _HeaderTabs(value: tab, onChanged: onTab);
    final platforms = _PlatformTextTabs(
      value: platform,
      onChanged: onPlatform,
    );
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        PillButton(
          label: 'Tune in Studio',
          icon: const Icon(Icons.auto_awesome, size: 15),
          onTap: () => context.go('/studio/app'),
        ),
        PillButton(
          label: 'Copy prompt',
          icon: const Icon(Icons.copy_rounded, size: 14),
          onTap: onCopyPrompt,
        ),
      ],
    );

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: tabs),
          SizedBox(height: narrow ? 19 : 12),
          if (narrow) ...[
            platforms,
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: PillButton(
                label: 'Copy prompt',
                icon: const Icon(Icons.copy_rounded, size: 14),
                compact: true,
                onTap: onCopyPrompt,
              ),
            ),
          ] else
            Row(
              children: [
                platforms,
                const Spacer(),
                PillButton(
                  label: 'Copy prompt',
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  compact: true,
                  onTap: onCopyPrompt,
                ),
              ],
            ),
        ],
      );
    }

    return Row(
      children: [
        tabs,
        const Spacer(),
        platforms,
        const SizedBox(width: 18),
        actions,
      ],
    );
  }
}

class _PlatformTextTabs extends StatelessWidget {
  const _PlatformTextTabs({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const options = <(String, String)>[
      ('react', 'React'),
      ('swift', 'SwiftUI'),
      ('rn', 'React Native'),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 18),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onChanged(options[i].$1),
              child: Text(
                options[i].$2,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: value == options[i].$1
                      ? FontWeight.w500
                      : FontWeight.w400,
                  color: value == options[i].$1
                      ? SiteColors.text
                      : SiteColors.subtle,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeaderTabs extends StatelessWidget {
  const _HeaderTabs({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: SiteColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DetailTab(
            label: 'Preview',
            active: value == 'preview',
            onTap: () => onChanged('preview'),
          ),
          _DetailTab(
            label: 'Install',
            active: value == 'install',
            onTap: () => onChanged('install'),
          ),
        ],
      ),
    );
  }
}

class _DetailTab extends StatelessWidget {
  const _DetailTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0x14FFFFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(48),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active ? SiteColors.text : SiteColors.subtle,
          ),
        ),
      ),
    );
  }
}

class _OrbPreview extends StatelessWidget {
  const _OrbPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _OrbExamples(),
        const SizedBox(height: 24),
        Text(
          'Playground',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: SiteColors.subtle,
              ),
        ),
        const SizedBox(height: 12),
        const _OrbPlayground(),
      ],
    );
  }
}

class _OrbExamples extends StatelessWidget {
  const _OrbExamples();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wide)
          const Row(
            children: [
              Expanded(
                child: _OrbExamplePill(
                  state: OrbState.solving,
                  label: 'Solving….',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _OrbExamplePill(
                  state: OrbState.composing,
                  label: 'Thinking….',
                ),
              ),
            ],
          )
        else
          const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _OrbExamplePill(
                state: OrbState.solving,
                label: 'Solving….',
                compact: true,
              ),
              SizedBox(height: 12),
              _OrbExamplePill(
                state: OrbState.composing,
                label: 'Thinking….',
                compact: true,
              ),
            ],
          ),
        const SizedBox(height: 12),
        if (width >= 860)
          LayoutGrid(
            columnSizes: [1.fr, 1.fr],
            rowSizes: List.filled(5, 151.px),
            rowGap: 12,
            columnGap: 12,
            children: [
              for (final item in _chips)
                GridPlacement(
                  rowSpan: item.$3 ? 2 : 1,
                  child: _OrbExampleChip(
                    state: item.$1,
                    label: item.$2,
                    large: item.$3,
                  ),
                ),
            ],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in _chips) ...[
                SizedBox(
                  height: 200,
                  child: _OrbExampleChip(
                    state: item.$1,
                    label: item.$2,
                    large: item.$3,
                  ),
                ),
                if (item != _chips.last) const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }

  static const _chips = <(OrbState, String, bool)>[
    (OrbState.listening, 'Agent listening…', false),
    (OrbState.working, 'Working….', true),
    (OrbState.searching, 'Searching….', true),
    (OrbState.connecting, 'Solving….', true),
    (OrbState.weaving, 'Agent planning…', false),
    (OrbState.breathing, 'Agent thinking…', false),
    (OrbState.shaping, 'Agent shaping…', false),
  ];
}

class _OrbExamplePill extends StatelessWidget {
  const _OrbExamplePill({
    required this.state,
    required this.label,
    this.compact = false,
  });

  final OrbState state;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: compact ? 200 : 314,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 20 : 40,
        vertical: compact ? 32 : 48,
      ),
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(compact ? 20 : 30),
        border: Border.all(color: SiteColors.line),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 270,
        height: 74,
        padding: const EdgeInsets.fromLTRB(9, 0, 32, 0),
        decoration: BoxDecoration(
          color: const Color(0x801D1D1D),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0x382C2F36)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThinkingOrb(state: state, size: 64, displaySize: 56),
            const SizedBox(width: 12),
            Flexible(
              child: ShimmerText(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFEDEDED),
                      fontSize: 18,
                      height: 24 / 18,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbExampleChip extends StatelessWidget {
  const _OrbExampleChip({
    required this.state,
    required this.label,
    required this.large,
  });

  final OrbState state;
  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Container(
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(compact ? 20 : 30),
        border: Border.all(color: SiteColors.line),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 20 : 32,
        vertical: 32,
      ),
      child: Container(
        height: large ? 74 : 36,
        padding: EdgeInsets.fromLTRB(
          large ? 9 : 8,
          0,
          large ? 32 : 14,
          0,
        ),
        decoration: BoxDecoration(
          color: const Color(0x801D1D1D),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: const Color(0x382C2F36)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThinkingOrb(
              state: state,
              size: large ? 64 : 20,
              displaySize: large ? 56 : 20,
            ),
            SizedBox(width: large ? 12 : 8),
            ShimmerText(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: large
                        ? const Color(0xFFEDEDED)
                        : const Color(0xFFCFCFCF),
                    fontSize: large ? 18 : 13,
                    height: large ? 24 / 18 : 14 / 13,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbPlayground extends StatefulWidget {
  const _OrbPlayground();

  @override
  State<_OrbPlayground> createState() => _OrbPlaygroundState();
}

class _OrbPlaygroundState extends State<_OrbPlayground> {
  OrbState _state = OrbState.listening;
  int _size = 64;
  bool _paused = true;
  bool _gravity = false;

  static const _states = <PillOption<OrbState>>[
    PillOption(OrbState.working, 'Working'),
    PillOption(OrbState.searching, 'Searching'),
    PillOption(OrbState.solving, 'Solving'),
    PillOption(OrbState.listening, 'Listening'),
    PillOption(OrbState.connecting, 'Connecting'),
    PillOption(OrbState.composing, 'Composing'),
    PillOption(OrbState.breathing, 'Breathing'),
  ];

  String get _snippet {
    final props = ['state="${_state.name}"', 'size={$_size}'];
    if (_gravity) props.add('gravity={{ sprite: macArrow }}');
    final head = _gravity
        ? "import { ThinkingOrb } from 'thinking-orbs';\n// A raster of the platform's own pointer - see the Gravity docs.\nimport { macArrow } from './cursors';\n\n"
        : "import { ThinkingOrb } from 'thinking-orbs';\n\n";
    return "$head<ThinkingOrb ${props.join(' ')} />";
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < 900;
    final stage = Container(
      height: 380,
      decoration: BoxDecoration(
        color: SiteColors.code,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: Stack(
        children: [
          OrbGravityField(
            key: ValueKey('${_state.name}-$_size'),
            state: _state,
            size: _size,
            displaySize: _size.toDouble(),
            paused: _paused,
            enabled: _gravity,
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
          const SectionLabel('State'),
          const SizedBox(height: 8),
          PillTabs<OrbState>(
            options: _states,
            value: _state,
            locked: const ['Weaving', 'Shaping'],
            compact: true,
            onChanged: (value) => setState(() => _state = value),
          ),
          const SizedBox(height: 16),
          const SectionLabel('Size'),
          const SizedBox(height: 8),
          PillTabs<int>(
            options: const [
              PillOption(64, '64px'),
              PillOption(20, '20px'),
            ],
            value: _size,
            locked: const ['32px'],
            compact: true,
            onChanged: (value) => setState(() => _size = value),
          ),
          const SizedBox(height: 16),
          const SectionLabel('Cursor gravity'),
          const SizedBox(height: 8),
          PillTabs<bool>(
            options: const [
              PillOption(false, 'Off'),
              PillOption(true, 'On'),
            ],
            value: _gravity,
            compact: true,
            onChanged: (value) => setState(() => _gravity = value),
          ),
          if (_gravity && !_isDesktop)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Draws the platform pointer, so it only shows on a desktop.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: SiteColors.subtle,
                ),
              ),
            ),
          const SizedBox(height: 20),
          const _TeaserRow(label: 'Speed', value: '1×', fill: 0.27),
          const _TeaserSwatches(),
          const _TeaserRow(label: 'Dots amount', value: '207', fill: 0.37),
          const _TeaserRow(label: 'Dot size', value: '1×', fill: 0.33),
          const _TeaserRow(label: 'Reach', value: '160px', fill: 0.63),
          const _TeaserRow(label: 'Bend', value: '19px', fill: 0.79),
          const _TeaserRow(label: 'Orbit paths', value: '50%', fill: 0.50),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (narrow)
          Column(children: [stage, const SizedBox(height: 12), controls])
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: stage),
              const SizedBox(width: 12),
              SizedBox(width: 268, child: controls),
            ],
          ),
        const SizedBox(height: 12),
        CodeBlock(code: _snippet, label: 'Copy playground snippet'),
      ],
    );
  }

  bool get _isDesktop {
    return switch (Theme.of(context).platform) {
      TargetPlatform.windows || TargetPlatform.macOS || TargetPlatform.linux =>
        true,
      _ => false,
    };
  }
}

class _TeaserRow extends StatelessWidget {
  const _TeaserRow({
    required this.label,
    required this.value,
    required this.fill,
  });

  final String label;
  final String value;
  final double fill;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SiteColors.subtle,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: fill,
              child: Container(
                decoration: BoxDecoration(
                  color: SiteColors.muted,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeaserSwatches extends StatelessWidget {
  const _TeaserSwatches();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Color', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 7),
          Row(
            children: [
              for (final color in const [
                Color(0xFFEDEDED),
                Color(0xFF7CD4FF),
                Color(0xFFFFD28F),
                Color(0xFFFF9EC9),
                Color(0xFF9FE8A8),
              ])
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(color: SiteColors.lineStrong),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrbInstall extends StatelessWidget {
  const _OrbInstall({
    required this.platform,
    required this.onPlatformChanged,
  });

  final String platform;
  final ValueChanged<String> onPlatformChanged;

  @override
  Widget build(BuildContext context) {
    final data = switch (platform) {
      'rn' => const (
          install:
              'npm install thinking-orbs-native @shopify/react-native-skia react-native-reanimated',
          usage:
              "import { ThinkingOrb } from 'thinking-orbs-native';\n\n<ThinkingOrb state=\"searching\" size={64} />",
          note:
              'thinking-orbs-native is not on npm yet - it lives in the web repository.',
        ),
      'swift' => const (
          install:
              '// Package.swift - or Xcode: File > Add Package Dependencies...\n.package(url: "https://github.com/Jakubantalik/Libraries.dev", branch: "main")\n// ...and in your target dependencies:\n.product(name: "ThinkingOrbsKit", package: "Libraries.dev")',
          usage:
              'import ThinkingOrbsKit\n\nThinkingOrb(state: .searching, size: .px64)',
          note: 'iOS 17+, no dependencies.',
        ),
      _ => const (
          install: 'npm install thinking-orbs',
          usage:
              "import { ThinkingOrb } from 'thinking-orbs';\n\n<ThinkingOrb state=\"searching\" size={64} />",
          note: null,
        ),
    };
    return InsetSurface(
      radius: 16,
      padding: const EdgeInsets.all(20),
      color: SiteColors.code,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PillTabs<String>(
            options: const [
              PillOption('react', 'React'),
              PillOption('rn', 'React Native'),
              PillOption('swift', 'SwiftUI'),
            ],
            value: platform,
            onChanged: onPlatformChanged,
          ),
          const SizedBox(height: 20),
          const SectionLabel('Installation'),
          const SizedBox(height: 8),
          CodeBlock(code: data.install, dense: true),
          if (data.note != null) ...[
            const SizedBox(height: 8),
            Text(
              data.note!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 20),
          const SectionLabel('Usage'),
          const SizedBox(height: 8),
          CodeBlock(code: data.usage, dense: true),
        ],
      ),
    );
  }
}

class _DocsSidebar extends StatelessWidget {
  const _DocsSidebar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SidebarGroupLabel('Getting started'),
          _SidebarLink(label: 'Introduction', path: '/introduction'),
          _SidebarLink(label: 'Accessibility', path: '/accessibility'),
          const SizedBox(height: 22),
          const _SidebarGroupLabel('Libraries'),
          _SidebarLink(
            label: 'Border beam',
            path: '/beam',
            icon: 'assets/site/icons/figma-beam.png',
          ),
          _SidebarLink(
            label: 'Thinking orbs',
            path: '/orbs',
            icon: 'assets/site/icons/figma-orbs.svg',
            active: true,
          ),
          _SidebarLink(
            label: 'Gooey',
            path: '/gooey',
            icon: 'assets/site/icons/figma-gooey.svg',
          ),
          _SidebarLink(
            label: 'Voice',
            path: '/voice',
            icon: 'assets/site/icons/figma-voice.png',
          ),
          _SidebarLink(
            label: 'Bot avatars',
            path: '/bots',
            icon: 'assets/site/icons/figma-avatars.svg',
          ),
          _SidebarLink(
            label: 'Metal',
            path: '/metal',
            icon: 'assets/site/icons/figma-metal.png',
          ),
          _SidebarLink(
            label: 'Image',
            path: '/image',
            icon: 'assets/site/icons/figma-image.png',
          ),
          const SizedBox(height: 22),
          const _SidebarGroupLabel('Models'),
          _SidebarLink(
            label: 'Magnetic UI',
            path: '/magnetic',
            icon: 'assets/site/icons/figma-magnetic.svg',
          ),
        ],
      ),
    );
  }
}

class _SidebarGroupLabel extends StatelessWidget {
  const _SidebarGroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: SiteColors.subtle,
            ),
      ),
    );
  }
}

class _SidebarLink extends StatefulWidget {
  const _SidebarLink({
    required this.label,
    required this.path,
    this.icon,
    this.active = false,
  });

  final String label;
  final String path;
  final String? icon;
  final bool active;

  @override
  State<_SidebarLink> createState() => _SidebarLinkState();
}

class _SidebarLinkState extends State<_SidebarLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: Container(
          height: 40,
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: widget.active || _hover
                ? const Color(0x14FFFFFF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.active ? SiteColors.lineStrong : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                SizedBox(
                  width: 24,
                  height: 24,
                  child: widget.icon!.endsWith('.svg')
                      ? SvgPicture.asset(widget.icon!)
                      : Image.asset(widget.icon!, fit: BoxFit.contain),
                ),
                const SizedBox(width: 9),
              ],
              Expanded(
                child: Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.active || _hover
                            ? SiteColors.text
                            : SiteColors.muted,
                        fontSize: 13,
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

class _DocsChips extends StatelessWidget {
  const _DocsChips();

  @override
  Widget build(BuildContext context) {
    const paths = <(String, String)>[
      ('Border beam', '/beam'),
      ('Thinking orbs', '/orbs'),
      ('Gooey', '/gooey'),
      ('Voice', '/voice'),
      ('Bot avatars', '/bots'),
      ('Metal', '/metal'),
      ('Image', '/image'),
      ('Magnetic UI', '/magnetic'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in paths) ...[
            PillButton(
              label: item.$1,
              active: item.$2 == '/orbs',
              compact: true,
              onTap: () => context.go(item.$2),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}










