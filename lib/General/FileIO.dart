import 'dart:convert';
import 'dart:io';

import 'package:hr_project_flutter/General/Logger.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> getFile(String filename) async {
  final path = await _localPath;
  slog.i("file/ $path/$filename");
  return File('$path/$filename');
}

Future<File> writeText(String filename, String text) async {
  final file = await getFile(filename);
  return file.writeAsString(text);
}

Future<File> writeJSON(String filename, Map<String, dynamic> jsonMap) async {
  var json = jsonEncode(jsonMap);
  return writeText(filename, json);
}

Future<String> readText(String filename) async {
  try {
    final file = await getFile(filename);
    return await file.readAsString();
  } catch (ex) {
    return '';
  }
}

Future<bool> deleteFile(String filename) async {
  try {
    final file = await getFile(filename);
    if (await file.exists() == true) {
      await file.delete();
      return true;
    }
    return false;
  } catch (ex) {
    return false;
  }
}
