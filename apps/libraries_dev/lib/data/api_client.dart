import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({
    Uri? baseUrl,
    http.Client? client,
    Future<String?> Function()? readCookie,
    Future<void> Function(String cookie)? writeCookie,
  })
      : baseUrl = baseUrl ??
            Uri.parse(
              const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: 'https://api.libraries.dev',
              ),
            ),
        _client = client ?? http.Client(),
        // ignore: prefer_initializing_formals
        _readCookie = readCookie,
        // ignore: prefer_initializing_formals
        _writeCookie = writeCookie;

  final Uri baseUrl;
  final http.Client _client;
  final Future<String?> Function()? _readCookie;
  final Future<void> Function(String cookie)? _writeCookie;
  String? _cookie;
  bool _cookieLoaded = false;

  Future<void> _ensureCookie() async {
    if (_cookieLoaded) return;
    _cookieLoaded = true;
    try {
      final value = await _readCookie?.call();
      _cookie = value == null || value.isEmpty ? null : value;
    } catch (_) {}
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return baseUrl.replace(
      path: '${baseUrl.path}$normalized'.replaceAll('//', '/'),
      queryParameters: query,
    );
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'accept': 'application/json',
      'content-type': 'application/json',
    };
    final cookie = _cookie;
    if (cookie != null) headers['cookie'] = cookie;
    return headers;
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    await _ensureCookie();
    final response = await _client.get(_uri(path, query), headers: _headers);
    await _storeCookie(response);
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, String>? query,
    Map<String, Object?> body = const {},
  }) async {
    await _ensureCookie();
    final response = await _client.post(
      _uri(path, query),
      headers: _headers,
      body: jsonEncode(body),
    );
    await _storeCookie(response);
    return _decode(response);
  }

  Future<http.StreamedResponse> streamJson(
    String path, {
    Map<String, String>? query,
    Map<String, Object?> body = const {},
  }) async {
    await _ensureCookie();
    final request = http.Request('POST', _uri(path, query))
      ..headers.addAll(_headers)
      ..body = jsonEncode(body);
    final response = await _client.send(request);
    await _storeCookie(response);
    return response;
  }

  Future<void> clearSession() async {
    _cookie = null;
    _cookieLoaded = true;
    try {
      await _writeCookie?.call('');
    } catch (_) {}
  }

  Future<File> download(String path, File destination) async {
    await _ensureCookie();
    final request = http.Request('GET', _uri(path))..headers.addAll(_headers);
    final response = await _client.send(request);
    await _storeCookie(response);
    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        response.reasonPhrase ?? 'Download failed',
      );
    }
    await destination.parent.create(recursive: true);
    final sink = destination.openWrite();
    await response.stream.pipe(sink);
    await sink.close();
    return destination;
  }

  Future<void> _storeCookie(Object response) async {
    final raw = response is http.Response
        ? response.headers['set-cookie']
        : response is http.StreamedResponse
            ? response.headers['set-cookie']
            : null;
    if (raw == null) return;
    final match = RegExp(r'(lp_session=[^;]+)').firstMatch(raw);
    if (match == null) return;
    _cookie = match.group(1);
    try {
      await _writeCookie?.call(_cookie!);
    } catch (_) {}
  }

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = response.body.trim().isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw ApiException(
        response.statusCode,
        decoded['error']?.toString() ?? response.reasonPhrase ?? 'API error',
      );
    }
    return decoded;
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}




