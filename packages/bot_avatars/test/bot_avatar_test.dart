import 'package:bot_avatars/bot_avatars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders every bot type and state', (tester) async {
    for (final type in BotAvatarType.values) {
      for (final state in BotAvatarState.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: BotAvatar(type: type, state: state, size: 96),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));
        expect(find.byType(BotAvatar), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
