import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

class SiteShell extends StatelessWidget {
  const SiteShell({
    super.key,
    required this.currentPath,
    required this.child,
    this.maxWidth = 1240,
    this.padding,
  });

  final String currentPath;
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 760;
    return Scaffold(
      backgroundColor: SiteColors.page,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SiteNav(currentPath: currentPath, mobile: mobile),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Padding(
                    padding: padding ??
                        EdgeInsets.fromLTRB(
                          mobile ? 16 : 24,
                          0,
                          mobile ? 16 : 24,
                          64,
                        ),
                    child: child,
                  ),
                ),
              ),
              const SiteFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class SiteNav extends StatelessWidget {
  const SiteNav({super.key, required this.currentPath, this.mobile = false});

  final String currentPath;
  final bool mobile;

  static const _links = <(String, String)>[
    ('Libraries', '/'),
    ('How to use', '/how-to-use'),
    ('Skill', '/skill'),
    ('Pricing', '/pro'),
    ('Studio', '/studio'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(mobile ? 12 : 24, 16, mobile ? 12 : 24, 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => context.go('/'),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BrandMark(),
                      SizedBox(width: 8),
                      Text(
                        'Libraries',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: SiteColors.text,
                        ),
                      ),
                      Text(
                        '.dev',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: SiteColors.subtle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!mobile) ...[
                const SizedBox(width: 22),
                for (final link in _links)
                  _NavLink(
                    label: link.$1,
                    path: link.$2,
                    active: _isActive(link.$2),
                  ),
                const Spacer(),
                PillButton(
                  label: 'Get Pro',
                  primary: true,
                  onTap: () => context.go('/pro'),
                ),
                const SizedBox(width: 8),
                const _StarPill(),
                const SizedBox(width: 8),
                IconPill(
                  icon: const Icon(Icons.more_horiz_rounded, size: 18),
                  tooltip: 'More',
                  onTap: () =>
                      context.go(currentPath == '/account' ? '/' : '/account'),
                ),
              ] else ...[
                const Spacer(),
                PillButton(
                  label: 'Get Pro',
                  compact: true,
                  primary: true,
                  onTap: () => context.go('/pro'),
                ),
                const SizedBox(width: 8),
                const _StarPill(),
                const SizedBox(width: 8),
                IconPill(
                  icon: const Icon(Icons.menu_rounded, size: 20),
                  tooltip: 'Menu',
                  onTap: () => _openMobileMenu(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isActive(String path) {
    if (path == '/') {
      return currentPath == '/' || currentPath.startsWith('/orbs');
    }
    return currentPath.startsWith(path);
  }

  void _openMobileMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SiteColors.menu,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final link in _links)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      link.$1,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.go(link.$2);
                    },
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: SiteColors.accentStrong,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      context.go('/pro');
                    },
                    child: const Text('Get Pro'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.path,
    required this.active,
  });

  final String label;
  final String path;
  final bool active;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final background = widget.active || _hover
        ? const Color(0x12FFFFFF)
        : Colors.transparent;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: widget.active || _hover
                      ? SiteColors.text
                      : SiteColors.muted,
                ),
              ),
              if (widget.label == 'Studio') ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: SiteColors.proTint,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Pro',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: SiteColors.proInk,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StarPill extends StatelessWidget {
  const _StarPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: SiteColors.line),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 15, color: SiteColors.muted),
          SizedBox(width: 6),
          Text(
            '5.2k',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: SiteColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BrandPainter(),
    );
  }
}

class _BrandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SiteColors.text
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.67
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.62)
      ..cubicTo(
        size.width * 0.05,
        size.height * 0.28,
        size.width * 0.42,
        size.height * 0.12,
        size.width * 0.5,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.72,
        size.width * 0.9,
        size.height * 0.55,
        size.width * 0.78,
        size.height * 0.35,
      )
      ..cubicTo(
        size.width * 0.7,
        size.height * 0.2,
        size.width * 0.55,
        size.height * 0.3,
        size.width * 0.62,
        size.height * 0.48,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 900;
    final columns = [
      (
        'Libraries',
        <(String, String)>[
          ('Border beam', '/beam'),
          ('Thinking orbs', '/orbs'),
          ('Gooey', '/gooey'),
          ('Voice', '/voice'),
          ('Bot avatars', '/bots'),
          ('Liquid metal', '/metal'),
          ('Image generation', '/image'),
          ('Magnetic UI', '/magnetic'),
        ]
      ),
      (
        'Product',
        <(String, String)>[
          ('How to use', '/how-to-use'),
          ('Skill', '/skill'),
          ('Studio', '/studio'),
          ('Pricing', '/pro'),
        ]
      ),
      (
        'Legal & Account',
        <(String, String)>[
          ('Account', '/account'),
          ('Terms', '/terms'),
          ('Privacy', '/privacy'),
          ('Accessibility', '/accessibility'),
        ]
      ),
    ];
    return Container(
      padding: EdgeInsets.fromLTRB(compact ? 20 : 40, 48, compact ? 20 : 40, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (compact) ...[
                const _FooterBrand(),
                const SizedBox(height: 28),
                for (final column in columns) ...[
                  _FooterColumn(title: column.$1, links: column.$2),
                  const SizedBox(height: 20),
                ],
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(flex: 2, child: _FooterBrand()),
                    for (final column in columns)
                      Expanded(
                        child: _FooterColumn(
                          title: column.$1,
                          links: column.$2,
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 48),
              const Divider(color: SiteColors.line),
              const SizedBox(height: 18),
              const Text(
                'Made by Jakub Antalik. Libraries are MIT; Pro content is licensed.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: SiteColors.faint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BrandMark(size: 20),
            SizedBox(width: 7),
            Flexible(
              child: Text(
                'libraries.dev',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: SiteColors.text,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 260,
          child: Text(
            'High-crafted UI libraries for the interfaces agents and people share.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.links});

  final String title;
  final List<(String, String)> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: SiteColors.text,
                fontSize: 13,
              ),
        ),
        const SizedBox(height: 12),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.go(link.$2),
                child: Text(
                  link.$1,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    height: 1.3,
                    color: SiteColors.subtle,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}




