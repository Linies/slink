import 'dart:io' show Directory, File, FileSystemEntity, Platform, Process;

import 'json_reader.dart';

Future<void> run([String target = ""]) async {
  var packageRoot = Directory.current.path;
  var list = await loadJson(packageRoot, target);
  await Future.forEach<Link2Src>(list, (element) async {
    await runLink(element, packageRoot);
  });
}

Future<void> runLink(Link2Src link2from, String root) async {
  if (link2from.src.isEmpty || link2from.to.isEmpty) {
    return;
  }
  var src =
      Uri.file('$root${link2from.src}').toFilePath(windows: Platform.isWindows);
  var to =
      Uri.file('$root${link2from.to}').toFilePath(windows: Platform.isWindows);
  // 判断是文件夹还是文件
  bool isDirectory = FileSystemEntity.isDirectorySync(src);
  print("start replace path: $src");
  print("is directory: $isDirectory, path:$src");
  if (isDirectory) {
    // 文件夹
    if (!Directory(src).existsSync()) {
      print('directory is no exists: \'$src\' \n');
    }
    if (Directory(to).existsSync()) {
      // 删除原来的
      print('directory is exists: \'$to\'');
      Directory(to).deleteSync(recursive: true);
    } else if (FileSystemEntity.isLinkSync(to)) {
      // 删除原来的软连接
      print('sort link path: \'$to\'');
      File(to).deleteSync(recursive: true);
    }
  } else {
    // 文件
    if (!File(src).existsSync()) {
      print('file is no exists: \'$src\'');
    }
    if (File(to).existsSync()) {
      // 删除原来的
      print('file is exists:: \'$to\'');
      File(to).deleteSync();
    } else if (FileSystemEntity.isLinkSync(to)) {
      // 删除原来的软连接
      print('sort link path: \'$to\'');
      File(to).deleteSync(recursive: true);
    }
  }
  print('\n');
  var res = await Process.run('ln', ['-s', src, to], runInShell: true);
  if (res.stdout.toString().isNotEmpty) print('${res.stdout}');
  if (res.stderr.toString().isNotEmpty) print('${res.stderr}');
}
