import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

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

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 600;
    final body = PlaceholderFeaturePage(title: pageTitles[_index]);
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
