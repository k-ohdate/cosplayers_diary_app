import 'package:flutter/material.dart';

import '../application/lens_store.dart';
import '../domain/lens_models.dart';

class LensPage extends StatelessWidget {
  const LensPage({required this.store, super.key});
  final LensStore store;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: store,
        builder: (context, _) => Scaffold(
          body: ListView(padding: const EdgeInsets.all(12), children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('使用期限はメーカー表示を優先してください。アプリの計算は管理の目安です。'),
              ),
            ),
            if (store.ledger.products.isEmpty)
              const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('カラコン製品はまだありません'))),
            for (final product in store.ledger.products)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.remove_red_eye_outlined),
                  title: Text(product.name),
                  subtitle: Text('${product.manufacturer} / ${product.color} / ${product.wearType.label}'),
                  trailing: Text('在庫 ${store.ledger.purchases.where((e) => e.productId == product.id).fold<int>(0, (sum, e) => sum + store.ledger.unusedCount(e.id))}'),
                  onTap: () => _addPurchase(context, product),
                ),
              ),
          ]),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addProduct(context),
            icon: const Icon(Icons.add), label: const Text('製品'),
          ),
        ),
      );

  Future<void> _addProduct(BuildContext context) async {
    final name = TextEditingController();
    final maker = TextEditingController();
    final color = TextEditingController();
    WearType type = WearType.oneDay;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setState) => AlertDialog(
        title: const Text('カラコン製品を追加'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: '製品名')),
          const SizedBox(height: 8),
          TextField(controller: maker, decoration: const InputDecoration(labelText: 'メーカー')),
          const SizedBox(height: 8),
          TextField(controller: color, decoration: const InputDecoration(labelText: 'カラー')),
          const SizedBox(height: 8),
          DropdownButtonFormField<WearType>(
            initialValue: type,
            decoration: const InputDecoration(labelText: '装用タイプ'),
            items: [for (final value in WearType.values) DropdownMenuItem(value: value, child: Text(value.label))],
            onChanged: (value) => setState(() => type = value!),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('保存')),
        ],
      )),
    );
    if (saved == true && name.text.trim().isNotEmpty) {
      store.addProduct(
        name: name.text.trim(), manufacturer: maker.text.trim(), color: color.text.trim(), type: type,
        periodDays: switch (type) { WearType.oneDay => 1, WearType.twoWeeks => 14, WearType.monthly => 30, WearType.other => null },
      );
    }
    name.dispose(); maker.dispose(); color.dispose();
  }

  Future<void> _addPurchase(BuildContext context, LensProduct product) async {
    final quantity = TextEditingController(text: '1');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${product.name} の購入'),
        content: TextField(controller: quantity, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: '数量')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('保存')),
        ],
      ),
    );
    final count = int.tryParse(quantity.text);
    quantity.dispose();
    if (saved == true && count != null && count > 0) {
      store.addPurchase(productId: product.id, purchasedOn: DateTime.now(), quantity: count);
    }
  }
}
