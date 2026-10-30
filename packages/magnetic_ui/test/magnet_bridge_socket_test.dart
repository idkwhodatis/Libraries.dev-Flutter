import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:magnetic_ui/magnetic_ui.dart';

void main() {
  test('handshakes and parses live bridge messages', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final bridge = MagnetBridge(
      endpoint: Uri.parse('ws://127.0.0.1:${server.port}'),
    );
    addTearDown(() async {
      await bridge.dispose();
      await server.close(force: true);
    });

    final connected = bridge.connect();
    final request = await server.first;
    final socket = await WebSocketTransformer.upgrade(request);
    expect(await connected, isTrue);
    expect(bridge.state, MagnetBridgeState.open);

    final handshake = jsonDecode(await socket.first as String);
    expect(handshake, {'type': 'hello'});

    final frame = bridge.frames.first;
    final gesture = bridge.gestures.first;
    socket.add(jsonEncode({
      'type': 'hello',
      'manufacturer': 'Google',
      'model': 'Pixel',
      'version': 5,
    }));
    socket.add(jsonEncode({
      'type': 'model-hello',
      'screenDp': [1080, 2400],
      'grabStage': 2,
      'face': 1,
      'strength': 0.7,
      'sensorDp': [540, 1200],
      'model': true,
    }));
    socket.add(jsonEncode({
      'type': 'm',
      't': 3.5,
      'pos': [100, 200],
      'sp': 0.2,
      'h': 800,
      'p': 0.9,
      'pull': 0.4,
      's': 0.8,
      'd': [1, 2, 3],
      'tc': false,
      'cal': true,
    }));
    socket.add(jsonEncode({
      'type': 'gesture',
      'g': 'swipe',
      'dir': [0.5, -0.5],
      'speed': 1.4,
    }));

    final firstFrame = await frame;
    expect(firstFrame.position?.x, 100);
    expect(firstFrame.calibrating, isTrue);
    final firstGesture = await gesture;
    expect(firstGesture.type, 'swipe');
    expect(firstGesture.direction?.y, -0.5);

    await Future<void>.delayed(const Duration(milliseconds: 80));
    expect(bridge.hello?.device, 'Google Pixel');
    expect(bridge.hello?.version, 5);
    expect(bridge.modelHello?.model, isTrue);
    expect(bridge.modelHello?.sensorDp?.y, 1200);
  });
}



