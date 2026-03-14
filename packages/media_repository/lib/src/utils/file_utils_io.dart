// packages/media_repository/lib/src/utils/file_utils_io.dart
import 'dart:io' as io;
import 'file_utils_stub.dart';

class File implements FileInterface {
  File(this.path) : _file = io.File(path);
  final io.File _file;
  
  @override
  final String path;

  @override
  Future<bool> exists() => _file.exists();

  @override
  Future<List<int>> readAsBytes() => _file.readAsBytes();

  @override
  Future<int> length() => _file.length();

  @override
  Future<void> writeAsBytes(List<int> bytes) async {
    await _file.writeAsBytes(bytes);
  }

  @override
  String get parentPath => _file.parent.path;
}
