import 'dart:typed_data';

import 'package:cosplayers_diary/core/services/file_store.dart';
import 'package:cosplayers_diary/features/photos/domain/photo_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('replacement saves new file before deleting unreferenced old file', () async {
    final files = _FakeFiles()..values['images/old.jpg'] = Uint8List.fromList([9]);
    final service = PhotoService(fileStore: files, processor: const PassthroughImageProcessor());
    final record = await service.replace(
      diaryId: 'd1', bytes: Uint8List.fromList([1, 2]), originalName: 'picked.jpg',
      mode: PhotoSaveMode.original, oldRelativePath: 'images/old.jpg', oldIsReferenced: false,
    );
    expect(files.values[record.relativePath], [1, 2]);
    expect(files.values.containsKey('images/old.jpg'), isFalse);
  });

  test('shared old file is retained', () async {
    final files = _FakeFiles()..values['images/shared.jpg'] = Uint8List.fromList([9]);
    final service = PhotoService(fileStore: files, processor: const PassthroughImageProcessor());
    await service.replace(
      diaryId: 'd1', bytes: Uint8List.fromList([1]), originalName: 'picked.jpg',
      mode: PhotoSaveMode.spaceSaving, oldRelativePath: 'images/shared.jpg', oldIsReferenced: true,
    );
    expect(files.values.containsKey('images/shared.jpg'), isTrue);
  });
}

class _FakeFiles implements FileStore {
  final values = <String, Uint8List>{};
  @override Future<void> delete(String relativePath) async => values.remove(relativePath);
  @override Future<bool> exists(String relativePath) async => values.containsKey(relativePath);
  @override Future<List<String>> list(String directory) async => values.keys.where((e) => e.startsWith(directory)).toList();
  @override Future<Uint8List> read(String relativePath) async => values[relativePath]!;
  @override Future<String> save(String relativePath, Uint8List bytes) async { values[relativePath] = bytes; return relativePath; }
}
