import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../../core/services/file_store.dart';

class LocalFileStore implements FileStore {
  LocalFileStore(this.root);
  final Directory root;

  File _file(String relativePath) {
    final normalized = p.normalize(relativePath);
    if (p.isAbsolute(normalized) || normalized.startsWith('..')) {
      throw ArgumentError.value(relativePath, 'relativePath', '相対パスのみ使用できます');
    }
    return File(p.join(root.path, normalized));
  }

  @override
  Future<void> delete(String relativePath) async {
    final value = _file(relativePath);
    if (await value.exists()) await value.delete();
  }

  @override
  Future<bool> exists(String relativePath) => _file(relativePath).exists();

  @override
  Future<List<String>> list(String directory) async {
    final target = Directory(p.join(root.path, p.normalize(directory)));
    if (!await target.exists()) return [];
    return [
      await for (final entity in target.list(recursive: true))
        if (entity is File) p.relative(entity.path, from: root.path),
    ];
  }

  @override
  Future<Uint8List> read(String relativePath) =>
      _file(relativePath).readAsBytes();

  @override
  Future<String> save(String relativePath, Uint8List bytes) async {
    final value = _file(relativePath);
    await value.parent.create(recursive: true);
    final temporary = File('${value.path}.tmp');
    await temporary.writeAsBytes(bytes, flush: true);
    await temporary.rename(value.path);
    return relativePath;
  }
}
