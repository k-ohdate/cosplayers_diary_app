import 'package:flutter/foundation.dart';

import '../domain/master_models.dart';

class MasterDataStore extends ChangeNotifier {
  final List<Genre> genres = [];
  final List<CosplayCharacter> characters = [];
  final List<Costume> costumes = [];
  int _sequence = 0;

  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';

  Genre addGenre(String name, {String memo = ''}) {
    final value = Genre(id: _id('genre'), name: name.trim(), memo: memo.trim());
    genres.add(value);
    notifyListeners();
    return value;
  }

  CosplayCharacter addCharacter(
    String genreId,
    String name, {
    String memo = '',
  }) {
    final value = CosplayCharacter(
      id: _id('character'),
      genreId: genreId,
      name: name.trim(),
      memo: memo.trim(),
    );
    characters.add(value);
    notifyListeners();
    return value;
  }

  Costume addCostume(
    String name, {
    required bool isGeneral,
    String? characterId,
    String memo = '',
  }) {
    final value = Costume(
      id: _id('costume'),
      name: name.trim(),
      isGeneral: isGeneral,
      characterId: isGeneral ? null : characterId,
      memo: memo.trim(),
    );
    costumes.add(value);
    notifyListeners();
    return value;
  }

  void archiveGenre(String id) =>
      _replaceGenre(id, (value) => value.copyWith(archived: true));
  void archiveCharacter(String id) =>
      _replaceCharacter(id, (value) => value.copyWith(archived: true));
  void archiveCostume(String id) =>
      _replaceCostume(id, (value) => value.copyWith(archived: true));

  void _replaceGenre(String id, Genre Function(Genre) update) {
    final index = genres.indexWhere((e) => e.id == id);
    if (index >= 0) genres[index] = update(genres[index]);
    notifyListeners();
  }

  void _replaceCharacter(
    String id,
    CosplayCharacter Function(CosplayCharacter) update,
  ) {
    final index = characters.indexWhere((e) => e.id == id);
    if (index >= 0) characters[index] = update(characters[index]);
    notifyListeners();
  }

  void _replaceCostume(String id, Costume Function(Costume) update) {
    final index = costumes.indexWhere((e) => e.id == id);
    if (index >= 0) costumes[index] = update(costumes[index]);
    notifyListeners();
  }
}
