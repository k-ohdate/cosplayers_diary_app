enum WearType {
  oneDay('ワンデー'),
  twoWeeks('2週間'),
  monthly('1か月'),
  other('その他');

  const WearType(this.label);
  final String label;
}

class LensProduct {
  const LensProduct({
    required this.id,
    required this.name,
    required this.manufacturer,
    required this.color,
    required this.wearType,
    this.openPeriodDays,
    this.memo = '',
    this.archived = false,
  });
  final String id;
  final String name;
  final String manufacturer;
  final String color;
  final WearType wearType;
  final int? openPeriodDays;
  final String memo;
  final bool archived;
}

class LensPurchase {
  const LensPurchase({
    required this.id,
    required this.productId,
    required this.purchasedOn,
    required this.quantity,
    this.unopenedExpiresOn,
  }) : assert(quantity >= 0);
  final String id;
  final String productId;
  final DateTime purchasedOn;
  final DateTime? unopenedExpiresOn;
  final int quantity;
}

class LensInventory {
  const LensInventory({
    required this.id,
    required this.purchaseId,
    this.openedOn,
    this.disposed = false,
  });
  final String id;
  final String purchaseId;
  final DateTime? openedOn;
  final bool disposed;
}

class LensUsage {
  const LensUsage({
    required this.id,
    required this.diaryId,
    required this.inventoryId,
    required this.usedOn,
  });
  final String id;
  final String diaryId;
  final String inventoryId;
  final DateTime usedOn;
}
