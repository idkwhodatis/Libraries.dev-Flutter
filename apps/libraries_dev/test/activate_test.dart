import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libraries_dev/data/backend.dart';
import 'package:libraries_dev/data/repositories.dart';
import 'package:libraries_dev/pages/content_pages.dart';
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

  testWidgets('activate forwards device, invite and signup parameters', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSiteTheme(),
        home: const ActivatePage(
          deviceCode: 'device-1',
          inviteToken: 'invite-1',
          signup: '1',
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, 'demo@libraries.dev');
    await tester.tap(find.text('Send code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final auth = backend.auth as MockAuthRepository;
    expect(auth.lastDeviceCode, 'device-1');
    expect(auth.lastInviteToken, 'invite-1');
    expect(auth.lastSignup, '1');
    expect(find.text('One-time code'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
