import 'package:cosplayers_diary/core/database/schema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('schema exposes an ordered initial migration', () {
    expect(databaseVersion, greaterThanOrEqualTo(1));
    expect(migrations.first.version, 1);
    expect(
      migrations.first.statements.join('\n'),
      contains('CREATE TABLE genres'),
    );
  });
}
