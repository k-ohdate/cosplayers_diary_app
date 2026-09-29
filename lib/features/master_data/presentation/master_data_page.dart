import 'package:flutter/material.dart';

import '../application/master_data_store.dart';

class MasterDataPage extends StatefulWidget {
  const MasterDataPage({required this.store, super.key});
  final MasterDataStore store;

  @override
  State<MasterDataPage> createState() => _MasterDataPageState();
}

class _MasterDataPageState extends State<MasterDataPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) => Column(
      children: [
        TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'ジャンル'),
            Tab(text: 'キャラクター'),
            Tab(text: '衣装'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _MasterList(
                empty: 'ジャンルを登録してください',
                names: [
                  for (final e in widget.store.genres.where((e) => !e.archived))
                    e.name,
                ],
                onArchive: (index) => widget.store.archiveGenre(
                  widget.store.genres
                      .where((e) => !e.archived)
                      .elementAt(index)
                      .id,
                ),
              ),
              _MasterList(
                empty: 'キャラクターを登録してください',
                names: [
                  for (final e in widget.store.characters.where(
                    (e) => !e.archived,
                  ))
                    e.name,
                ],
                onArchive: (index) => widget.store.archiveCharacter(
                  widget.store.characters
                      .where((e) => !e.archived)
                      .elementAt(index)
                      .id,
                ),
              ),
              _MasterList(
                empty: '衣装を登録してください',
                names: [
                  for (final e in widget.store.costumes.where(
                    (e) => !e.archived,
                  ))
                    e.name,
                ],
                onArchive: (index) => widget.store.archiveCostume(
                  widget.store.costumes
                      .where((e) => !e.archived)
                      .elementAt(index)
                      .id,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('追加'),
          ),
        ),
      ],
    ),
  );

  Future<void> _add() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${['ジャンル', 'キャラクター', '衣装'][_tabs.index]}を追加'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: '名前'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    if (_tabs.index == 0) {
      widget.store.addGenre(name);
    } else if (_tabs.index == 1 &&
        widget.store.genres.any((e) => !e.archived)) {
      widget.store.addCharacter(
        widget.store.genres.firstWhere((e) => !e.archived).id,
        name,
      );
    } else if (_tabs.index == 2) {
      widget.store.addCostume(name, isGeneral: true);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('先にジャンルを登録してください')));
    }
  }
}

class _MasterList extends StatelessWidget {
  const _MasterList({
    required this.empty,
    required this.names,
    required this.onArchive,
  });
  final String empty;
  final List<String> names;
  final ValueChanged<int> onArchive;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return Center(child: Text(empty));
    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(names[index]),
        trailing: IconButton(
          tooltip: 'アーカイブ',
          icon: const Icon(Icons.archive_outlined),
          onPressed: () => onArchive(index),
        ),
      ),
    );
  }
}
