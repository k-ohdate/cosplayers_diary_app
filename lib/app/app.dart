import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';
import '../features/master_data/application/master_data_store.dart';
import '../features/diary/application/diary_store.dart';
import '../features/diary/presentation/diary_pages.dart';
import '../features/contact_lenses/application/lens_store.dart';
import '../features/master_data/presentation/management_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';

class CosplayDiaryApp extends StatelessWidget {
  const CosplayDiaryApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'コスプレ日記',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AppShell(),
      );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final _masterStore = MasterDataStore();
  final _diaryStore = DiaryStore();
  final _lensStore = LensStore();

  @override
  void dispose() {
    _masterStore.dispose();
    _diaryStore.dispose();
    _lensStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final body = switch (_index) {
      0 => CalendarPage(store: _diaryStore, masterStore: _masterStore),
      1 => DiaryListPage(store: _diaryStore, masterStore: _masterStore),
      2 => ManagementPage(masterStore: _masterStore, lensStore: _lensStore),
      3 => DashboardPage(diaryStore: _diaryStore, lensStore: _lensStore),
      _ => PlaceholderFeaturePage(title: pageTitles[_index]),
    };
    final content = wide
        ? Row(children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final destination in appDestinations)
                  NavigationRailDestination(
                    icon: destination.icon,
                    selectedIcon: destination.selectedIcon,
                    label: Text(destination.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ])
        : body;

    return Scaffold(
      appBar: AppBar(title: Text(pageTitles[_index])),
      body: SafeArea(child: content),
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              destinations: appDestinations,
            ),
    );
  }
}
