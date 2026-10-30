import 'package:flutter_test/flutter_test.dart';
import 'package:magnetic_ui/magnetic_ui.dart';

void main() {
  test('parses a bridge frame', () {
    final frame = MagnetFrame.fromJson({
      't': 12.5,
      'pos': [100.0, 200.0],
      'sp': 0.4,
      'h': 800.0,
      'p': 0.9,
      'pull': 0.3,
      's': 0.7,
      'd': [1, 2, 3],
      'tc': false,
      'cal': true,
    });
    expect(frame.position?.x, 100);
    expect(frame.position?.y, 200);
    expect(frame.pull, 0.3);
    expect(frame.delta, [1, 2, 3]);
    expect(frame.calibrating, isTrue);
  });

  test('parses gestures with speed and direction', () {
    final gesture = MagnetGesture.fromJson({
      'g': 'swipe',
      'dir': [0.5, -0.5],
      'speed': 1.2,
    });
    expect(gesture.type, 'swipe');
    expect(gesture.direction?.x, 0.5);
    expect(gesture.speed, 1.2);
  });

  test('parses the model hello and converts page coordinates', () {
    final hello = MagnetModelHello.fromJson({
      'screenDp': [1080, 2400],
      'grabStage': 2,
      'face': -1,
      'strength': 0.8,
      'sensorDp': [540, 1200],
      'model': true,
    });
    expect(hello.screenDp.x, 1080);
    expect(hello.sensorDp?.y, 1200);
    expect(hello.model, isTrue);

    final bridge = MagnetBridge()..clientOffset = const MagnetPoint(0, 64);
    expect(bridge.toClient(const MagnetPoint(10, 100)).y, 36);
    expect(bridge.toScreen(const MagnetPoint(10, 36)).y, 100);
  });
}

