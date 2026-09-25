import 'package:cosplayers_diary/features/contact_lenses/domain/lens_models.dart';
import 'package:cosplayers_diary/features/contact_lenses/domain/lens_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final reusable = LensProduct(id: 'p1', name: 'Blue', manufacturer: 'Maker', color: '青', wearType: WearType.monthly, openPeriodDays: 30);
  final oneDay = LensProduct(id: 'p2', name: 'Red', manufacturer: 'Maker', color: '赤', wearType: WearType.oneDay, openPeriodDays: 1);
  const service = LensService();

  test('purchase date does not affect opened expiry', () {
    expect(service.openedExpiresOn(reusable, DateTime(2026, 2, 10)), DateTime(2026, 3, 12));
  });

  test('unopened item has no opened expiry', () {
    expect(service.openedExpiresOn(reusable, null), isNull);
  });

  test('expiry boundary is valid through expiry date and expired next day', () {
    expect(service.isOpenedExpired(reusable, DateTime(2026, 1, 1), DateTime(2026, 1, 31)), isFalse);
    expect(service.isOpenedExpired(reusable, DateTime(2026, 1, 1), DateTime(2026, 2, 1)), isTrue);
  });

  group('ledger', () {
    late LensLedger ledger;
    setUp(() {
      ledger = LensLedger(products: [reusable, oneDay]);
      ledger.addPurchase(LensPurchase(id: 'buy1', productId: 'p2', purchasedOn: DateTime(2026, 1, 1), quantity: 2));
      ledger.addPurchase(LensPurchase(id: 'buy2', productId: 'p2', purchasedOn: DateTime(2026, 2, 1), quantity: 3));
      ledger.addPurchase(LensPurchase(id: 'buy3', productId: 'p1', purchasedOn: DateTime(2026, 1, 1), quantity: 1));
    });

    test('one-day usage consumes stock and cannot reuse an item', () {
      final item = ledger.useOneDay(purchaseId: 'buy1', diaryId: 'd1', usedOn: DateTime(2026, 2, 1));
      expect(ledger.unusedCount('buy1'), 1);
      expect(() => ledger.useInventory(inventoryId: item.id, diaryId: 'd2', usedOn: DateTime(2026, 2, 2)), throwsStateError);
    });

    test('multiple purchases keep independent stock and never negative', () {
      ledger.useOneDay(purchaseId: 'buy1', diaryId: 'd1', usedOn: DateTime(2026, 2, 1));
      ledger.useOneDay(purchaseId: 'buy1', diaryId: 'd2', usedOn: DateTime(2026, 2, 2));
      expect(() => ledger.useOneDay(purchaseId: 'buy1', diaryId: 'd3', usedOn: DateTime(2026, 2, 3)), throwsStateError);
      expect(ledger.unusedCount('buy1'), 0);
      expect(ledger.unusedCount('buy2'), 3);
    });

    test('same diary is not counted twice', () {
      final item = ledger.openReusable(purchaseId: 'buy3', openedOn: DateTime(2026, 1, 10));
      ledger.useInventory(inventoryId: item.id, diaryId: 'd1', usedOn: DateTime(2026, 1, 10));
      ledger.useInventory(inventoryId: item.id, diaryId: 'd1', usedOn: DateTime(2026, 1, 11));
      expect(ledger.usages, hasLength(1));
      expect(ledger.usages.single.usedOn, DateTime(2026, 1, 11));
    });

    test('reusable usage count and last date are calculated', () {
      final item = ledger.openReusable(purchaseId: 'buy3', openedOn: DateTime(2026, 1, 10));
      ledger.useInventory(inventoryId: item.id, diaryId: 'd1', usedOn: DateTime(2026, 1, 10));
      ledger.useInventory(inventoryId: item.id, diaryId: 'd2', usedOn: DateTime(2026, 1, 14));
      expect(ledger.usageCount(item.id), 2);
      expect(ledger.lastUsedOn(item.id), DateTime(2026, 1, 14));
    });

    test('editing diary moves usage without changing reusable stock', () {
      final item = ledger.openReusable(purchaseId: 'buy3', openedOn: DateTime(2026, 1, 10));
      ledger.useInventory(inventoryId: item.id, diaryId: 'd1', usedOn: DateTime(2026, 1, 10));
      ledger.useInventory(inventoryId: item.id, diaryId: 'd1', usedOn: DateTime(2026, 1, 20));
      expect(ledger.usageCount(item.id), 1);
      expect(ledger.unusedCount('buy3'), 0);
    });

    test('deleting diary cancels use and restores one-day stock', () {
      ledger.useOneDay(purchaseId: 'buy1', diaryId: 'd1', usedOn: DateTime(2026, 2, 1));
      ledger.removeDiaryUsage('d1');
      expect(ledger.usages, isEmpty);
      expect(ledger.unusedCount('buy1'), 2);
    });
  });
}
