import 'package:flutter_test/flutter_test.dart';
import 'package:libraries_dev/data/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('mock auth signs out and back in', () async {
    final auth = MockAuthRepository();
    expect(await auth.me(), isNotNull);
    await auth.signOut();
    expect(await auth.me(), isNull);
    expect(
      await auth.verifyCode('demo@libraries.dev', '123456'),
      isNotNull,
    );
    expect(await auth.me(), isNotNull);
  });

  test('mock presets save, list and delete', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = MockPresetsRepository();
    expect(await repository.list('thinking-orbs'), isEmpty);

    const preset = StudioPreset(
      id: 'p1',
      library: 'thinking-orbs',
      name: 'Calm',
      params: {'state': 'breathing', 'speed': 0.8},
    );
    await repository.save(preset);
    final saved = await repository.list('thinking-orbs');
    expect(saved, hasLength(1));
    expect(saved.single.name, 'Calm');
    expect(saved.single.params['state'], 'breathing');

    await repository.delete('p1');
    expect(await repository.list('thinking-orbs'), isEmpty);
  });
}
