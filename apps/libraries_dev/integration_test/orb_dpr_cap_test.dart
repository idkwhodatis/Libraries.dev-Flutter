import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('caps orb rasterization at DPR 2', (tester) async {
    tester.view.devicePixelRatio = 3;
    debugOrbCappedRasterCount = 0;
    final key = GlobalKey();
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      debugOrbCappedRasterCount = 0;
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSiteTheme(),
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: const ThinkingOrb(
                state: OrbState.composing,
                size: 64,
                debugTime: 0.6,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 120));
    expect(tester.takeException(), isNull);
    expect(debugOrbCappedRasterCount, greaterThan(0));
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    expect(bytes, isNotNull);
    expect(
      [
        for (var i = 3; i < bytes!.lengthInBytes; i += 4) bytes.getUint8(i),
      ].any((alpha) => alpha > 0),
      isTrue,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
