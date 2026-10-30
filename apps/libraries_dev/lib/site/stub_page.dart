import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import 'site_shell.dart';

class StubPage extends StatelessWidget {
  const StubPage({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final name = _titleFor(path);
    return SiteShell(
      currentPath: path,
      child: Padding(
        padding: const EdgeInsets.only(top: 72, bottom: 72),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Port pending', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 14),
            Text(name, style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: 560,
              child: Text(
                'This route is registered so the fork stays navigable. The first '
                'Flutter slice is dedicated to Thinking Orbs and its related '
                'surfaces.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                PillButton(
                  label: 'Open Thinking Orbs',
                  primary: true,
                  onTap: () => context.go('/orbs'),
                ),
                PillButton(
                  label: 'Back home',
                  onTap: () => context.go('/'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _titleFor(String path) {
    final segment = path.split('/').where((s) => s.isNotEmpty).toList();
    if (segment.isEmpty) return 'Libraries.dev';
    return segment
        .map((s) => s
            .split('-')
            .map((part) => part.isEmpty
                ? part
                : '${part[0].toUpperCase()}${part.substring(1)}')
            .join(' '))
        .join(' / ');
  }
}
