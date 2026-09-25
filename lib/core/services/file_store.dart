import 'dart:typed_data';

/// Boundary for app-private storage. Platform I/O stays outside business logic.
abstract interface class FileStore {
  Future<String> save(String relativePath, Uint8List bytes);
  Future<Uint8List> read(String relativePath);
  Future<bool> exists(String relativePath);
  Future<void> delete(String relativePath);
  Future<List<String>> list(String directory);
}
