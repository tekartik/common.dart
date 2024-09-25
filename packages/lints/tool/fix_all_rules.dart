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
    await run('tklint fix-rules ${file.path}');
  }
}
