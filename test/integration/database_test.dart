import 'package:cosplayers_diary/core/database/app_database.dart';
import 'package:cosplayers_diary/core/database/schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  test(
    'initial migration creates production tables and persists settings',
    () async {
      final db = await AppDatabase.open(
        path: inMemoryDatabasePath,
        factory: databaseFactoryFfi,
      );
      addTearDown(db.close);
      final tables = await db.raw.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final names = tables.map((row) => row['name']).toSet();
      expect(
        names,
        containsAll([
          'genres',
          'characters',
          'costumes',
          'diary',
          'lens_usage',
          'photos',
          'settings',
        ]),
      );
      expect(await db.raw.getVersion(), databaseVersion);
      await db.writeSetting('key', 'value');
      expect(await db.readSetting('key'), 'value');
    },
  );
}
