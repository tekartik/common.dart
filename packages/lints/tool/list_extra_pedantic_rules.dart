import 'dart:io';

import 'package:dev_build/build_support.dart';
import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

Future<List<String>> getRules(String path) async {
  var yaml = loadYaml(await File(path).readAsString()) as Map;
  try {
    var rawRules = (yaml['linter'] as Map)['rules'];
    List<String> rules;
    if (rawRules is List) {
      rules = List<String>.from(rawRules.cast<String>())..sort();
      return rules;
    }
    throw UnsupportedError('invalid rawRules type ${rawRules.runtimeType}');
  } catch (e) {
    stderr.writeln('fail to read linter rules in $path');
    rethrow;
  }
}

Future<void> _writeRules(String name, List<String> rules) async {
  var sb = StringBuffer();
  //for (var element in rules) {
  //  sb.writeln('  - $element');
  //}
  for (var element in rules) {
    sb.writeln('    $element: true');
  }
  await Directory('.local').create(recursive: true);
  await File(join('.local', '${name}_rules.txt')).writeAsString(sb.toString());
}

Future<void> main() async {
  var rules = await getRules(join('lib', 'recommended.yaml'));
  await _writeRules('tekartik', rules);

  var packageConfigMap = await pathGetPackageConfigMap('.');
  var path = '.';

  var dartTeamLibPath = join(
      pathPackageConfigMapGetPackagePath(
          path, packageConfigMap, 'dart_flutter_team_lints')!,
      'lib');
  var lintsDartTeamRecommended =
      await getRules(join(dartTeamLibPath, 'analysis_options.yaml'));
  await _writeRules('dart_flutter_team', lintsDartTeamRecommended);
  var lintsLibPath = join(
      pathPackageConfigMapGetPackagePath(path, packageConfigMap, 'lints')!,
      'lib');
  //var pedanticRules =
//      await getRules(join(pedanticLibPath, 'analysis_options.1.11.0.yaml'));
  //await _writeRules('pedantic', pedanticRules);
  var lintsRecommendedRules =
      await getRules(join(lintsLibPath, 'recommended.yaml'));
  await _writeRules('recommended_lints', lintsRecommendedRules);
  var lintsCoreRules = await getRules(join(lintsLibPath, 'core.yaml'));
  await _writeRules('core_lints', lintsCoreRules);

  //var diffRules = List<String>.from(rules);
  //diffRules.removeWhere((element) => pedanticRules.contains(element));
  // await _writeRules('pedantic_diff', diffRules);
  var diffRules = List<String>.from(rules);
  diffRules.removeWhere((element) => lintsRecommendedRules.contains(element));
  await _writeRules('lints_diff', diffRules);
  diffRules = List<String>.from(lintsRecommendedRules);
  //diffRules.removeWhere((element) => pedanticRules.contains(element));
  //await _writeRules('lints_over_pedantic', diffRules);
  //diffRules = List<String>.from(pedanticRules);
  //diffRules.removeWhere((element) => lintsRecommendedRules.contains(element));
  //await _writeRules('pedantic_over_lints', diffRules);

  var all = <String>{}
    ..addAll(rules)
    //..addAll(pedanticRules)
    ..addAll(lintsRecommendedRules)
    ..addAll(lintsCoreRules);
  diffRules = List<String>.from(all)..sort();
  diffRules.removeWhere((element) =>
      lintsRecommendedRules.contains(element) ||
      lintsCoreRules.contains(element));
  await _writeRules('tekartik_recommended_over_lints', diffRules);
}
