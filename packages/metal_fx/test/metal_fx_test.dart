import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metal_fx/metal_fx.dart';

void main() {
  testWidgets('renders every metal preset and variant', (tester) async {
    for (final preset in MetalFxPreset.values) {
      for (final variant in MetalFxVariant.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: MetalFx(
                  preset: preset,
                  variant: variant,
                  child: const Text('Metal'),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));
        expect(find.byType(MetalFx), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('renders MetalText with the shader fallback', (tester) async {
    for (final preset in MetalFxPreset.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MetalText('Libraries', preset: preset),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(MetalText), findsOneWidget);
      expect(find.text('Libraries'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}

