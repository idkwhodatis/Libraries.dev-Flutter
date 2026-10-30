import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets('renders the orb and exposes its semantic label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSiteTheme(),
        home: const Scaffold(
          body: Center(
            child: ThinkingOrb(state: OrbState.searching, size: 64),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.byType(ThinkingOrb), findsOneWidget);
    expect(find.bySemanticsLabel('Searching…'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('honors a custom label and explicit dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSiteTheme(),
        home: const Scaffold(
          body: Center(
            child: ThinkingOrb(
              state: OrbState.solving,
              size: 20,
              theme: OrbTheme.light,
              semanticLabel: 'Analysing repository',
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    expect(find.bySemanticsLabel('Analysing repository'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('renders at high device pixel ratio without exceptions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetDevicePixelRatio);
    debugOrbCappedRasterCount = 0;
    final watch = Stopwatch()..start();
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSiteTheme(),
        home: const Scaffold(
          body: Center(
            child: ThinkingOrb(state: OrbState.composing, size: 64),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));
    watch.stop();
    expect(tester.takeException(), isNull);
    expect(debugOrbCappedRasterCount, greaterThan(0));
    expect(watch.elapsedMilliseconds, lessThan(2000));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('gravity field accepts mouse hover', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSiteTheme(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: OrbGravityField(
                state: OrbState.working,
                size: 64,
                displaySize: 64,
                enabled: true,
              ),
            ),
          ),
        ),
      ),
    );
    final center = tester.getCenter(find.byType(OrbGravityField));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: center);
    await tester.pump();
    await gesture.moveTo(center + const Offset(30, 20));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await gesture.removePointer();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
