class Genre {
  const Genre({
    required this.id,
    required this.name,
    this.memo = '',
    this.archived = false,
  });
  final String id;
  final String name;
  final String memo;
  final bool archived;

  Genre copyWith({String? name, String? memo, bool? archived}) => Genre(
    id: id,
    name: name ?? this.name,
    memo: memo ?? this.memo,
    archived: archived ?? this.archived,
  );
}

class CosplayCharacter {
  const CosplayCharacter({
    required this.id,
    required this.genreId,
    required this.name,
    this.memo = '',
    this.lensProductIds = const [],
    this.defaultLensProductId,
    this.archived = false,
  });
  final String id;
  final String genreId;
  final String name;
  final String memo;
  final List<String> lensProductIds;
  final String? defaultLensProductId;
  final bool archived;

  CosplayCharacter copyWith({String? name, String? memo, bool? archived}) =>
      CosplayCharacter(
        id: id,
        genreId: genreId,
        name: name ?? this.name,
        memo: memo ?? this.memo,
        lensProductIds: lensProductIds,
        defaultLensProductId: defaultLensProductId,
        archived: archived ?? this.archived,
      );
}

class Costume {
  const Costume({
    required this.id,
    required this.name,
    required this.isGeneral,
    this.characterId,
    this.memo = '',
    this.archived = false,
  }) : assert(isGeneral || characterId != null);
  final String id;
  final String name;
  final bool isGeneral;
  final String? characterId;
  final String memo;
  final bool archived;

  Costume copyWith({String? name, String? memo, bool? archived}) => Costume(
    id: id,
    name: name ?? this.name,
    isGeneral: isGeneral,
    characterId: characterId,
    memo: memo ?? this.memo,
    archived: archived ?? this.archived,
  );
}
