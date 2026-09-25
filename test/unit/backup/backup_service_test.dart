import 'dart:convert';
import 'dart:typed_data';

import 'package:cosplayers_diary/features/backup/domain/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = BackupService(maxExtractedBytes: 1024);

  test('manifest round trips with counts and relative image', () {
    final files = <String, Uint8List>{
      'data/genres.csv': Uint8List.fromList(utf8.encode('id,name\ng1,A\n')),
      'images/photo-1.jpg': Uint8List.fromList([1, 2, 3]),
    };
    final bytes = service.create(files, createdAt: DateTime.utc(2026, 1, 1));
    final result = service.inspect(bytes);
    expect(result.isValid, isTrue);
    expect(result.manifest!.formatVersion, BackupService.currentVersion);
    expect(result.manifest!.imageCount, 1);
  });

  test('rejects unsupported manifest version', () {
    final bytes = service.create(
      const {},
      createdAt: DateTime.utc(2026),
      formatVersion: 99,
    );
    expect(service.inspect(bytes).errors.join(), contains('バージョン'));
  });

  test('rejects traversal path before extraction', () {
    final bytes = service.create({
      '../escape.txt': Uint8List(1),
    }, createdAt: DateTime.utc(2026));
    expect(service.inspect(bytes).errors.join(), contains('不正なパス'));
  });

  test('rejects excessive extracted size', () {
    final bytes = service.create({
      'images/huge.jpg': Uint8List(2048),
    }, createdAt: DateTime.utc(2026));
    expect(service.inspect(bytes).errors.join(), contains('サイズ'));
  });
}
