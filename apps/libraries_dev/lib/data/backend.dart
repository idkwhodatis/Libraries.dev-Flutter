import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'http_backend.dart';
import 'repositories.dart';

final Backend backend = const bool.fromEnvironment(
  'USE_REAL_API',
  defaultValue: false,
)
    ? HttpBackend(_apiClient())
    : MockBackend();

ApiClient _apiClient() {
  return ApiClient(
    readCookie: () async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('lp_session');
    },
    writeCookie: (cookie) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lp_session', cookie);
    },
  );
}
