import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/expense_tile.dart';
import '../screens/add_expense_screen.dart';
import '../db/app_db.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expense Tracker")),
      body: StreamBuilder<List<Expense>>(
        stream: db.watchAllExpenses(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final expenses = snapshot.data!;

          if (expenses.isEmpty) {
            return Center(child: Text("No expenses added yet."));
          }

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (_, index) => ExpenseTile(expenses[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddExpenseScreen()),
        ),
      ),
    );
  }
}
