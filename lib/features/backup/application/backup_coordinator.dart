import 'dart:convert';
import 'dart:typed_data';

import '../../../core/database/app_state_persistence.dart';
import '../domain/backup_service.dart';
import '../domain/csv_service.dart';

class BackupCoordinator {
  const BackupCoordinator(this.persistence);
  final AppStatePersistence persistence;
  static const _csv = CsvService();
  static const _backup = BackupService();

  Uint8List create(DateTime createdAt) {
    final stateJson = persistence.exportJson();
    final state = jsonDecode(stateJson) as Map<String, Object?>;
    final files = <String, Uint8List>{
      'data/app_state.json': Uint8List.fromList(utf8.encode(stateJson)),
    };
    for (final definition in csvFileColumns.entries) {
      final rows = _rowsFor(definition.key, state);
      final text = _csv.encode(rows, columns: definition.value, bom: true);
      files['data/${definition.key}'] = Uint8List.fromList(utf8.encode(text));
    }
    return _backup.create(files, createdAt: createdAt);
  }

  Future<BackupInspection> restore(Uint8List bytes) async {
    final result = _backup.inspect(bytes);
    if (!result.isValid) return result;
    final state = result.files['data/app_state.json'];
    if (state == null) {
      return BackupInspection(
        errors: const ['data/app_state.json がありません'],
        files: result.files,
        manifest: result.manifest,
      );
    }
    persistence.restoreJson(utf8.decode(state));
    await persistence.save();
    return result;
  }

  List<Map<String, Object?>> _rowsFor(String file, Map<String, Object?> state) {
    final sourceKey = switch (file) {
      'genres.csv' => 'genres',
      'characters.csv' => 'characters',
      'costumes.csv' => 'costumes',
      'contact_lenses.csv' => 'lensProducts',
      'lens_purchases.csv' => 'lensPurchases',
      'lens_inventory.csv' => 'lensInventories',
      'lens_usage.csv' => 'lensUsages',
      'diary.csv' => 'diary',
      _ => null,
    };
    if (sourceKey == null) return const [];
    return [
      for (final raw
          in (state[sourceKey] as List? ?? const [])
              .cast<Map<String, Object?>>())
        _csvRow(file, raw),
    ];
  }

  Map<String, Object?> _csvRow(String file, Map<String, Object?> raw) =>
      switch (file) {
        'genres.csv' => {
          'id': raw['id'],
          'name': raw['name'],
          'memo': raw['memo'],
          'archived': raw['archived'],
        },
        'characters.csv' => {
          'id': raw['id'],
          'genre_id': raw['genreId'],
          'name': raw['name'],
          'memo': raw['memo'],
          'default_lens_product_id': raw['defaultLensProductId'],
          'archived': raw['archived'],
        },
        'costumes.csv' => {
          'id': raw['id'],
          'name': raw['name'],
          'is_general': raw['isGeneral'],
          'character_id': raw['characterId'],
          'memo': raw['memo'],
          'archived': raw['archived'],
        },
        'contact_lenses.csv' => {
          'id': raw['id'],
          'name': raw['name'],
          'manufacturer': raw['manufacturer'],
          'color': raw['color'],
          'wear_type': raw['wearType'],
          'open_period_days': raw['openPeriodDays'],
          'memo': raw['memo'],
          'archived': raw['archived'],
        },
        'lens_purchases.csv' => {
          'id': raw['id'],
          'lens_product_id': raw['productId'],
          'purchased_on': _day(raw['purchasedOn']),
          'unopened_expires_on': _day(raw['unopenedExpiresOn']),
          'quantity': raw['quantity'],
        },
        'lens_inventory.csv' => {
          'id': raw['id'],
          'purchase_id': raw['purchaseId'],
          'opened_on': _day(raw['openedOn']),
          'disposed': raw['disposed'],
        },
        'lens_usage.csv' => {
          'id': raw['id'],
          'diary_id': raw['diaryId'],
          'inventory_id': raw['inventoryId'],
          'used_on': _day(raw['usedOn']),
        },
        'diary.csv' => {
          'id': raw['id'],
          'activity_date': _day(raw['activityDate']),
          'activity_type': raw['activityType'],
          'genre_id': raw['genreId'],
          'character_id': raw['characterId'],
          'costume_id': raw['costumeId'],
          'memo': raw['memo'],
          'photo_id': raw['photoId'],
          'lens_inventory_id': raw['lensInventoryId'],
        },
        _ => const {},
      };

  String _day(Object? value) =>
      value == null ? '' : (value as String).split('T').first;
}
