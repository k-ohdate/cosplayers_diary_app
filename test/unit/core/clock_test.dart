import 'package:cosplayers_diary/core/services/clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FixedClock always returns the injected instant', () {
    final instant = DateTime(2026, 4, 12, 9, 30);
    expect(FixedClock(instant).now(), instant);
  });
}
