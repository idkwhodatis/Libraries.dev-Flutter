import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class OrbClock {
  OrbClock._();

  static final OrbClock instance = OrbClock._();

  final Stopwatch _watch = Stopwatch()..start();
  final Set<void Function()> _listeners = <void Function()>{};
  bool _registered = false;
  double? _frozenTime;

  double get elapsedSeconds =>
      _frozenTime ?? _watch.elapsedMicroseconds / 1000000;

  bool get isFrozen => _frozenTime != null;

  void add(void Function() listener) {
    _listeners.add(listener);
    _ensureRegistered();
    if (!isFrozen) SchedulerBinding.instance.scheduleFrame();
  }

  void remove(void Function() listener) {
    _listeners.remove(listener);
  }

  @visibleForTesting
  void freeze(double time) {
    _frozenTime = time;
  }

  @visibleForTesting
  void unfreeze() {
    _frozenTime = null;
    if (_listeners.isNotEmpty) SchedulerBinding.instance.scheduleFrame();
  }

  void _ensureRegistered() {
    if (_registered) return;
    _registered = true;
    SchedulerBinding.instance.addPersistentFrameCallback(_onFrame);
  }

  void _onFrame(Duration _) {
    if (isFrozen || _listeners.isEmpty) return;
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
    if (_listeners.isNotEmpty) {
      SchedulerBinding.instance.scheduleFrame();
    }
  }
}
