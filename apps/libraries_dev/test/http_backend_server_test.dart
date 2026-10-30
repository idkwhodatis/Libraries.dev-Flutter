import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:libraries_dev/data/api_client.dart';
import 'package:libraries_dev/data/http_backend.dart';
import 'package:libraries_dev/data/repositories.dart';

void main() {
  test('HttpBackend works against a real local HTTP server', () async {
    final seen = <String>[];
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));

    server.listen((request) async {
      seen.add(request.uri.path);
      final response = request.response;
      response.headers.contentType = ContentType.json;
      switch (request.uri.path) {
        case '/me':
          response.headers.set('set-cookie', 'lp_session=server123; Path=/');
          response.write(jsonEncode({
            'authenticated': true,
            'email': 'server@libraries.dev',
            'entitlements': {'pro': true},
          }));
        case '/auth/code/request':
          response.write(jsonEncode({'ok': true}));
        case '/auth/code':
          response.write(jsonEncode({'ok': true}));
        case '/presets':
          response.write(jsonEncode({'presets': []}));
        case '/presets/delete':
          response.write(jsonEncode({'ok': true}));
        case '/models/magnet':
          response.headers.contentType = ContentType.binary;
          response.add([1, 2, 3, 4]);
        case '/studio/chat':
          response.headers.contentType = ContentType('text', 'event-stream');
          response.write(
            'data: {"type":"params","text":"Applied","params":{"state":"working"}}\n\n',
          );
        default:
          response.statusCode = 404;
          response.write(jsonEncode({'error': 'not found'}));
      }
      await response.close();
    });

    final client = ApiClient(
      baseUrl: Uri.parse('http://127.0.0.1:${server.port}'),
    );
    final backend = HttpBackend(client);
    addTearDown(client.dispose);

    final session = await backend.auth.me();
    expect(session?.email, 'server@libraries.dev');
    expect(session?.plan, AccountPlan.pro);

    await backend.auth.requestCode('server@libraries.dev');
    final verified = await backend.auth.verifyCode(
      'server@libraries.dev',
      '123456',
    );
    expect(verified?.plan, AccountPlan.pro);

    expect(await backend.presets.list('thinking-orbs'), isEmpty);
    await backend.presets.save(
      const StudioPreset(
        id: 'p1',
        library: 'thinking-orbs',
        name: 'Server preset',
        params: {'state': 'working'},
      ),
    );
    await backend.presets.delete('p1');

    final temp = await Directory.systemTemp.createTemp('magnet-test');
    addTearDown(() => temp.delete(recursive: true));
    final file = await backend.downloads.downloadMagnetModel(temp);
    expect(await file.readAsBytes(), [1, 2, 3, 4]);

    final events = await backend.agent.chat(const ['calm']).toList();
    expect(events.single.type, 'params');
    expect(events.single.params?['state'], 'working');

    expect(
      seen,
      containsAll([
        '/me',
        '/auth/code/request',
        '/auth/code',
        '/presets',
        '/studio/chat',
      ]),
    );
  });
}

