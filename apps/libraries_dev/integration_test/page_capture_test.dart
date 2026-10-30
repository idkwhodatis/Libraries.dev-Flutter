import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:libraries_dev/pages/orbs_carousel_page.dart';
import 'package:libraries_dev/pages/orbs_page.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captures the orbs page at desktop width', (tester) async {
    await _capture(tester, const Size(1440, 900), 'flutter-orbs-1440x900.png');
  });

  testWidgets('captures the orbs page at mobile width', (tester) async {
    await _capture(tester, const Size(390, 844), 'flutter-orbs-390x844.png');
  });

  testWidgets('captures the carousel page at desktop width', (tester) async {
    await _captureCarousel(
      tester,
      const Size(1440, 900),
      'flutter-orbs-carousel-1440x900.png',
    );
  });

  testWidgets('captures the carousel page at mobile width', (tester) async {
    await _captureCarousel(
      tester,
      const Size(390, 844),
      'flutter-orbs-carousel-390x844.png',
    );
  });
}

Future<void> _capture(WidgetTester tester, Size size, String name) async {
  final inter = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'));
  await inter.load();
  final mono = FontLoader('RobotoMono')
    ..addFont(rootBundle.load('assets/fonts/RobotoMono-Regular.ttf'));
  await mono.load();
  OrbClock.instance.freeze(0.6);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    OrbClock.instance.unfreeze();
  });

  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      theme: buildSiteTheme(),
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: key,
        child: const TickerMode(
          enabled: false,
          child: OrbsPage(),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 80));
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final dir = Directory('../../reference/captures/pages')
    ..createSync(recursive: true);
  File('${dir.path}/$name').writeAsBytesSync(data!.buffer.asUint8List());
  image.dispose();
  await tester.pumpWidget(const SizedBox());
}

Future<void> _captureCarousel(
  WidgetTester tester,
  Size size,
  String name,
) async {
  final inter = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'));
  await inter.load();
  final mono = FontLoader('RobotoMono')
    ..addFont(rootBundle.load('assets/fonts/RobotoMono-Regular.ttf'));
  await mono.load();
  OrbClock.instance.freeze(0.6);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    OrbClock.instance.unfreeze();
  });

  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      theme: buildSiteTheme(),
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: key,
        child: const TickerMode(
          enabled: false,
          child: OrbsCarouselPage(),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 80));
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  final dir = Directory('../../reference/captures/pages')
    ..createSync(recursive: true);
  File('${dir.path}/$name').writeAsBytesSync(data!.buffer.asUint8List());
  image.dispose();
  await tester.pumpWidget(const SizedBox());
}
