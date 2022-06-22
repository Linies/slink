import 'dart:convert';
import 'dart:io';

Future<List<Link2Src>> loadJson(String path, [String target = ""]) async {
  var file = File('$path${Platform.pathSeparator}slink.json');
  if (!file.existsSync()) {
    throw Exception();
  }
  var content = file.readAsStringSync();
  var json = jsonDecode(content);
  var jsonList = target.isNotEmpty ? json[target] : json.values.first ?? [];
  return jsonList.map<Link2Src>((e) => Link2Src.fromJson(e)).toList();
}

class Link2Src {
  /// 原始路径
  final String src;

  /// 目标路径
  final String to;

  const Link2Src(this.src, this.to);

  factory Link2Src.fromJson(Map<String, dynamic> json) {
    return Link2Src(json['src'], json['to']);
  }
}
