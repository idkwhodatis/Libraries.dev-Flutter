import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:img_fx/img_fx.dart';

void main() {
  testWidgets('renders a loading surface without images', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 240,
              height: 180,
              child: ImageGeneration(images: []),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));
    expect(find.byType(ImageGeneration), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
