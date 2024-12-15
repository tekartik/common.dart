import 'dart:io';

import 'package:fs_shim/utils/io/read_write.dart';
import 'package:dev_build/build_support.dart';
import 'package:path/path.dart';
import 'package:tekartik_common_utils/string_utils.dart';
import 'package:tekartik_prj_tktools/tklint.dart';

Future<void> writeIfNeeded(String filePath, List<String> newLines) async {
  var file = File(filePath);
  if (await file.exists()) {
    var existing = await file.readAsLines();
    if (existing.matchesStringList(newLines)) {
      stdout.writeln(('up to date: $filePath'));
    } else {
      await writeLines(file, newLines);
      stdout.writeln(('writing...: $filePath'));
    }
  } else {
    await writeLines(file, newLines);
    stdout.writeln(('creating..: $filePath'));
  }
  return;
}

Future<void> main() async {
  var packageConfig = await pathGetPackageConfigMap('.');
  var tekartikLintsPackagePath =
      pathPackageConfigMapGetPackagePath('.', packageConfig, 'tekartik_lints')!;
  stdout.writeln('lintsPackagePath: $tekartikLintsPackagePath');
  var files = await Directory(join(tekartikLintsPackagePath, 'lib'))
      .list()
      .where((fse) => fse is File && extension(fse.path) == '.yaml')
      .toList();
  for (var file in files) {
    var filePath = file.path;
    stdout.writeln('# $filePath');
    var package = TkLintPackage('.', verbose: true);
    var rules = await package.getRules(filePath,
        handleInclude: true, fromInclude: true);
    rules.removeObsoleteRules();

    package.writeRules(filePath, rules);
  }
}
