import 'dart:typed_data';

import '../../../core/services/file_store.dart';

enum PhotoSaveMode { original, spaceSaving }

class PhotoRecord {
  const PhotoRecord({
    required this.id,
    required this.relativePath,
    required this.originalName,
  });
  final String id;
  final String relativePath;
  final String originalName;
}

abstract interface class ImageProcessor {
  Future<Uint8List> resizeForStorage(
    Uint8List source, {
    required int maxLongEdge,
  });
}

class PassthroughImageProcessor implements ImageProcessor {
  const PassthroughImageProcessor();
  @override
  Future<Uint8List> resizeForStorage(
    Uint8List source, {
    required int maxLongEdge,
  }) async => source;
}

class PhotoService {
  PhotoService({required this.fileStore, required this.processor});
  final FileStore fileStore;
  final ImageProcessor processor;
  int _sequence = 0;

  Future<PhotoRecord> replace({
    required String diaryId,
    required Uint8List bytes,
    required String originalName,
    required PhotoSaveMode mode,
    String? oldRelativePath,
    required bool oldIsReferenced,
  }) async {
    final id = 'photo-${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';
    final encoded = mode == PhotoSaveMode.original
        ? bytes
        : await processor.resizeForStorage(bytes, maxLongEdge: 2048);
    final extension = _safeExtension(originalName);
    final relativePath = 'images/$id.$extension';
    await fileStore.save(relativePath, encoded);
    if (oldRelativePath != null && !oldIsReferenced) {
      try {
        await fileStore.delete(oldRelativePath);
      } catch (_) {
        // A stale orphan is safer than breaking the new database reference.
      }
    }
    return PhotoRecord(
      id: id,
      relativePath: relativePath,
      originalName: originalName,
    );
  }

  String _safeExtension(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0) return 'jpg';
    final value = name.substring(dot + 1).toLowerCase();
    return const {'jpg', 'jpeg', 'png', 'webp', 'heic'}.contains(value)
        ? value
        : 'jpg';
  }
}
