import 'package:flutter/material.dart';
import 'package:xpense/screens/home_screen.dart';
import 'db/app_db.dart';

final AppDatabase db = AppDatabase();

void main() {
  runApp(ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'xpense using Drift ORM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: HomeScreen(),
    );
  }
}
