import 'package:flutter/material.dart';
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
import 'package:libraries_dev/pages/orbs_carousel_page.dart';
import 'package:libraries_dev/pages/orbs_page.dart';
import 'package:libraries_dev/pages/studio_app_page.dart';
import 'package:libraries_dev/pages/voice_page.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('every implemented route builds', (tester) async {
    OrbClock.instance.freeze(0.6);
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    final pages = <Widget>[
      const HomePage(),
      const OrbsPage(),
      const OrbsCarouselPage(),
      const BeamPage(),
      const BotsPage(),
      const GooeyPage(),
      const VoicePage(),
      const MetalPage(),
      const ImagePage(),
      const MagneticPage(),
      const StudioAppPage(),
      const AccountPage(),
      const IntroductionPage(),
      const AccessibilityPage(),
      const TermsPage(),
      const PrivacyPage(),
      const HowToUsePage(),
      const SkillPage(),
      const ProPage(),
      const StudioMarketingPage(),
      const ActivatePage(),
      const SuccessPage(),
      const VoicePhonePage(),
      const BotCarouselPage(),
    ];
    for (final page in pages) {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildSiteTheme(),
          debugShowCheckedModeBanner: false,
          home: page,
        ),
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
    await tester.binding.setSurfaceSize(null);
    OrbClock.instance.unfreeze();
  });
}
