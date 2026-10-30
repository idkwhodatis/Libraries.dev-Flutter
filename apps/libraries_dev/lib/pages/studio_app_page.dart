import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:ui_kit/ui_kit.dart';

import '../data/backend.dart';
import '../data/repositories.dart';

class StudioAppPage extends StatefulWidget {
  const StudioAppPage({super.key});

  @override
  State<StudioAppPage> createState() => _StudioAppPageState();
}

class _StudioAppPageState extends State<StudioAppPage> {
  OrbState _state = OrbState.listening;
  int _size = 64;
  double _speed = 1;
  double _dots = 1;
  double _dotSize = 1;
  bool _paused = false;
  String _ink = '#ededed';
  List<StudioPreset> _presets = const [];

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    final presets = await backend.presets.list('thinking-orbs');
    if (mounted) setState(() => _presets = presets);
  }

  Future<void> _savePreset() async {
    await backend.presets.save(
      StudioPreset(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        library: 'thinking-orbs',
        name: 'My orb',
        params: {
          'state': _state.name,
          'size': _size,
          'speed': _speed,
          'dots': _dots,
          'dotSize': _dotSize,
          'ink': _ink,
        },
      ),
    );
    await _loadPresets();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preset saved'),
        duration: Duration(milliseconds: 1400),
      ),
    );
  }

  void _applyPreset(StudioPreset preset) {
    setState(() {
      final state = preset.params['state'];
      if (state is String) {
        _state = OrbState.values.firstWhere(
          (value) => value.name == state,
          orElse: () => _state,
        );
      }
      final size = preset.params['size'];
      if (size is num) _size = size.toInt();
      final speed = preset.params['speed'];
      if (speed is num) _speed = speed.toDouble();
      final dots = preset.params['dots'];
      if (dots is num) _dots = dots.toDouble();
      final dotSize = preset.params['dotSize'];
      if (dotSize is num) _dotSize = dotSize.toDouble();
      final ink = preset.params['ink'];
      if (ink is String) _ink = ink;
    });
  }

  Future<void> _deletePreset(StudioPreset preset) async {
    await backend.presets.delete(preset.id);
    await _loadPresets();
  }

  void _applyAgent(Map<String, Object?> params) {
    setState(() {
      final state = params['state'];
      if (state is String) {
        _state = OrbState.values.byName(state);
      }
      final speed = params['speed'];
      if (speed is num) _speed = speed.toDouble();
      final dots = params['dots'];
      if (dots is num) _dots = dots.toDouble();
    });
  }

  String get _snippet {
    final props = <String>[
      'state="${_state.name}"',
      'size={$_size}',
      if (_speed != 1) 'speed={${_speed.toStringAsFixed(2)}}',
      if (_ink != '#ededed') 'color="$_ink"',
      'paused={$_paused.toString()}',
    ];
    return "import { ThinkingOrb } from 'thinking-orbs';\n\n<ThinkingOrb ${props.join(' ')} />";
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 1000;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _StudioTopBar(
              onHome: () => context.go('/'),
              onOrbs: () => context.go('/orbs'),
              onSave: _savePreset,
            ),
            const Divider(height: 1, color: SiteColors.line),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: compact
                    ? Column(
                        children: [
                          _Stage(
                            state: _state,
                            size: _size,
                            speed: _speed,
                            dots: _dots,
                            dotSize: _dotSize,
                            color: _ink,
                            paused: _paused,
                            onTogglePause: () =>
                                setState(() => _paused = !_paused),
                          ),
                          const SizedBox(height: 14),
                          _Controls(
                            state: _state,
                            size: _size,
                            speed: _speed,
                            dots: _dots,
                            dotSize: _dotSize,
                            ink: _ink,
                            paused: _paused,
                            onState: (value) => setState(() => _state = value),
                            onSize: (value) => setState(() => _size = value),
                            onSpeed: (value) => setState(() => _speed = value),
                            onDots: (value) => setState(() => _dots = value),
                            onDotSize: (value) =>
                                setState(() => _dotSize = value),
                            onInk: (value) => setState(() => _ink = value),
                            onPaused: (value) => setState(() => _paused = value),
                          ),
                          const SizedBox(height: 14),
                          _CodePane(code: _snippet),
                          const SizedBox(height: 14),
                          _AgentPanel(onApply: _applyAgent),
                          const SizedBox(height: 14),
                          _PresetPanel(
                            presets: _presets,
                            onApply: _applyPreset,
                            onDelete: _deletePreset,
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 190, child: _Rail()),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _Stage(
                              state: _state,
                              size: _size,
                              speed: _speed,
                              dots: _dots,
                              dotSize: _dotSize,
                              color: _ink,
                              paused: _paused,
                              onTogglePause: () =>
                                  setState(() => _paused = !_paused),
                            ),
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 300,
                            child: Column(
                              children: [
                                _Controls(
                                  state: _state,
                                  size: _size,
                                  speed: _speed,
                                  dots: _dots,
                                  dotSize: _dotSize,
                                  ink: _ink,
                                  paused: _paused,
                                  onState: (value) =>
                                      setState(() => _state = value),
                                  onSize: (value) =>
                                      setState(() => _size = value),
                                  onSpeed: (value) =>
                                      setState(() => _speed = value),
                                  onDots: (value) =>
                                      setState(() => _dots = value),
                                  onDotSize: (value) =>
                                      setState(() => _dotSize = value),
                                  onInk: (value) =>
                                      setState(() => _ink = value),
                                  onPaused: (value) =>
                                      setState(() => _paused = value),
                                ),
                                const SizedBox(height: 12),
                                _CodePane(code: _snippet),
                                const SizedBox(height: 12),
                                _AgentPanel(onApply: _applyAgent),
                                const SizedBox(height: 12),
                                _PresetPanel(
                                  presets: _presets,
                                  onApply: _applyPreset,
                                  onDelete: _deletePreset,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudioTopBar extends StatelessWidget {
  const _StudioTopBar({
    required this.onHome,
    required this.onOrbs,
    required this.onSave,
  });

  final VoidCallback onHome;
  final VoidCallback onOrbs;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onHome,
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: SiteColors.accent,
                ),
                const SizedBox(width: 9),
                Text(
                  compact ? 'Studio' : 'libraries.dev',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(width: 9),
                  const Text(
                    'Studio',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: SiteColors.subtle,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          PillButton(
            label: compact ? 'Page' : 'Library page',
            compact: compact,
            onTap: onOrbs,
          ),
          if (!compact) ...[
            const SizedBox(width: 8),
            PillButton(label: 'Save preset', onTap: onSave),
          ],
        ],
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail();

  @override
  Widget build(BuildContext context) {
    const libraries = <(String, String)>[
      ('Border beam', '/beam'),
      ('Thinking orbs', '/orbs'),
      ('Gooey', '/gooey'),
      ('Voice', '/voice'),
      ('Bot avatars', '/bots'),
      ('Liquid metal', '/metal'),
      ('Image', '/image'),
    ];
    return InsetSurface(
      radius: 14,
      padding: const EdgeInsets.all(10),
      color: SiteColors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Libraries'),
          const SizedBox(height: 10),
          for (final item in libraries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: PillButton(
                label: item.$1,
                active: item.$2 == '/orbs',
                onTap: () => context.go(item.$2),
              ),
            ),
          const SizedBox(height: 16),
          const SectionLabel('Agent'),
          const SizedBox(height: 8),
          const _RailRow(label: 'Tune with agent', value: 'Mock'),
        ],
      ),
    );
  }
}

class _RailRow extends StatelessWidget {
  const _RailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({
    required this.state,
    required this.size,
    required this.speed,
    required this.dots,
    required this.dotSize,
    required this.color,
    required this.paused,
    required this.onTogglePause,
  });

  final OrbState state;
  final int size;
  final double speed;
  final double dots;
  final double dotSize;
  final String color;
  final bool paused;
  final VoidCallback onTogglePause;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 560,
      decoration: BoxDecoration(
        color: SiteColors.stage,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SiteColors.line),
      ),
      child: Stack(
        children: [
          OrbGravityField(
            state: state,
            size: size,
            displaySize: 260,
            speed: speed,
            dots: dots,
            dotSize: dotSize,
            color: color,
            paused: paused,
          ),
          Positioned(
            left: 16,
            top: 16,
            child: Text(
              '${state.name} · ${size}px',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: PillButton(
              label: paused ? 'Play' : 'Pause',
              icon: Icon(
                paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                size: 16,
              ),
              onTap: onTogglePause,
            ),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.state,
    required this.size,
    required this.speed,
    required this.dots,
    required this.dotSize,
    required this.ink,
    required this.paused,
    required this.onState,
    required this.onSize,
    required this.onSpeed,
    required this.onDots,
    required this.onDotSize,
    required this.onInk,
    required this.onPaused,
  });

  final OrbState state;
  final int size;
  final double speed;
  final double dots;
  final double dotSize;
  final String ink;
  final bool paused;
  final ValueChanged<OrbState> onState;
  final ValueChanged<int> onSize;
  final ValueChanged<double> onSpeed;
  final ValueChanged<double> onDots;
  final ValueChanged<double> onDotSize;
  final ValueChanged<String> onInk;
  final ValueChanged<bool> onPaused;

  static const _states = <PillOption<OrbState>>[
    PillOption(OrbState.working, 'Working'),
    PillOption(OrbState.searching, 'Searching'),
    PillOption(OrbState.solving, 'Solving'),
    PillOption(OrbState.listening, 'Listening'),
    PillOption(OrbState.connecting, 'Connecting'),
    PillOption(OrbState.weaving, 'Weaving'),
    PillOption(OrbState.composing, 'Composing'),
    PillOption(OrbState.breathing, 'Breathing'),
    PillOption(OrbState.shaping, 'Shaping'),
  ];

  @override
  Widget build(BuildContext context) {
    return InsetSurface(
      color: SiteColors.panel,
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('State'),
          const SizedBox(height: 8),
          PillTabs<OrbState>(
            options: _states,
            value: state,
            compact: true,
            onChanged: onState,
          ),
          const SizedBox(height: 14),
          const SectionLabel('Size'),
          const SizedBox(height: 8),
          PillTabs<int>(
            options: const [
              PillOption(64, '64px'),
              PillOption(32, '32px'),
              PillOption(20, '20px'),
            ],
            value: size,
            compact: true,
            onChanged: onSize,
          ),
          const SizedBox(height: 16),
          _Slider(
            label: 'Speed',
            value: '${speed.toStringAsFixed(2)}x',
            value2: speed,
            min: 0.1,
            max: 2,
            onChanged: onSpeed,
          ),
          _Slider(
            label: 'Dots amount',
            value: '${(dots * 207).round()}',
            value2: dots,
            min: 0.1,
            max: 2,
            onChanged: onDots,
          ),
          _Slider(
            label: 'Dot size',
            value: '${dotSize.toStringAsFixed(2)}x',
            value2: dotSize,
            min: 0.3,
            max: 2,
            onChanged: onDotSize,
          ),
          const SizedBox(height: 8),
          const SectionLabel('Color'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final swatch in const [
                '#ededed',
                '#7cd4ff',
                '#ffd28f',
                '#ff9ec9',
                '#9fe8a8',
              ])
                GestureDetector(
                  onTap: () => onInk(swatch),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: _color(swatch),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ink == swatch
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
            label: paused ? 'Play animation' : 'Pause animation',
            icon: Icon(
              paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              size: 16,
            ),
            onTap: () => onPaused(!paused),
          ),
        ],
      ),
    );
  }

  Color _color(String value) {
    final hex = value.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class _Slider extends StatelessWidget {
  const _Slider({
    required this.label,
    required this.value,
    required this.value2,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String value;
  final double value2;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: Theme.of(context).textTheme.bodySmall),
              ),
              Text(value, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: SiteColors.muted,
              inactiveTrackColor: const Color(0x1FFFFFFF),
              thumbColor: SiteColors.text,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              min: min,
              max: max,
              value: value2.clamp(min, max),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetPanel extends StatelessWidget {
  const _PresetPanel({
    required this.presets,
    required this.onApply,
    required this.onDelete,
  });

  final List<StudioPreset> presets;
  final ValueChanged<StudioPreset> onApply;
  final ValueChanged<StudioPreset> onDelete;

  @override
  Widget build(BuildContext context) {
    return InsetSurface(
      color: SiteColors.panel,
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Saved presets'),
          const SizedBox(height: 8),
          if (presets.isEmpty)
            Text(
              'Save the current orb to reuse it.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            for (final preset in presets)
              InkWell(
                onTap: () => onApply(preset),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              preset.params['state']?.toString() ?? 'orb',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete preset',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () => onDelete(preset),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _AgentPanel extends StatefulWidget {
  const _AgentPanel({required this.onApply});

  final ValueChanged<Map<String, Object?>> onApply;

  @override
  State<_AgentPanel> createState() => _AgentPanelState();
}

class _AgentPanelState extends State<_AgentPanel> {
  bool _busy = false;
  String _status = 'Mock agent is ready. It does not call the real endpoint.';

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _status = 'Thinking...';
    });
    await for (final event in backend.agent.chat(const ['calm'])) {
      if (!mounted) return;
      if (event.type == 'status') {
        setState(() => _status = event.text);
      } else if (event.type == 'text') {
        setState(() => _status = event.text);
      } else if (event.type == 'params' && event.params != null) {
        widget.onApply(event.params!);
        setState(() => _status = event.text);
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return InsetSurface(
      color: SiteColors.panel,
      radius: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Agent'),
          const SizedBox(height: 8),
          Text(_status, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          PillButton(
            label: _busy ? 'Thinking...' : 'Ask agent to calm it',
            enabled: !_busy,
            icon: const Icon(Icons.auto_awesome, size: 15),
            onTap: _run,
          ),
        ],
      ),
    );
  }
}

class _CodePane extends StatefulWidget {
  const _CodePane({required this.code});

  final String code;

  @override
  State<_CodePane> createState() => _CodePaneState();
}

class _CodePaneState extends State<_CodePane> {
  String _tab = 'snippet';
  String _platform = 'react';

  static const _install = <String, String>{
    'react': 'npm install thinking-orbs',
    'swift':
        '.package(url: "https://github.com/Jakubantalik/Libraries.dev.git", from: "0.3.1")',
    'rn': 'npm install @shopify/react-native-skia react-native-reanimated',
  };

  static const _usage = <String, String>{
    'react': '''import { ThinkingOrb } from 'thinking-orbs';

<ThinkingOrb state="listening" size={64} />''',
    'swift': '''import ThinkingOrbsKit

ThinkingOrb(state: .listening, size: .px64)

// render the 64 design at another size, still vector-crisp
ThinkingOrb(state: .working, size: .px64, displaySize: 133)''',
    'rn': '''import { ThinkingOrb } from 'thinking-orbs-native';

<ThinkingOrb state="listening" size={64} />''',
  };

  String get _code {
    return switch (_tab) {
      'install' => _install[_platform]!,
      'usage' => _usage[_platform]!,
      _ => widget.code,
    };
  }

  @override
  Widget build(BuildContext context) {
    return InsetSurface(
      color: SiteColors.panel,
      radius: 16,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Snippet'),
          const SizedBox(height: 8),
          PillTabs<String>(
            options: const [
              PillOption('snippet', 'Snippet'),
              PillOption('install', 'Install'),
              PillOption('usage', 'Usage'),
            ],
            value: _tab,
            compact: true,
            onChanged: (value) => setState(() => _tab = value),
          ),
          if (_tab != 'snippet') ...[
            const SizedBox(height: 8),
            PillTabs<String>(
              options: const [
                PillOption('react', 'React'),
                PillOption('swift', 'SwiftUI'),
                PillOption('rn', 'React Native'),
              ],
              value: _platform,
              compact: true,
              onChanged: (value) => setState(() => _platform = value),
            ),
          ],
          const SizedBox(height: 8),
          CodeBlock(code: _code, dense: true, maxHeight: 220),
          if (_tab == 'install' && _platform != 'react') ...[
            const SizedBox(height: 8),
            Text(
              'Native ports install from the repository and are not on npm.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}



