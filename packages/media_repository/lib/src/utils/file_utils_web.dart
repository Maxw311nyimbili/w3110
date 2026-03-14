// packages/media_repository/lib/src/utils/file_utils_web.dart
import 'file_utils_stub.dart';

class File implements FileInterface {
  File(this.path);
  @override
  final String path;

  @override
  Future<bool> exists() async => false;

  @override
  Future<List<int>> readAsBytes() async => [];

  @override
  Future<int> length() async => 0;

  @override
  Future<void> writeAsBytes(List<int> bytes) async {}

  @override
  String get parentPath => '';
}
