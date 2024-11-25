import 'dart:io';

import 'package:dev_build/build_support.dart';
import 'package:path/path.dart';
import 'package:process_run/shell.dart';

Future<void> main() async {
  var files = await Directory('lib')
      .list()
      .where((fse) => fse is File && extension(fse.path) == '.yaml')
      .toList();
  for (var file in files) {
    stdout.writeln('# ${file.path}');
    var content = (await run('tklint list-rules ${file.path}')).first.outText;
    await File(join('doc', 'all_rules_${basename(file.path)}'))
        .writeAsString(content);
  }

  var configMap = await pathGetPackageConfigMap('.');
  var packagePath =
      pathPackageConfigMapGetPackagePath('.', configMap, 'lints')!;
  var content = (await run(
          'tklint list-rules ${join(packagePath, 'lib', 'recommended.yaml')}'))
      .first
      .outText;
  await File(join('doc', 'dart_lints_recommended.yaml')).writeAsString(content);
}
