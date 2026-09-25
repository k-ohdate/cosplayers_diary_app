import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await AppDatabase.openDefault();
  runApp(CosplayDiaryApp(database: database));
}
