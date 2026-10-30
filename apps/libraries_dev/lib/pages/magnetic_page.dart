import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magnetic_ui/magnetic_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ui_kit/ui_kit.dart';

import '../data/backend.dart';
import '../data/repositories.dart';
import '../site/site_shell.dart';

class MagneticPage extends StatefulWidget {
  const MagneticPage({super.key});

  @override
  State<MagneticPage> createState() => _MagneticPageState();
}

class _MagneticPageState extends State<MagneticPage> {
  String _tab = 'preview';
  String _platform = 'react';

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/magnetic',
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
            const _MagneticPreview()
          else
            _MagneticInstall(platform: _platform),
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
          child: SvgPicture.asset('assets/site/icons/figma-magnetic.svg'),
        ),
        const SizedBox(height: 16),
        Text('Magnetic UI', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 5),
        Text(
          'An interface that leans toward the pointer, powered by a magnetic field.',
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

class _MagneticPreview extends StatelessWidget {
  const _MagneticPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: SiteColors.code,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: SiteColors.line),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 4 : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  return MagneticSurface(
                    strength: 0.22,
                    reach: 180,
                    onTap: () {},
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1D1D),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SiteColors.line),
                      ),
                      child: Center(
                        child: Icon(
                          [
                            Icons.auto_awesome,
                            Icons.bolt_rounded,
                            Icons.blur_on_rounded,
                            Icons.circle_outlined,
                          ][index % 4],
                          color: SiteColors.muted,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Move the pointer across the tiles. This first pass runs the pull in '
          'Flutter; the model-backed magnet bridge and download are local mocks.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 18),
        const _BridgePanel(),
        const SizedBox(height: 30),
        Text(
          'Playground',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: SiteColors.subtle,
              ),
        ),
        const SizedBox(height: 12),
        const _MagneticPlayground(),
      ],
    );
  }
}

class _BridgePanel extends StatefulWidget {
  const _BridgePanel();

  @override
  State<_BridgePanel> createState() => _BridgePanelState();
}

class _BridgePanelState extends State<_BridgePanel> {
  MagnetBridge? _bridge;
  String _status = 'Not connected';
  double? _pull;
  bool _busy = false;

  @override
  void dispose() {
    _bridge?.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _busy = true;
      _status = 'Connecting to ws://127.0.0.1:47613...';
    });
    final bridge = MagnetBridge();
    final connected = await bridge.connect();
    if (!mounted) {
      await bridge.dispose();
      return;
    }
    if (!connected) {
      await bridge.dispose();
      setState(() {
        _busy = false;
        _status =
            'No bridge found. Start MagnetBridge.apk on the phone to stream frames.';
      });
      return;
    }
    _bridge = bridge;
    bridge.frames.listen((frame) {
      if (!mounted) return;
      setState(() {
        _pull = frame.pull;
        _status =
            'Connected${bridge.hello?.device.isNotEmpty == true ? ' to ${bridge.hello!.device}' : ''}';
      });
    });
    setState(() {
      _busy = false;
      _status = 'Connected. Move the phone near a magnet.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return InsetSurface(
      color: SiteColors.panel,
      radius: 16,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Local magnet bridge'),
                const SizedBox(height: 6),
                Text(_status, style: Theme.of(context).textTheme.bodySmall),
                if (_pull != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'pull ${_pull!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          PillButton(
            label: _busy ? 'Connecting...' : 'Connect',
            enabled: !_busy,
            onTap: _connect,
          ),
        ],
      ),
    );
  }
}

class _MagneticPlayground extends StatefulWidget {
  const _MagneticPlayground();

  @override
  State<_MagneticPlayground> createState() => _MagneticPlaygroundState();
}

class _MagneticPlaygroundState extends State<_MagneticPlayground> {
  double _strength = 0.22;
  double _reach = 220;
  MagneticAxis _axis = MagneticAxis.both;

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
        child: MagneticSurface(
          strength: _strength,
          reach: _reach,
          axis: _axis,
          onTap: () {},
          child: Container(
            width: 220,
            height: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1D1D1D),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SiteColors.lineStrong),
            ),
            child: Text(
              'Magnetic',
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
          const SectionLabel('Strength'),
          Slider(
            min: 0,
            max: 0.6,
            value: _strength,
            onChanged: (value) => setState(() => _strength = value),
          ),
          const SectionLabel('Reach'),
          Slider(
            min: 100,
            max: 320,
            value: _reach,
            onChanged: (value) => setState(() => _reach = value),
          ),
          const SectionLabel('Axis'),
          const SizedBox(height: 8),
          PillTabs<MagneticAxis>(
            options: const [
              PillOption(MagneticAxis.both, 'Both'),
              PillOption(MagneticAxis.horizontal, 'X'),
              PillOption(MagneticAxis.vertical, 'Y'),
            ],
            value: _axis,
            compact: true,
            onChanged: (value) => setState(() => _axis = value),
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
              "import { useMagneticPull } from 'magnetkit-web';\n\nconst ref = useMagneticPull(container, { strength: 0.22 });",
        ),
      ],
    );
  }
}

class _MagneticInstall extends StatelessWidget {
  const _MagneticInstall({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    final install = switch (platform) {
      'rn' => 'npm install magnetkit-native magnetkit-web',
      'swift' => '// Add MagnetKit from the Libraries.dev repository with Swift Package Manager.',
      _ => 'npm install magnetkit-web',
    };
    final usage = switch (platform) {
      'rn' =>
        "import { useMagnetFrame } from 'magnetkit-native';\n\nconst frame = useMagnetFrame();",
      'swift' =>
        'import MagnetKit\n\nlet reading = MagnetSource.shared.reading()',
      _ =>
        "import { useMagneticPull } from 'magnetkit-web';\n\nconst ref = useMagneticPull(container);",
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InsetSurface(
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
        ),
        const SizedBox(height: 12),
        InsetSurface(
          color: SiteColors.panel,
          radius: 16,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The Magnetic model and the Android Magnet Bridge are not '
                'available in this local slice. The web download is '
                'account-gated and the model is separately licensed.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              const _ModelDownloadButton(),
            ],
          ),
        ),
      ],
    );
  }
}



class _ModelDownloadButton extends StatefulWidget {
  const _ModelDownloadButton();

  @override
  State<_ModelDownloadButton> createState() => _ModelDownloadButtonState();
}

class _ModelDownloadButtonState extends State<_ModelDownloadButton> {
  bool _busy = false;
  String? _status;

  Future<void> _download() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final support = await getApplicationSupportDirectory();
      final models = Directory('${support.path}/models');
      final file = await backend.downloads.downloadMagnetModel(models);
      if (!mounted) return;
      setState(() => _status = 'Saved ${file.path}');
    } catch (error) {
      if (!mounted) return;
      setState(() => _status = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = backend is! MockBackend;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PillButton(
          label: _busy
              ? 'Downloading...'
              : available
                  ? 'Download model'
                  : 'Model download needs the real backend',
          enabled: available && !_busy,
          onTap: _download,
        ),
        if (_status != null) ...[
          const SizedBox(height: 8),
          Text(_status!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}
