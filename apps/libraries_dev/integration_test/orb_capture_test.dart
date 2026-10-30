import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:thinking_orbs/thinking_orbs.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('captures the orb parity matrix', (tester) async {
    final directory = Directory('../../reference/captures/orbs')
      ..createSync(recursive: true);
    const times = [0.6, 1.7, 3.3, 5.1];

    for (final state in OrbState.values) {
      for (final size in const [64, 20]) {
        for (final theme in const [OrbTheme.dark, OrbTheme.light]) {
          for (final t in times) {
            final key = GlobalKey();
            await tester.pumpWidget(
              MaterialApp(
                theme: buildSiteTheme(),
                debugShowCheckedModeBanner: false,
                home: Center(
                  child: RepaintBoundary(
                    key: key,
                    child: ColoredBox(
                      color: theme == OrbTheme.dark
                          ? SiteColors.page
                          : const Color(0xFFFDFDFD),
                      child: ThinkingOrb(
                        state: state,
                        size: size,
                        displaySize: size.toDouble(),
                        theme: theme,
                        paused: true,
                        debugTime: t,
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pump();
            final boundary =
                key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final data = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final name =
                '${state.name}-$size-${theme.name}-${t.toStringAsFixed(1)}.png';
            File('${directory.path}/$name').writeAsBytesSync(
              data!.buffer.asUint8List(),
            );
            image.dispose();
          }
        }
      }
    }
    await tester.pumpWidget(const SizedBox());
  });
}
