import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_glow/voice_glow.dart';

void main() {
  testWidgets('renders every voice type and variant', (tester) async {
    for (final type in VoiceBeamType.values) {
      for (final variant in VoiceBeamColorVariant.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  height: 140,
                  child: VoiceBeam(
                    type: type,
                    colorVariant: variant,
                    level: 0.6,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));
        expect(find.byType(VoiceBeam), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
