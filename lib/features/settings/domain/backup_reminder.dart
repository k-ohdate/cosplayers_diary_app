class BackupReminderPolicy {
  const BackupReminderPolicy({this.interval = const Duration(days: 30)});
  final Duration interval;

  bool shouldRemind({required DateTime? lastBackupAt, required DateTime now}) {
    if (lastBackupAt == null) return true;
    final elapsed = now.difference(lastBackupAt);
    return !elapsed.isNegative && elapsed >= interval;
  }
}
