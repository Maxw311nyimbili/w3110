// packages/media_repository/lib/src/utils/file_utils_stub.dart
abstract class FileInterface {
  Future<bool> exists();
  Future<List<int>> readAsBytes();
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
  Future<List<int>> readAsBytes() => throw UnimplementedError();
  @override
  Future<int> length() => throw UnimplementedError();
  @override
  Future<void> writeAsBytes(List<int> bytes) => throw UnimplementedError();
  @override
  String get path => throw UnimplementedError();
  @override
  String get parentPath => throw UnimplementedError();
}
