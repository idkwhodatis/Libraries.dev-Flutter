import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magnetic_ui/magnetic_ui.dart';

void main() {
  testWidgets('pulls a surface toward the pointer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 200,
              child: MagneticSurface(
                onTap: () {},
                child: Container(color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
    );
    final center = tester.getCenter(find.byType(MagneticSurface));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: center);
    await tester.pump();
    await gesture.moveTo(center + const Offset(60, 30));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
    await gesture.removePointer();
    await tester.pumpWidget(const SizedBox());
  });
}
