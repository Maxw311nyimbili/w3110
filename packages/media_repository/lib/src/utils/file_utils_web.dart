// packages/media_repository/lib/src/utils/file_utils_web.dart
import 'dart:typed_data';
import 'file_utils_stub.dart';

class File implements FileInterface {
  File(this.path);
  @override
  final String path;

  @override
  Future<bool> exists() async => false;

  @override
  Future<Uint8List> readAsBytes() async => Uint8List(0);

  @override
  Future<int> length() async => 0;

  @override
  Future<void> writeAsBytes(List<int> bytes) async {}

  @override
  String get parentPath => '';
}
