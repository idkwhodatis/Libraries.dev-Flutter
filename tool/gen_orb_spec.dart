import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final check = args.contains('--check');
  final specFile = File('packages/thinking_orbs/spec/orbs-spec.json');
  final outFile = File('packages/thinking_orbs/lib/src/spec.g.dart');

  if (!specFile.existsSync()) {
    stderr.writeln('Missing ${specFile.path}');
    exitCode = 2;
    return;
  }

  final spec = jsonDecode(specFile.readAsStringSync()) as Map<String, dynamic>;
  final generated = _generate(spec);

  if (check) {
    if (!outFile.existsSync() || outFile.readAsStringSync() != generated) {
      stderr.writeln('Generated orb spec is out of date. Run:');
      stderr.writeln('  dart run tool/gen_orb_spec.dart');
      exitCode = 1;
    }
    return;
  }

  outFile.parent.createSync(recursive: true);
  outFile.writeAsStringSync(generated);
  stdout.writeln('Wrote ${outFile.path}');
}

String _generate(Map<String, dynamic> spec) {
  final b = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('// Source: packages/thinking_orbs/spec/orbs-spec.json')
    ..writeln('// Regenerate with: dart run tool/gen_orb_spec.dart')
    ..writeln()
    ..writeln("import 'spec_types.dart';")
    ..writeln();

  final source = spec['sourceLibrary'] as Map<String, dynamic>;
  b
    ..writeln('const String orbSpecVersion = ${_str(spec['specVersion'])};')
    ..writeln('const String orbSourceLibrary = ${_str(source['name'])};')
    ..writeln('const String orbSourceVersion = ${_str(source['version'])};')
    ..writeln();

  final defaults = spec['defaults'] as Map<String, dynamic>;
  b
    ..writeln('const String kDefaultOrbState = ${_str(defaults['state'])};')
    ..writeln('const int kDefaultOrbSize = ${defaults['size']};')
    ..writeln('const String kDefaultOrbTheme = ${_str(defaults['theme'])};')
    ..writeln('const double kDefaultOrbSpeed = ${_num(defaults['speed'])};')
    ..writeln('const bool kDefaultOrbPaused = ${defaults['paused']};')
    ..writeln();

  final stateToMode = spec['stateToMode'] as Map<String, dynamic>;
  b.writeln('const Map<String, String> kStateToMode = {');
  for (final key in stateToMode.keys.toList()..sort()) {
    b.writeln('  ${_str(key)}: ${_str(stateToMode[key])},');
  }
  b.writeln('};');
  b.writeln();

  final labels = spec['labels'] as Map<String, dynamic>;
  b.writeln('const Map<String, String> kOrbSemanticLabels = {');
  for (final key in labels.keys.toList()..sort()) {
    b.writeln('  ${_str(key)}: ${_str(labels[key])},');
  }
  b.writeln('};');
  b.writeln();

  final baseProfiles = spec['baseProfiles'] as Map<String, dynamic>;
  b.writeln('const Map<String, Map<String, double>> kBaseProfiles = {');
  for (final mode in baseProfiles.keys.toList()..sort()) {
    final profile = baseProfiles[mode] as Map<String, dynamic>;
    b.writeln('  ${_str(mode)}: {');
    for (final key in profile.keys.toList()..sort()) {
      b.writeln('    ${_str(key)}: ${_num(profile[key])},');
    }
    b.writeln('  },');
  }
  b.writeln('};');
  b.writeln();

  final presets = spec['presets'] as Map<String, dynamic>;
  b.writeln('const Map<String, Map<int, OrbPresetSpec>> kOrbPresets = {');
  for (final mode in presets.keys.toList()..sort()) {
    final sizes = presets[mode] as Map<String, dynamic>;
    b.writeln('  ${_str(mode)}: {');
    final sizeKeys = sizes.keys.map(int.parse).toList()..sort();
    for (final size in sizeKeys) {
      final preset = sizes['$size'] as Map<String, dynamic>;
      final extra = preset['extra'] as Map<String, dynamic>?;
      b.write(
        '    $size: OrbPresetSpec('
        'speed: ${_num(preset['speed'])}, '
        'count: ${_num(preset['count'])}, '
        'size: ${_num(preset['size'])}',
      );
      if (extra != null && extra.isNotEmpty) {
        b.write(', extra: {');
        for (final key in extra.keys.toList()..sort()) {
          b.write('${_str(key)}: ${_num(extra[key])}, ');
        }
        b.write('}');
      }
      b.writeln('),');
    }
    b.writeln('  },');
  }
  b.writeln('};');
  b.writeln();

  final scaling = spec['scaling'] as Map<String, dynamic>;
  _writeStringListList(b, 'kCountPairs', scaling['countPairs']);
  _writeStringList(b, 'kCountKeys', scaling['countKeys']);
  _writeStringList(b, 'kIconDensityKeys', scaling['iconDensityKeys']);
  _writeStringList(b, 'kRadiusKeys', scaling['radiusKeys']);
  b.writeln();

  final paint = spec['paint'] as Map<String, dynamic>;
  b
    ..writeln('const double kOrbCullAlphaBelow = ${_num(paint['cullAlphaBelow'])};')
    ..writeln('const int kOrbDevicePixelRatioCap = ${paint['devicePixelRatioCap']};')
    ..writeln('const double kOrbReducedMotionTime = 0.6;')
    ..writeln();

  final timing = spec['timing'] as Map<String, dynamic>;
  final morph = timing['morph'] as Map<String, dynamic>;
  final rubik = timing['rubik'] as Map<String, dynamic>;
  b
    ..writeln('const double kMorphHold = ${_num(morph['hold'])};')
    ..writeln('const double kMorphMorph = ${_num(morph['morph'])};')
    ..writeln('const double kRubikSlotDuration = ${_num(rubik['slotDuration'])};')
    ..writeln('const double kRubikRest = ${_num(rubik['rest'])};');

  return b.toString();
}

void _writeStringList(StringBuffer b, String name, Object? value) {
  final list = (value as List<dynamic>).cast<String>();
  b.writeln('const List<String> $name = [');
  for (final item in list) {
    b.writeln('  ${_str(item)},');
  }
  b.writeln('];');
}

void _writeStringListList(StringBuffer b, String name, Object? value) {
  final list = value as List<dynamic>;
  b.writeln('const List<List<String>> $name = [');
  for (final pair in list) {
    final items = (pair as List<dynamic>).cast<String>();
    b.writeln('  [${items.map(_str).join(', ')}],');
  }
  b.writeln('];');
}

String _str(Object? value) {
  final text = value
      .toString()
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'");
  return "'$text'";
}

String _num(Object? value) {
  if (value is int) return '$value.0';
  if (value is double) {
    if (value == value.truncateToDouble()) return value.toStringAsFixed(1);
    return value.toString();
  }
  throw FormatException('Expected number, got $value');
}
