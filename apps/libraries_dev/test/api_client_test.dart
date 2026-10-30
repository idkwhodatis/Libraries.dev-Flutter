import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:libraries_dev/data/api_client.dart';
import 'package:libraries_dev/data/http_backend.dart';
import 'package:libraries_dev/data/repositories.dart';

void main() {
  test('stores the session cookie and sends it on later calls', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      if (request.url.path == '/me') {
        return http.Response(
          jsonEncode({
            'authenticated': true,
            'email': 'demo@libraries.dev',
            'entitlements': {'pro': true},
            'lifetime': true,
          }),
          200,
          headers: {'set-cookie': 'lp_session=abc123; Path=/; HttpOnly'},
        );
      }
      expect(request.headers['cookie'], 'lp_session=abc123');
      return http.Response(jsonEncode({'presets': []}), 200);
    });

    final api = ApiClient(
      baseUrl: Uri.parse('https://api.example.test'),
      client: client,
    );
    final auth = HttpAuthRepository(api);
    final session = await auth.me();
    expect(session?.email, 'demo@libraries.dev');
    expect(session?.plan, AccountPlan.pro);

    final presets = HttpPresetsRepository(api);
    expect(await presets.list('thinking-orbs'), isEmpty);
    expect(calls, 2);
  });

  test('persists and restores the session cookie', () async {
    String? stored;
    final first = MockClient(
      (_) async => http.Response(
        jsonEncode({'ok': true}),
        200,
        headers: {'set-cookie': 'lp_session=persisted; Path=/'},
      ),
    );
    final api1 = ApiClient(
      baseUrl: Uri.parse('https://api.example.test'),
      client: first,
      readCookie: () async => stored,
      writeCookie: (cookie) async => stored = cookie,
    );
    await api1.getJson('/me');
    expect(stored, 'lp_session=persisted');

    final second = MockClient((request) async {
      expect(request.headers['cookie'], 'lp_session=persisted');
      return http.Response(jsonEncode({'presets': []}), 200);
    });
    final api2 = ApiClient(
      baseUrl: Uri.parse('https://api.example.test'),
      client: second,
      readCookie: () async => stored,
      writeCookie: (cookie) async => stored = cookie,
    );
    await api2.getJson('/presets');
  });

  test('clearSession drops the persisted cookie', () async {
    String? stored = 'lp_session=old';
    final client = MockClient((request) async {
      expect(request.headers['cookie'], isNull);
      return http.Response(jsonEncode({'ok': true}), 200);
    });
    final api = ApiClient(
      baseUrl: Uri.parse('https://api.example.test'),
      client: client,
      readCookie: () async => stored,
      writeCookie: (cookie) async => stored = cookie,
    );
    await api.clearSession();
    expect(stored, isEmpty);
    await api.getJson('/me');
  });

  test('requestCode and verifyCode hit the auth contract', () async {
    final paths = <String>[];
    final client = MockClient((request) async {
      paths.add(request.url.path);
      if (request.url.path == '/auth/code/request') {
        return http.Response(jsonEncode({'ok': true}), 200);
      }
      if (request.url.path == '/auth/code') {
        return http.Response(jsonEncode({'ok': true}), 200);
      }
      if (request.url.path == '/me') {
        return http.Response(
          jsonEncode({
            'authenticated': true,
            'email': 'demo@libraries.dev',
            'entitlements': {'pro': true},
          }),
          200,
        );
      }
      return http.Response('{}', 404);
    });
    final api = ApiClient(
      baseUrl: Uri.parse('https://api.example.test'),
      client: client,
    );
    final auth = HttpAuthRepository(api);
    await auth.requestCode('demo@libraries.dev');
    final session = await auth.verifyCode('demo@libraries.dev', '123456');
    expect(session?.plan, AccountPlan.pro);
    expect(paths, ['/auth/code/request', '/auth/code', '/me']);
  });

  test('parses the Studio agent SSE stream', () async {
    final client = MockClient((request) async {
      return http.Response(
        'data: {"type":"params","text":"Applied","params":{"state":"working"}}\n\n',
        200,
      );
    });
    final api = ApiClient(
      baseUrl: Uri.parse('https://api.example.test'),
      client: client,
    );
    final events = await HttpStudioAgent(api).chat(const ['calm']).toList();
    expect(events, hasLength(1));
    expect(events.first.type, 'params');
    expect(events.first.params?['state'], 'working');
  });
}

