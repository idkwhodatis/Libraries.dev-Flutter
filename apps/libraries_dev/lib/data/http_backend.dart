import 'dart:convert';
import 'dart:io';

import 'api_client.dart';
import 'repositories.dart';

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this._client);

  final ApiClient _client;

  @override
  Future<AccountSession?> me() async {
    try {
      final json = await _client.getJson('/me');
      if (json['authenticated'] == false) return null;
      final entitlements = json['entitlements'] as Map<String, dynamic>?;
      final business = entitlements?['business'] == true;
      final pro = entitlements?['pro'] == true;
      return AccountSession(
        email: json['email'] as String? ?? 'account@libraries.dev',
        plan: business
            ? AccountPlan.business
            : pro
                ? AccountPlan.pro
                : AccountPlan.free,
        lifetime: json['lifetime'] == true,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> requestCode(
    String email, {
    String? deviceCode,
    String? inviteToken,
    String? signup,
  }) async {
    final body = <String, Object?>{'email': email};
    if (deviceCode != null) body['device_code'] = deviceCode;
    if (inviteToken != null) body['invite_token'] = inviteToken;
    if (signup != null) body['signup'] = signup;
    await _client.postJson('/auth/code/request', body: body);
  }

  @override
  Future<AccountSession?> verifyCode(String email, String code) async {
    await _client.postJson(
      '/auth/code',
      body: {'email': email, 'code': code},
    );
    return me();
  }

  @override
  Future<void> signOut({bool allDevices = false}) async {
    try {
      await _client.postJson(
        '/auth/logout',
        query: allDevices ? const {'all': '1'} : null,
      );
    } catch (_) {}
    await _client.clearSession();
  }
}

class HttpPresetsRepository implements PresetsRepository {
  HttpPresetsRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<StudioPreset>> list(String library) async {
    try {
      final json = await _client.getJson(
        '/presets',
        query: {'library': library},
      );
      final rows = (json['presets'] as List<dynamic>? ?? const []);
      return [
        for (final row in rows)
          StudioPreset.fromJson(Map<String, Object?>.from(row as Map)),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<StudioPreset> save(StudioPreset preset) async {
    await _client.postJson('/presets', body: preset.toJson());
    return preset;
  }

  @override
  Future<void> delete(String id) async {
    await _client.postJson('/presets/delete', body: {'id': id});
  }
}

class HttpStudioAgent implements StudioAgent {
  HttpStudioAgent(this._client);

  final ApiClient _client;

  @override
  Stream<StudioEvent> chat(List<String> messages) async* {
    try {
      final response = await _client.streamJson(
        '/studio/chat',
        body: {
          'messages': [
            for (final message in messages) {'role': 'user', 'content': message},
          ],
        },
      );
      if (response.statusCode >= 400) {
        yield StudioEvent.text('Agent request failed (${response.statusCode}).');
        return;
      }
      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      await for (final line in lines) {
        if (!line.startsWith('data:')) continue;
        final raw = line.substring(5).trim();
        if (raw.isEmpty) continue;
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final type = json['type']?.toString() ?? 'text';
        final text = json['text']?.toString() ?? '';
        final params = json['params'] as Map<String, dynamic>?;
        if (type == 'params' && params != null) {
          yield StudioEvent.params(
            text,
            Map<String, Object?>.from(params),
          );
        } else if (type == 'error') {
          yield StudioEvent.text(text.isEmpty ? 'Agent error.' : text);
        } else {
          yield StudioEvent.text(text);
        }
      }
    } catch (error) {
      yield StudioEvent.text('Agent unavailable: $error');
    }
  }
}

class HttpCommerceRepository implements CommerceRepository {
  HttpCommerceRepository(this._client);

  final ApiClient _client;

  @override
  Future<CheckoutResult> checkout(AccountPlan plan) async {
    final json = await _client.postJson('/checkout', body: {'plan': plan.name});
    return CheckoutResult(url: json['url'] as String? ?? '/pro');
  }

  @override
  Future<String> portal() async {
    final json = await _client.postJson('/portal');
    return json['url'] as String? ?? '/account';
  }
}

class HttpDownloadsRepository implements DownloadsRepository {
  HttpDownloadsRepository(this._client);

  final ApiClient _client;

  @override
  Future<String> magnetModel() async {
    return _client.baseUrl.replace(path: '/models/magnet').toString();
  }

  @override
  Future<File> downloadMagnetModel(Directory directory) {
    return _client.download(
      '/models/magnet',
      File('${directory.path}/Magnet.mfxl'),
    );
  }
}

class HttpBackend implements Backend {
  HttpBackend(ApiClient client)
      : auth = HttpAuthRepository(client),
        presets = HttpPresetsRepository(client),
        agent = HttpStudioAgent(client),
        commerce = HttpCommerceRepository(client),
        downloads = HttpDownloadsRepository(client);

  @override
  final HttpAuthRepository auth;
  @override
  final HttpPresetsRepository presets;
  @override
  final HttpStudioAgent agent;
  @override
  final HttpCommerceRepository commerce;
  @override
  final HttpDownloadsRepository downloads;
}





