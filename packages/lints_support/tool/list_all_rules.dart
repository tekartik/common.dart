import 'dart:io';

import 'package:dev_build/build_support.dart';
import 'package:dev_build/shell.dart';
import 'package:path/path.dart';
import 'package:tekartik_prj_tktools/tklint.dart';

Future<void> main() async {
  var packageConfig = await pathGetPackageConfigMap('.');
  var tekartikLintsPackagePath = pathPackageConfigMapGetPackagePath(
    '.',
    packageConfig,
    'tekartik_lints',
  )!;
  stdout.writeln('lintsPackagePath: $tekartikLintsPackagePath');
  var supportPackage = TkLintPackage('.');
  var files = await Directory(join(tekartikLintsPackagePath, 'lib'))
      .list()
      .where((fse) => fse is File && extension(fse.path) == '.yaml')
      .toList();
  for (var file in files) {
    stdout.writeln('# ${file.path}');
    var package = TkLintPackage(tekartikLintsPackagePath);
    var rules = await package.getRules(file.path, handleInclude: true);
    var filePath = join('doc', 'all_rules_${basename(file.path)}');
    var lines = rules.toStringList();
    supportPackage.writeIfNeeded(filePath, lines);

    var content = (await run(
      'tklint list-rules --force-any ${shellArgument(file.path)}',
    )).first.outText;
    await File(
      join('.local', 'all_rules_any_${basename(file.path)}'),
    ).writeAsString(content);
  }

  files = await Directory('lib')
      .list()
      .where((fse) => fse is File && extension(fse.path) == '.yaml')
      .toList();
  for (var file in files) {
    stdout.writeln('# ${file.path}');
    var package = TkLintPackage(tekartikLintsPackagePath);
    var rules = await package.getRules(file.path, handleInclude: true);
    var filePath = join('doc', 'support', 'all_rules_${basename(file.path)}');
    var lines = rules.toStringList();
    supportPackage.writeIfNeeded(filePath, lines);
  }
}
