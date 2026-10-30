import 'package:border_beam/border_beam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders every beam family', (tester) async {
    for (final size in BorderBeamSize.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BorderBeam(
                size: size,
                colorVariant: BorderBeamColorVariant.ocean,
                child: const SizedBox(width: 220, height: 88),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.byType(BorderBeam), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('renders every color variant', (tester) async {
    for (final variant in BorderBeamColorVariant.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: BorderBeam(
                colorVariant: variant,
                child: const SizedBox(width: 220, height: 88),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
