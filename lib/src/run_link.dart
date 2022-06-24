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
  print("开始替换 PATH:$src");
  print("是否文件夹:$isDirectory ,path:$src");
  if (isDirectory) {
    // 文件夹
    if (!Directory(src).existsSync()) {
      print('路径不存在: \'$src\' \n');
    }
    if (Directory(to).existsSync()) {
      // 删除原来的
      print('存在文件路径: \'$to\' 开始替换');
      Directory(to).deleteSync();
    }
  } else {
    // 文件
    if (!File(src).existsSync()) {
      print('路径不存在: \'$src\'');
    }
    if (File(to).existsSync()) {
      // 删除原来的
      print('存在文件路径: \'$to\' 开始替换');
      File(to).deleteSync();
    }
  }
  print('\n');
  var res = await Process.run('ln', ['-s', src, to], runInShell: true);
  if (res.stdout.toString().isNotEmpty) print('${res.stdout}');
  if (res.stderr.toString().isNotEmpty) print('${res.stderr}');
}
