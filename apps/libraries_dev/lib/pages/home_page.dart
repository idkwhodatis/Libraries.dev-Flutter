import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:ui_kit/ui_kit.dart';

import '../site/site_shell.dart';
import '../widgets/video_surface.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SiteShell(
      currentPath: '/',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Hero(),
          const _Customers(),
          const _LibraryGrid(),
          const _Quotes(),
          const _HowTo(),
          const _Faq(),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    return Padding(
      padding: EdgeInsets.only(top: compact ? 24 : 64, bottom: compact ? 36 : 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: SiteColors.card,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: SiteColors.line),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 14, color: SiteColors.accent),
                SizedBox(width: 7),
                Text(
                  '7 libraries for AI interfaces',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: SiteColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 680,
            child: Text(
              'High-crafted UI libraries for AI agents.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: compact ? 34 : 52,
                    height: 1.04,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 580,
            child: Text(
              'Effects that make an interface feel alive: a beam of light on a '
              'card, orbs that think, shapes that merge like liquid, and a glow '
              'that rises with your voice.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: SiteColors.muted,
                  ),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              PillButton(
                label: 'Browse libraries',
                primary: true,
                onTap: () => context.go('/orbs'),
              ),
              PillButton(
                label: 'Get full access',
                onTap: () => context.go('/pro'),
              ),
            ],
          ),
          const SizedBox(height: 44),
          const _HeroTiles(),
        ],
      ),
    );
  }
}

class _HeroTiles extends StatelessWidget {
  const _HeroTiles();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final tiles = <Widget>[
      const _LiveOrbTile(),
      const _PreviewTile(
        'beam',
        'assets/site/icons/tile-beam.png',
        video: 'assets/site/videos/beam-main-card.mp4',
        poster: 'assets/site/videos/posters/beam-main-card.jpg',
      ),
      const _PreviewTile(
        'metal',
        'assets/site/icons/tile-metal.png',
        video: 'assets/site/videos/metal-main-card.mp4',
        poster: 'assets/site/videos/posters/metal-main-card.jpg',
      ),
      const _PreviewTile(
        'gooey',
        'assets/site/icons/tile-gooey.png',
        video: 'assets/site/videos/gooey-main-card.mp4',
        poster: 'assets/site/videos/posters/gooey-main-card.jpg',
      ),
      const _PreviewTile(
        'image',
        'assets/site/icons/tile-image.png',
        video: 'assets/site/videos/image-main-card.mp4',
        poster: 'assets/site/videos/posters/image-main-card.jpg',
      ),
    ];
    if (compact) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [for (final tile in tiles) SizedBox(width: 104, height: 104, child: tile)],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < tiles.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          SizedBox(width: 130, height: 130, child: tiles[i]),
        ],
      ],
    );
  }
}

class _LiveOrbTile extends StatelessWidget {
  const _LiveOrbTile();

