import 'package:flutter/material.dart';

const appDestinations = <NavigationDestination>[
  NavigationDestination(
    icon: Icon(Icons.calendar_month_outlined),
    selectedIcon: Icon(Icons.calendar_month),
    label: 'カレンダー',
  ),
  NavigationDestination(
    icon: Icon(Icons.menu_book_outlined),
    selectedIcon: Icon(Icons.menu_book),
    label: '日記',
  ),
  NavigationDestination(
    icon: Icon(Icons.inventory_2_outlined),
    selectedIcon: Icon(Icons.inventory_2),
    label: '管理',
  ),
  NavigationDestination(
    icon: Icon(Icons.bar_chart_outlined),
    selectedIcon: Icon(Icons.bar_chart),
    label: '統計',
  ),
  NavigationDestination(
    icon: Icon(Icons.settings_outlined),
    selectedIcon: Icon(Icons.settings),
    label: '設定',
  ),
];

const pageTitles = ['カレンダー', '日記', 'マスターデータ・カラコン', 'ダッシュボード', '設定・バックアップ'];

class PlaceholderFeaturePage extends StatelessWidget {
  const PlaceholderFeaturePage({required this.title, super.key});
  final String title;

  @override
  Widget build(BuildContext context) => Center(
    child: Text('$title\nデータはこの端末内だけに保存されます', textAlign: TextAlign.center),
  );
}
