import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class MagnetPoint {
  const MagnetPoint(this.x, this.y);

  final double x;
  final double y;

  factory MagnetPoint.fromJson(List<dynamic> value) {
    return MagnetPoint(
      (value[0] as num).toDouble(),
      (value[1] as num).toDouble(),
    );
  }

  Map<String, double> toJson() => {'x': x, 'y': y};
}

class MagnetFrame {
  const MagnetFrame({
    required this.t,
    required this.position,
    required this.spread,
    required this.height,
    required this.presence,
    required this.pull,
    required this.strength,
    required this.delta,
    required this.tooClose,
    required this.calibrating,
  });

  final double t;
  final MagnetPoint? position;
  final double spread;
  final double? height;
  final double presence;
  final double pull;
  final double strength;
  final List<double> delta;
  final bool tooClose;
  final bool calibrating;

  factory MagnetFrame.fromJson(Map<String, dynamic> json) {
    final pos = json['pos'] as List<dynamic>?;
    final delta = json['d'] as List<dynamic>?;
    return MagnetFrame(
      t: (json['t'] as num?)?.toDouble() ?? 0,
      position: pos == null ? null : MagnetPoint.fromJson(pos),
      spread: (json['sp'] as num?)?.toDouble() ?? 0,
      height: (json['h'] as num?)?.toDouble(),
      presence: (json['p'] as num?)?.toDouble() ?? 1,
      pull: (json['pull'] as num?)?.toDouble() ?? 0,
      strength: (json['s'] as num?)?.toDouble() ?? 0,
      delta: [
        for (final value in delta ?? const []) (value as num).toDouble(),
      ],
      tooClose: json['tc'] == true,
      calibrating: json['cal'] == true,
    );
  }
}

class MagnetGesture {
  const MagnetGesture({
    required this.type,
    this.at,
    this.speed,
    this.direction,
  });

  final String type;
  final MagnetPoint? at;
  final double? speed;
  final MagnetPoint? direction;

  factory MagnetGesture.fromJson(Map<String, dynamic> json) {
    final at = json['at'] as List<dynamic>?;
    final dir = json['dir'] as List<dynamic>?;
    return MagnetGesture(
      type: json['g']?.toString() ?? 'gesture',
      at: at == null ? null : MagnetPoint.fromJson(at),
      speed: (json['speed'] as num?)?.toDouble(),
      direction: dir == null ? null : MagnetPoint.fromJson(dir),
    );
  }
}

class MagnetHello {
  const MagnetHello({required this.device, required this.version});

  final String device;
  final int version;
}

class MagnetModelHello {
  const MagnetModelHello({
    required this.screenDp,
    this.grabStage,
    this.face,
    this.strength,
    this.sensorDp,
    required this.model,
  });

  final MagnetPoint screenDp;
  final int? grabStage;
  final int? face;
  final double? strength;
  final MagnetPoint? sensorDp;
  final bool model;

  factory MagnetModelHello.fromJson(Map<String, dynamic> json) {
    final screen = json['screenDp'] as List<dynamic>?;
    final sensor = json['sensorDp'] as List<dynamic>?;
    return MagnetModelHello(
      screenDp: screen == null
          ? const MagnetPoint(0, 0)
          : MagnetPoint.fromJson(screen),
      grabStage: (json['grabStage'] as num?)?.toInt(),
      face: (json['face'] as num?)?.toInt(),
      strength: (json['strength'] as num?)?.toDouble(),
      sensorDp: sensor == null ? null : MagnetPoint.fromJson(sensor),
      model: json['model'] == true,
    );
  }
}

enum MagnetBridgeState { idle, connecting, open, failed }

class MagnetBridge {
  MagnetBridge({Uri? endpoint})
      : endpoint = endpoint ?? Uri.parse('ws://127.0.0.1:47613');

  final Uri endpoint;
  final _frames = StreamController<MagnetFrame>.broadcast();
  final _gestures = StreamController<MagnetGesture>.broadcast();
  final _states = StreamController<MagnetBridgeState>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  MagnetBridgeState _state = MagnetBridgeState.idle;
  MagnetHello? hello;
  MagnetModelHello? modelHello;
  MagnetPoint clientOffset = const MagnetPoint(0, 0);

  Stream<MagnetFrame> get frames => _frames.stream;
  Stream<MagnetGesture> get gestures => _gestures.stream;
  Stream<MagnetBridgeState> get states => _states.stream;
  MagnetBridgeState get state => _state;

  MagnetPoint toClient(MagnetPoint point) {
    return MagnetPoint(point.x - clientOffset.x, point.y - clientOffset.y);
  }

  MagnetPoint toScreen(MagnetPoint point) {
    return MagnetPoint(point.x + clientOffset.x, point.y + clientOffset.y);
  }

  Future<bool> connect() async {
    if (_state == MagnetBridgeState.open) return true;
    if (_state == MagnetBridgeState.connecting) return false;
    _setState(MagnetBridgeState.connecting);
    try {
      final channel = WebSocketChannel.connect(endpoint);
      await channel.ready;
      _channel = channel;
      _subscription = channel.stream.listen(
        _receive,
        onError: (_) => _fail(),
        onDone: _fail,
        cancelOnError: false,
      );
      _setState(MagnetBridgeState.open);
      _send(const {'type': 'hello'});
      return true;
    } catch (_) {
      _fail();
      return false;
    }
  }

  void zero() => _send({'type': 'calibrate'});

  void setMagnet({
    required int face,
    required double strength,
    required MagnetPoint sensor,
  }) {
    _send({
      'type': 'set-magnet',
      'face': face,
      'strength': strength,
      'sensor': [sensor.x, sensor.y],
    });
  }

  void _send(Map<String, Object?> value) {
    _channel?.sink.add(jsonEncode(value));
  }

  void _receive(dynamic message) {
    if (message is! String) return;
    try {
      final json = jsonDecode(message) as Map<String, dynamic>;
      switch (json['type']) {
        case 'm':
          _frames.add(MagnetFrame.fromJson(json));
        case 'gesture':
          _gestures.add(MagnetGesture.fromJson(json));
        case 'hello':
          hello = MagnetHello(
            device:
                '${json['manufacturer'] ?? ''} ${json['model'] ?? ''}'.trim(),
            version: (json['version'] as num?)?.toInt() ?? 0,
          );
        case 'model-hello':
          modelHello = MagnetModelHello.fromJson(json);
      }
    } catch (_) {}
  }

  void _fail() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _setState(MagnetBridgeState.failed);
  }

  void _setState(MagnetBridgeState state) {
    _state = state;
    _states.add(state);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    await _frames.close();
    await _gestures.close();
    await _states.close();
  }
}


