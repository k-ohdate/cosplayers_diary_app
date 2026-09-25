import 'lens_models.dart';

class LensService {
  const LensService();

  DateTime? openedExpiresOn(LensProduct product, DateTime? openedOn) {
    if (openedOn == null || product.openPeriodDays == null) return null;
    return DateTime(openedOn.year, openedOn.month, openedOn.day).add(Duration(days: product.openPeriodDays!));
  }

  bool isOpenedExpired(LensProduct product, DateTime? openedOn, DateTime now) {
    final expiry = openedExpiresOn(product, openedOn);
    if (expiry == null) return false;
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(expiry);
  }

  int openedElapsedDays(DateTime? openedOn, DateTime now) => openedOn == null ? 0 : now.difference(openedOn).inDays.clamp(0, 1 << 31);
}

class LensLedger {
  LensLedger({Iterable<LensProduct> products = const []}) : products = List.of(products);

  final List<LensProduct> products;
  final List<LensPurchase> purchases = [];
  final List<LensInventory> inventories = [];
  final List<LensUsage> usages = [];
  int _sequence = 0;

  String _id(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';

  void addPurchase(LensPurchase purchase) {
    if (purchase.quantity < 0) throw ArgumentError.value(purchase.quantity, 'quantity');
    purchases.add(purchase);
  }

  int unusedCount(String purchaseId) {
    final purchase = _purchase(purchaseId);
    final allocated = inventories.where((item) => item.purchaseId == purchaseId).length;
    return (purchase.quantity - allocated).clamp(0, purchase.quantity);
  }

  LensInventory useOneDay({required String purchaseId, required String diaryId, required DateTime usedOn}) {
    final purchase = _purchase(purchaseId);
    final product = _product(purchase.productId);
    if (product.wearType != WearType.oneDay) throw StateError('ワンデー製品ではありません');
    removeDiaryUsage(diaryId);
    if (unusedCount(purchaseId) <= 0) throw StateError('未使用在庫がありません');
    final item = LensInventory(id: _id('inventory'), purchaseId: purchaseId, openedOn: usedOn, disposed: true);
    inventories.add(item);
    usages.add(LensUsage(id: _id('usage'), diaryId: diaryId, inventoryId: item.id, usedOn: usedOn));
    return item;
  }

  LensInventory openReusable({required String purchaseId, required DateTime openedOn}) {
    final purchase = _purchase(purchaseId);
    if (_product(purchase.productId).wearType == WearType.oneDay) throw StateError('ワンデーは個別開封できません');
    if (unusedCount(purchaseId) <= 0) throw StateError('未使用在庫がありません');
    final item = LensInventory(id: _id('inventory'), purchaseId: purchaseId, openedOn: openedOn);
    inventories.add(item);
    return item;
  }

  void useInventory({required String inventoryId, required String diaryId, required DateTime usedOn}) {
    final item = _inventory(inventoryId);
    final product = _product(_purchase(item.purchaseId).productId);
    final existingForItem = usages.where((e) => e.inventoryId == inventoryId).toList();
    if (product.wearType == WearType.oneDay && existingForItem.any((e) => e.diaryId != diaryId)) {
      throw StateError('ワンデーは再使用できません');
    }
    usages.removeWhere((usage) => usage.diaryId == diaryId);
    usages.add(LensUsage(id: _id('usage'), diaryId: diaryId, inventoryId: inventoryId, usedOn: usedOn));
  }

  void removeDiaryUsage(String diaryId) {
    final matched = usages.where((usage) => usage.diaryId == diaryId).toList();
    usages.removeWhere((usage) => usage.diaryId == diaryId);
    for (final usage in matched) {
      final item = _inventory(usage.inventoryId);
      final product = _product(_purchase(item.purchaseId).productId);
      if (product.wearType == WearType.oneDay) inventories.removeWhere((e) => e.id == item.id);
    }
  }

  int usageCount(String inventoryId) => usages.where((usage) => usage.inventoryId == inventoryId).length;

  DateTime? lastUsedOn(String inventoryId) {
    final dates = usages.where((usage) => usage.inventoryId == inventoryId).map((usage) => usage.usedOn).toList()..sort();
    return dates.isEmpty ? null : dates.last;
  }

  LensPurchase _purchase(String id) => purchases.firstWhere((value) => value.id == id, orElse: () => throw StateError('購入履歴が見つかりません'));
  LensProduct _product(String id) => products.firstWhere((value) => value.id == id, orElse: () => throw StateError('製品が見つかりません'));
  LensInventory _inventory(String id) => inventories.firstWhere((value) => value.id == id, orElse: () => throw StateError('実物が見つかりません'));
}
