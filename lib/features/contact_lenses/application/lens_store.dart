import 'package:flutter/foundation.dart';

import '../domain/lens_models.dart';
import '../domain/lens_service.dart';

class LensStore extends ChangeNotifier {
  LensStore() : ledger = LensLedger();
  final LensLedger ledger;
  int _sequence = 0;

  String _id(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_sequence++}';

  LensProduct addProduct({
    required String name,
    required String manufacturer,
    required String color,
    required WearType type,
    int? periodDays,
  }) {
    final product = LensProduct(
      id: _id('lens'),
      name: name,
      manufacturer: manufacturer,
      color: color,
      wearType: type,
      openPeriodDays: periodDays,
    );
    ledger.products.add(product);
    notifyListeners();
    return product;
  }

  LensPurchase addPurchase({
    required String productId,
    required DateTime purchasedOn,
    required int quantity,
    DateTime? expiresOn,
  }) {
    final purchase = LensPurchase(
      id: _id('purchase'),
      productId: productId,
      purchasedOn: purchasedOn,
      quantity: quantity,
      unopenedExpiresOn: expiresOn,
    );
    ledger.addPurchase(purchase);
    notifyListeners();
    return purchase;
  }

  void cancelDiaryUsage(String diaryId) {
    ledger.removeDiaryUsage(diaryId);
    notifyListeners();
  }
}
