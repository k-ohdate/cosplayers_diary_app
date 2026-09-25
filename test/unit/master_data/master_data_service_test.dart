import 'package:cosplayers_diary/features/master_data/domain/master_models.dart';
import 'package:cosplayers_diary/features/master_data/domain/master_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = MasterDataService();
  final genres = [
    const Genre(id: 'g1', name: '作品A'),
    const Genre(id: 'g2', name: '作品B'),
  ];
  final characters = [
    const CosplayCharacter(id: 'c1', genreId: 'g1', name: '主人公'),
    const CosplayCharacter(id: 'c2', genreId: 'g2', name: 'ライバル'),
    const CosplayCharacter(
      id: 'c3',
      genreId: 'g1',
      name: '旧キャラ',
      archived: true,
    ),
  ];
  final costumes = [
    const Costume(id: 's1', name: '制服', isGeneral: true),
    const Costume(id: 's2', name: '専用', isGeneral: false, characterId: 'c1'),
    const Costume(
      id: 's3',
      name: '他キャラ専用',
      isGeneral: false,
      characterId: 'c2',
    ),
    const Costume(id: 's4', name: '旧衣装', isGeneral: true, archived: true),
  ];

  test('genre filters active characters by stable genre id', () {
    expect(
      service.charactersForGenre(characters, genres.first).map((e) => e.id),
      ['c1'],
    );
  });

  test('character sees general and own costumes only', () {
    expect(
      service.costumesForCharacter(costumes, characters.first).map((e) => e.id),
      ['s1', 's2'],
    );
  });

  test('archived masters remain resolvable for historical diary', () {
    expect(service.findCharacter(characters, 'c3')?.name, '旧キャラ');
    expect(service.activeGenres(genres).length, 2);
  });
}
