import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders every orb state at every tuned size', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSiteTheme(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Wrap(
              children: [
                for (final state in OrbState.values)
                  for (final size in const [64, 32, 20])
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: Center(
                        child: RepaintBoundary(
                          child: ThinkingOrb(
                            state: state,
                            size: size,
                            displaySize: 64,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
    expect(find.byType(ThinkingOrb), findsNWidgets(27));
  });

  testWidgets('renders light and dark pinned themes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSiteTheme(),
        home: Scaffold(
          body: Row(
            children: [
              for (final theme in const [OrbTheme.dark, OrbTheme.light])
                for (final size in const [64, 20])
                  SizedBox(
                    width: 96,
                    height: 96,
                    child: ThinkingOrb(
                      state: OrbState.composing,
                      size: size,
                      theme: theme,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });
}
