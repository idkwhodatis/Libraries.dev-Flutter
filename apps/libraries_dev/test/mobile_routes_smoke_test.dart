import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libraries_dev/pages/account_page.dart';
import 'package:libraries_dev/pages/beam_page.dart';
import 'package:libraries_dev/pages/bots_page.dart';
import 'package:libraries_dev/pages/content_pages.dart';
import 'package:libraries_dev/pages/gooey_page.dart';
import 'package:libraries_dev/pages/home_page.dart';
import 'package:libraries_dev/pages/image_page.dart';
import 'package:libraries_dev/pages/magnetic_page.dart';
import 'package:libraries_dev/pages/metal_page.dart';
import 'package:libraries_dev/pages/orbs_page.dart';
import 'package:libraries_dev/pages/studio_app_page.dart';
import 'package:libraries_dev/pages/voice_page.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  setUpAll(() async {
    final inter = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'));
    await inter.load();
    final mono = FontLoader('RobotoMono')
      ..addFont(rootBundle.load('assets/fonts/RobotoMono-Regular.ttf'));
    await mono.load();
  });

  testWidgets('key routes build at mobile width', (tester) async {
    OrbClock.instance.freeze(0.6);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final pages = <Widget>[
      const HomePage(),
      const OrbsPage(),
      const BeamPage(),
      const BotsPage(),
      const GooeyPage(),
      const VoicePage(),
      const MetalPage(),
      const ImagePage(),
      const MagneticPage(),
      const StudioAppPage(),
      const AccountPage(),
      const ProPage(),
      const StudioMarketingPage(),
    ];
    for (final page in pages) {
      await tester.pumpWidget(
        MaterialApp(theme: buildSiteTheme(), home: page),
      );
      await tester.pump(const Duration(milliseconds: 40));
      expect(
        tester.takeException(),
        isNull,
        reason: '${page.runtimeType}',
      );
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
    OrbClock.instance.unfreeze();
  });
}
