import 'package:cosplayers_diary/features/backup/domain/csv_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = CsvService();

  test('accepts UTF-8 BOM and quoted comma', () {
    final rows = service.parse('\uFEFFid,name,memo\r\ng1,"作品, A","改行\nあり"\r\n');
    expect(rows.single['id'], 'g1');
    expect(rows.single['name'], '作品, A');
    expect(rows.single['memo'], '改行\nあり');
  });

  test('reports duplicate id and missing required value', () {
    final result = service.validate(
      service.parse('id,name\ng1,A\ng1,\n'),
      schema: const CsvSchema(requiredColumns: {'id', 'name'}),
    );
    expect(result.errors.join('\n'), contains('重複ID'));
    expect(result.errors.join('\n'), contains('name'));
  });

  test('validates ISO date integer and references', () {
    final result = service.validate(
      service.parse('id,date,count,genre_id\nd1,2026-99-01,-x,missing\n'),
      schema: const CsvSchema(
        requiredColumns: {'id', 'date'}, dateColumns: {'date'}, integerColumns: {'count'},
        references: {'genre_id': {'g1'}},
      ),
    );
    expect(result.errors, hasLength(3));
  });

  test('preview distinguishes add overwrite and replace', () {
    final rows = service.parse('id,name\ng1,new\ng2,two\n');
    final append = service.preview(rows, existingIds: {'g1'}, mode: ImportMode.append);
    final overwrite = service.preview(rows, existingIds: {'g1'}, mode: ImportMode.overwrite);
    final replace = service.preview(rows, existingIds: {'g1', 'old'}, mode: ImportMode.replaceAll);
    expect((append.added, append.updated, append.deleted), (1, 0, 0));
    expect((overwrite.added, overwrite.updated), (1, 1));
    expect(replace.deleted, 1);
  });
}
