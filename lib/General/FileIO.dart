import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'Logger.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> getFile(String filename) async {
  final path = await _localPath;
  slog.i('$path/$filename');
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
  } catch (e) {
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
  } catch (e) {
    return false;
  }
}
