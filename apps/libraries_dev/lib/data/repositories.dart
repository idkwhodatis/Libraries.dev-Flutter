import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

enum AccountPlan { free, pro, business }

class AccountSession {
  const AccountSession({
    required this.email,
    required this.plan,
    this.lifetime = false,
  });

  final String email;
  final AccountPlan plan;
  final bool lifetime;

  bool get isPro => plan == AccountPlan.pro || plan == AccountPlan.business;
}

abstract class AuthRepository {
  Future<AccountSession?> me();
  Future<void> requestCode(
    String email, {
    String? deviceCode,
    String? inviteToken,
    String? signup,
  });
  Future<AccountSession?> verifyCode(String email, String code);
  Future<void> signOut({bool allDevices = false});
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository({AccountPlan plan = AccountPlan.pro})
      : _session = AccountSession(
          email: 'demo@libraries.dev',
          plan: plan,
          lifetime: plan == AccountPlan.pro,
        );

  AccountSession _session;
  bool _signedOut = false;
  String? lastDeviceCode;
  String? lastInviteToken;
  String? lastSignup;

  AccountSession get session => _session;

  set plan(AccountPlan value) {
    _session = AccountSession(
      email: _session.email,
      plan: value,
      lifetime: value == AccountPlan.pro,
    );
  }

  @override
  Future<AccountSession?> me() async => _signedOut ? null : _session;

  @override
  Future<void> requestCode(
    String email, {
    String? deviceCode,
    String? inviteToken,
    String? signup,
  }) async {
    lastDeviceCode = deviceCode;
    lastInviteToken = inviteToken;
    lastSignup = signup;
  }

  @override
  Future<AccountSession?> verifyCode(String email, String code) async {
    _signedOut = false;
    return _session;
  }

  @override
  Future<void> signOut({bool allDevices = false}) async {
    _signedOut = true;
  }
}

class StudioPreset {
  const StudioPreset({
    required this.id,
    required this.library,
    required this.name,
    required this.params,
  });

  final String id;
  final String library;
  final String name;
  final Map<String, Object?> params;

  Map<String, Object?> toJson() => {
        'id': id,
        'library': library,
        'name': name,
        'params': params,
      };

  factory StudioPreset.fromJson(Map<String, Object?> json) => StudioPreset(
        id: json['id'] as String,
        library: json['library'] as String,
        name: json['name'] as String,
        params: (json['params'] as Map<String, Object?>?) ?? const {},
      );
}

abstract class PresetsRepository {
  Future<List<StudioPreset>> list(String library);
  Future<StudioPreset> save(StudioPreset preset);
  Future<void> delete(String id);
}

class MockPresetsRepository implements PresetsRepository {
  final List<StudioPreset> _presets = <StudioPreset>[];
  static const _key = 'ldev:studio:presets';

  Future<void> _load() async {
    if (_presets.isNotEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final decoded = jsonDecode(raw) as List<dynamic>;
    _presets.addAll(
      decoded.map(
        (item) => StudioPreset.fromJson(item as Map<String, Object?>),
      ),
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode([for (final preset in _presets) preset.toJson()]),
    );
  }

  @override
  Future<List<StudioPreset>> list(String library) async {
    await _load();
    return _presets.where((preset) => preset.library == library).toList();
  }

  @override
  Future<StudioPreset> save(StudioPreset preset) async {
    await _load();
    final index = _presets.indexWhere((item) => item.id == preset.id);
    if (index >= 0) {
      _presets[index] = preset;
    } else {
      _presets.add(preset);
    }
    await _persist();
    return preset;
  }

  @override
  Future<void> delete(String id) async {
    await _load();
    _presets.removeWhere((preset) => preset.id == id);
    await _persist();
  }
}

class StudioEvent {
  const StudioEvent.status(this.text) : type = 'status', params = null;
  const StudioEvent.text(this.text) : type = 'text', params = null;
  const StudioEvent.params(this.text, this.params) : type = 'params';

  final String type;
  final String text;
  final Map<String, Object?>? params;
}

abstract class StudioAgent {
  Stream<StudioEvent> chat(List<String> messages);
}

class MockStudioAgent implements StudioAgent {
  @override
  Stream<StudioEvent> chat(List<String> messages) async* {
    yield const StudioEvent.status('Reading your orb...');
    await Future<void>.delayed(const Duration(milliseconds: 420));
    yield const StudioEvent.text(
      'I tuned the orb toward a quieter working state.',
    );
    await Future<void>.delayed(const Duration(milliseconds: 260));
    yield const StudioEvent.params(
      'Applied 1 change',
      {'state': 'working', 'speed': 0.85, 'dots': 0.9},
    );
  }
}

class CheckoutResult {
  const CheckoutResult({required this.url});

  final String url;
}

abstract class CommerceRepository {
  Future<CheckoutResult> checkout(AccountPlan plan);
  Future<String> portal();
}

class MockCommerceRepository implements CommerceRepository {
  @override
  Future<CheckoutResult> checkout(AccountPlan plan) async {
    return const CheckoutResult(url: 'https://libraries.dev/pro');
  }

  @override
  Future<String> portal() async => 'https://libraries.dev/account';
}

abstract class DownloadsRepository {
  Future<String> magnetModel();
  Future<File> downloadMagnetModel(Directory directory);
}

class MockDownloadsRepository implements DownloadsRepository {
  @override
  Future<String> magnetModel() async {
    throw UnsupportedError('Model downloads are not available in the local mock');
  }

  @override
  Future<File> downloadMagnetModel(Directory directory) {
    throw UnsupportedError('Model downloads are not available in the local mock');
  }
}

abstract class Backend {
  AuthRepository get auth;
  PresetsRepository get presets;
  StudioAgent get agent;
  CommerceRepository get commerce;
  DownloadsRepository get downloads;
}

class MockBackend implements Backend {
  MockBackend({
    AccountPlan plan = AccountPlan.pro,
  })  : auth = MockAuthRepository(plan: plan),
        presets = MockPresetsRepository(),
        agent = MockStudioAgent(),
        commerce = MockCommerceRepository(),
        downloads = MockDownloadsRepository();

  @override
  final MockAuthRepository auth;
  @override
  final MockPresetsRepository presets;
  @override
  final MockStudioAgent agent;
  @override
  final MockCommerceRepository commerce;
  @override
  final MockDownloadsRepository downloads;
}





