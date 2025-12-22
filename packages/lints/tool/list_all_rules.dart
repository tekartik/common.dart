import 'dart:io';

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
    await File(
      join('doc', 'all_rules_${basename(file.path)}'),
    ).writeAsString(content);
    content = (await run(
      'tklint list-rules --force-any ${shellArgument(file.path)}',
    )).first.outText;
    await File(
      join('.local', 'all_rules_any_${basename(file.path)}'),
    ).writeAsString(content);
  }
}
