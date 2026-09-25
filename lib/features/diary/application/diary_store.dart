import 'package:flutter/foundation.dart';

import '../domain/diary_models.dart';
import '../domain/diary_service.dart';

class DiaryStore extends ChangeNotifier {
  DiaryStore({this.service = const DiaryService()});
  final DiaryService service;
  final List<DiaryEntry> entries = [];
  int _sequence = 0;

  String nextId() =>
      'diary-${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';

  void save(DiaryEntry entry) {
    final errors = service.validate(entry);
    if (errors.isNotEmpty) throw ArgumentError('必須項目: ${errors.join('、')}');
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index < 0) {
      entries.add(entry);
    } else {
      entries[index] = entry;
    }
    entries.sort((a, b) => b.activityDate.compareTo(a.activityDate));
    notifyListeners();
  }

  void delete(String id) {
    entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  DiaryEntry duplicate(DiaryEntry source, DateTime date) {
    final copy = service.duplicate(source, id: nextId(), date: date);
    save(copy);
    return copy;
  }
}
