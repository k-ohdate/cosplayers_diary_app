import 'diary_models.dart';

class DiaryService {
  const DiaryService();

  List<String> validate(DiaryEntry entry) {
    if (entry.activityType != ActivityType.cosplay) return const [];
    return [
      if (entry.genreId == null) 'ジャンル',
      if (entry.characterId == null) 'キャラクター',
      if (entry.costumeId == null) '衣装',
    ];
  }

  List<DiaryEntry> onDate(Iterable<DiaryEntry> entries, DateTime date) => entries
      .where((entry) => _sameDate(entry.activityDate, date))
      .toList(growable: false)
    ..sort((a, b) => a.activityDate.compareTo(b.activityDate));

  DiaryEntry duplicate(DiaryEntry source, {required String id, required DateTime date}) => source.copyWith(
        id: id,
        activityDate: date,
        clearLens: true,
        updatedAt: date,
      );

  bool _sameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
