import 'package:cosplayers_diary/features/dashboard/domain/statistics_service.dart';
import 'package:cosplayers_diary/features/diary/domain/diary_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = StatisticsService();
  final entries = [
    DiaryEntry(id: 'd1', activityDate: DateTime(2026, 1, 1, 9), activityType: ActivityType.cosplay, genreId: 'g1', characterId: 'c1', costumeId: 's1'),
    DiaryEntry(id: 'd2', activityDate: DateTime(2026, 1, 1, 18), activityType: ActivityType.cosplay, genreId: 'g1', characterId: 'c2', costumeId: 's2'),
    DiaryEntry(id: 'd3', activityDate: DateTime(2026, 1, 1, 20), activityType: ActivityType.photographer),
    DiaryEntry(id: 'd4', activityDate: DateTime(2026, 2, 2), activityType: ActivityType.photographer),
    DiaryEntry(id: 'd5', activityDate: DateTime(2025, 3, 1), activityType: ActivityType.cosplay, genreId: 'g2', characterId: 'c1', costumeId: 's1'),
  ];

  test('counts entries and unique activity dates separately', () {
    final result = service.calculate(entries, year: 2026);
    expect(result.cosplayCount, 2);
    expect(result.cosplayDays, 1);
    expect(result.photographerCount, 2);
    expect(result.photographerDays, 2);
    expect(result.overlapDays, 1);
  });

  test('provides monthly counts and ties for leaders', () {
    final result = service.calculate(entries, year: 2026);
    expect(result.cosplayByMonth[1], 2);
    expect(result.photographerByMonth[2], 1);
    expect(result.topCharacters.map((e) => e.id).toSet(), {'c1', 'c2'});
  });

  test('null year calculates all time and empty input is supported', () {
    expect(service.calculate(entries).cosplayCount, 3);
    expect(service.calculate(const []).topCharacters, isEmpty);
  });
}
