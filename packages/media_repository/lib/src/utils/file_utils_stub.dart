// packages/media_repository/lib/src/utils/file_utils_stub.dart
import 'dart:typed_data';

abstract class FileInterface {
  Future<bool> exists();
  Future<Uint8List> readAsBytes();
  Future<int> length();
  Future<void> writeAsBytes(List<int> bytes);
  String get path;
  String get parentPath;
}

class File implements FileInterface {
  File(String path);
  @override
  Future<bool> exists() => throw UnimplementedError();
  @override
  Future<Uint8List> readAsBytes() => throw UnimplementedError();
  @override
  Future<int> length() => throw UnimplementedError();
  @override
  Future<void> writeAsBytes(List<int> bytes) => throw UnimplementedError();
  @override
  String get path => throw UnimplementedError();
  @override
  String get parentPath => throw UnimplementedError();
}
