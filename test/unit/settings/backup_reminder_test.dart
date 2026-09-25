import 'package:cosplayers_diary/features/settings/domain/backup_reminder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const policy = BackupReminderPolicy(interval: Duration(days: 30));
  final now = DateTime(2026, 6, 30, 12);

  test('reminds when never backed up or interval reached', () {
    expect(policy.shouldRemind(lastBackupAt: null, now: now), isTrue);
    expect(
      policy.shouldRemind(
        lastBackupAt: now.subtract(const Duration(days: 30)),
        now: now,
      ),
      isTrue,
    );
  });

  test('does not remind before interval and handles future clock safely', () {
    expect(
      policy.shouldRemind(
        lastBackupAt: now.subtract(const Duration(days: 29)),
        now: now,
      ),
      isFalse,
    );
    expect(
      policy.shouldRemind(
        lastBackupAt: now.add(const Duration(days: 1)),
        now: now,
      ),
      isFalse,
    );
  });
}
