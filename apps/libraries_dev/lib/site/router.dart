import 'package:go_router/go_router.dart';

import '../pages/account_page.dart';
import '../pages/beam_page.dart';
import '../pages/bots_page.dart';
import '../pages/content_pages.dart';
import '../pages/gooey_page.dart';
import '../pages/home_page.dart';
import '../pages/image_page.dart';
import '../pages/magnetic_page.dart';
import '../pages/metal_page.dart';
import '../pages/orbs_carousel_page.dart';
import '../pages/orbs_page.dart';
import '../pages/studio_app_page.dart';
import '../pages/voice_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation:
      const String.fromEnvironment('START_ROUTE', defaultValue: '/'),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/beam',
      builder: (context, state) => const BeamPage(),
    ),
    GoRoute(
      path: '/bots',
      builder: (context, state) => const BotsPage(),
    ),
    GoRoute(
      path: '/gooey',
      builder: (context, state) => const GooeyPage(),
    ),
    GoRoute(
      path: '/image',
      builder: (context, state) => const ImagePage(),
    ),
    GoRoute(
      path: '/magnetic',
      builder: (context, state) => const MagneticPage(),
    ),
    GoRoute(
      path: '/metal',
      builder: (context, state) => const MetalPage(),
    ),
    GoRoute(
      path: '/voice',
      builder: (context, state) => const VoicePage(),
    ),
    GoRoute(
      path: '/orbs',
      builder: (context, state) => const OrbsPage(),
    ),
    GoRoute(
      path: '/orbs-carousel',
      builder: (context, state) => const OrbsCarouselPage(),
    ),
    GoRoute(
      path: '/studio/app',
      builder: (context, state) => const StudioAppPage(),
    ),
    GoRoute(
      path: '/account',
      builder: (context, state) => const AccountPage(),
    ),
    GoRoute(
      path: '/how-to-use',
      builder: (context, state) => const HowToUsePage(),
    ),
    GoRoute(
      path: '/skill',
      builder: (context, state) => const SkillPage(),
    ),
    GoRoute(
      path: '/introduction',
      builder: (context, state) => const IntroductionPage(),
    ),
    GoRoute(
      path: '/accessibility',
      builder: (context, state) => const AccessibilityPage(),
    ),
    GoRoute(
      path: '/pro',
      builder: (context, state) => const ProPage(),
    ),
    GoRoute(
      path: '/studio',
      builder: (context, state) => const StudioMarketingPage(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsPage(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyPage(),
    ),
    GoRoute(
      path: '/activate',
      builder: (context, state) => ActivatePage(
        deviceCode: state.uri.queryParameters['device'],
        inviteToken: state.uri.queryParameters['invite'],
        signup: state.uri.queryParameters['signup'],
      ),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) => const SuccessPage(),
    ),
    GoRoute(
      path: '/voice-phone',
      builder: (context, state) => const VoicePhonePage(),
    ),
    GoRoute(
      path: '/bot-carousel',
      builder: (context, state) => const BotCarouselPage(),
    ),
    GoRoute(
      path: '/skill-demo',
      builder: (context, state) => const SkillDemoPage(),
    ),
    GoRoute(
      path: '/skill-example',
      builder: (context, state) => SkillExamplePage(
        generic: state.uri.queryParameters['style'] == 'generic',
      ),
    ),
    GoRoute(
      path: '/404',
      builder: (context, state) => const NotFoundPage(path: '/404'),
    ),
    GoRoute(
      path: '/:page',
      builder: (context, state) => NotFoundPage(path: state.uri.path),
    ),
  ],
  errorBuilder: (context, state) => NotFoundPage(path: state.uri.path),
);