  @override
  Widget build(BuildContext context) {
    return _TileFrame(
      label: 'Thinking orbs',
      child: const Center(
        child: ThinkingOrb(
          state: OrbState.working,
          size: 64,
          displaySize: 70,
        ),
      ),
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile(
    this.label,
    this.asset, {
    this.video,
    this.poster,
  });

  final String label;
  final String asset;
  final String? video;
  final String? poster;

  @override
  Widget build(BuildContext context) {
    return _TileFrame(
      label: label,
      child: video != null
          ? VideoSurface(asset: video!, poster: poster)
          : Center(
              child: Image.asset(
                asset,
                width: 54,
                height: 54,
                fit: BoxFit.contain,
              ),
            ),
    );
  }
}

class _TileFrame extends StatelessWidget {
  const _TileFrame({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SiteColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SiteColors.line),
      ),
      padding: const EdgeInsets.all(11),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: SiteColors.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: SiteColors.subtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Customers extends StatelessWidget {
  const _Customers();

  @override
  Widget build(BuildContext context) {
    const logos = [
      'vercel.svg',
      'google.svg',
      'zendesk.svg',
      'sarvam-ai.svg',
      'stripe.svg',
      'gecko-robotics.svg',
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1008),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 56),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 28,
          runSpacing: 18,
          children: [
            for (final logo in logos)
              Opacity(
                opacity: 0.55,
                child: SvgPicture.asset(
                  'assets/site/customers/$logo',
                  height: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LibraryGrid extends StatelessWidget {
  const _LibraryGrid();

  static const _items = <(String, String, String, String, String)>[
    (
      'Thinking orbs',
      'Nine hand-tuned thought-orbs for AI interfaces.',
      'orbs',
      'assets/site/icons/tile-orbs.png',
      'live',
    ),
    (
      'Border beam',
      'A soft glow that rides the border of a card, button or input.',
      'beam',
      'assets/site/icons/tile-beam.png',
      'stub',
    ),
    (
      'Gooey',
      'Pieces that merge like goo and morph like jelly while text stays crisp.',
      'gooey',
      'assets/site/icons/tile-gooey.png',
      'stub',
    ),
    (
      'Voice',
      'A glow that rises with your voice from the bottom of a chat input.',
      'voice',
      'assets/site/icons/tile-voice.png',
      'stub',
    ),
    (
      'Bot avatars',
      'Animated bot avatars with living faces, for AI agents.',
      'bots',
      'assets/site/icons/tile-bots.png',
      'stub',
    ),
    (
      'Liquid metal',
      'Liquid metal for buttons, icons, text and badges.',
      'metal',
      'assets/site/icons/tile-metal.png',
      'stub',
    ),
    (
      'Magnetic UI',
      'A magnetometer-driven interface that pulls toward you.',
      'magnetic',
      'assets/site/icons/figma-magnetic.svg',
      'stub',
    ),
    (
      'Image generation',
      'A loader that becomes the image, settling into the picture.',
      'image',
      'assets/site/icons/tile-image.png',
      'stub',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1008),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width >= 960 ? 2 : 1;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seven libraries. One language for living interfaces.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 30),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: columns == 2 ? 1.45 : 1.22,
                ),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _LibraryCard(
                    title: item.$1,
                    description: item.$2,
                    route: '/${item.$3}',
                    icon: item.$4,
                    live: item.$5 == 'live',
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LibraryCard extends StatefulWidget {
  const _LibraryCard({
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
    required this.live,
  });

  final String title;
  final String description;
  final String route;
  final String icon;
  final bool live;

  @override
  State<_LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<_LibraryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _hover ? SiteColors.cardHover : SiteColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _hover ? SiteColors.lineStrong : SiteColors.line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: SiteColors.stage,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SiteColors.line),
                  ),
                  child: Center(
                    child: widget.live
                        ? const ThinkingOrb(
                            state: OrbState.working,
                            size: 64,
                            displaySize: 96,
                          )
                        : widget.icon.endsWith('.svg')
                            ? SvgPicture.asset(
                                widget.icon,
                                width: 64,
                                height: 64,
                              )
                            : Image.asset(
                                widget.icon,
                                width: 64,
                                height: 64,
                                fit: BoxFit.contain,
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                widget.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Quotes extends StatelessWidget {
  const _Quotes();

  static const _quotes = <(String, String, String)>[
    (
      'The orb finally makes waiting feel designed.',
      'Rauchg',
      'assets/site/avatars/rauchg.jpg',
    ),
    (
      'It is the first loading state I have not wanted to replace.',
      'Adam Whitcroft',
      'assets/site/avatars/adam-whitcroft.jpg',
    ),
    (
      'A tiny detail that changes the whole temperature of the product.',
      'Kris Puckett',
      'assets/site/avatars/krispuckett.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1008),
      child: Padding(
        padding: const EdgeInsets.only(top: 96),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900 ? 3 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _quotes.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: columns == 3 ? 1.0 : 1.15,
              ),
              itemBuilder: (context, index) {
                final quote = _quotes[index];
                return InsetSurface(
                  radius: 24,
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${quote.$1}"',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: SiteColors.text,
                            ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundImage: AssetImage(quote.$3),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            quote.$2,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _HowTo extends StatelessWidget {
  const _HowTo();

  @override
  Widget build(BuildContext context) {
    const steps = <(String, String, String)>[
      (
        'Copy the prompt',
        'Every library page has a Copy prompt button. One paste gives your agent the whole library.',
        '1',
      ),
      (
        'Paste it into your agent',
        'Drop it into Claude Code, Cursor or Codex. The agent installs the package and wires it in.',
        '2',
      ),
      (
        'Make it yours',
        'Open the Studio with Pro for every knob, tune it live and copy the result as props.',
        '3',
      ),
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1008),
      child: Padding(
        padding: const EdgeInsets.only(top: 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From prompt to production in three steps.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 28),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 3 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: steps.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: columns == 3 ? 1.0 : 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return InsetSurface(
                      radius: 24,
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: SiteColors.accentStrong,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: SiteColors.accentStrong.withValues(
                                    alpha: 0.22,
                                  ),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Text(
                              step.$3,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            step.$1,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step.$2,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq();

  @override
  Widget build(BuildContext context) {
    const items = <(String, String)>[
      (
        'Do they work with coding agents?',
        'Yes. Every library installs and configures cleanly from Cursor, Claude Code and Codex, and each playground copies the exact configuration.',
      ),
      (
        'Light and dark mode?',
        'Both. The site is dark-first, while the effects follow the host theme when embedded.',
      ),
      (
        'What are Pro and the Studio?',
        'One plan across every library. Pro unlocks deep per-library customization and the exact exported configuration.',
      ),
      (
        'What about the models?',
        'The code is MIT. Model files start with Magnetic UI and are free for development and non-commercial apps.',
      ),
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Padding(
        padding: const EdgeInsets.only(top: 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Questions, answered.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 22),
            for (final item in items) _FaqItem(item.$1, item.$2),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem(this.question, this.answer);

  final String question;
  final String answer;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SiteColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Icon(
                      _open
                          ? Icons.remove_rounded
                          : Icons.add_rounded,
                      size: 18,
                      color: SiteColors.subtle,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text(
                widget.answer,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            crossFadeState:
                _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}





