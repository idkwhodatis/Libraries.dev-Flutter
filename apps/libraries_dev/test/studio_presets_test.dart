import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libraries_dev/data/backend.dart';
import 'package:libraries_dev/pages/studio_app_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Studio saves a preset', (tester) async {
    SharedPreferences.setMockInitialValues({});
    for (final preset in await backend.presets.list('thinking-orbs')) {
      await backend.presets.delete(preset.id);
    }
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() async {
      for (final preset in await backend.presets.list('thinking-orbs')) {
        await backend.presets.delete(preset.id);
      }
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: buildSiteTheme(),
        debugShowCheckedModeBanner: false,
        home: const StudioAppPage(),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Save preset'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('My orb'), findsOneWidget);

    await tester.ensureVisible(find.text('Install'));
    await tester.tap(find.text('Install'));
    await tester.pump();
    expect(find.text('npm install thinking-orbs'), findsOneWidget);
    await tester.ensureVisible(find.text('SwiftUI'));
    await tester.tap(find.text('SwiftUI'));
    await tester.pump();
    expect(
      find.textContaining('github.com/Jakubantalik/Libraries.dev'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Usage'));
    await tester.tap(find.text('Usage'));
    await tester.pump();
    expect(find.textContaining('ThinkingOrb(state'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}


