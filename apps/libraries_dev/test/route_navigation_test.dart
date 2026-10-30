import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libraries_dev/app.dart';
import 'package:libraries_dev/site/router.dart';
import 'package:thinking_orbs/thinking_orbs.dart';

void main() {
  testWidgets('every route is reachable through the app router', (tester) async {
    OrbClock.instance.freeze(0.6);
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpWidget(const LibrariesApp());
    await tester.pump();

    const paths = [
      '/',
      '/orbs',
      '/orbs-carousel',
      '/beam',
      '/bots',
      '/gooey',
      '/voice',
      '/metal',
      '/image',
      '/magnetic',
      '/studio',
      '/studio/app',
      '/account',
      '/introduction',
      '/accessibility',
      '/terms',
      '/privacy',
      '/how-to-use',
      '/skill',
      '/skill-demo',
      '/skill-example',
      '/pro',
      '/activate',
      '/success',
      '/voice-phone',
      '/bot-carousel',
      '/404',
    ];

    for (final path in paths) {
      appRouter.go(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(tester.takeException(), isNull, reason: path);
    }

    appRouter.go('/');
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    await tester.binding.setSurfaceSize(null);
    OrbClock.instance.unfreeze();
  });
}
