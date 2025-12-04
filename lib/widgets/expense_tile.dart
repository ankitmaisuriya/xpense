import 'package:flutter/material.dart';
import '../db/app_db.dart';
import '../main.dart';
import '../screens/add_expense_screen.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;

  ExpenseTile(this.expense);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(expense.title, style: TextStyle(fontSize: 18)),
      subtitle: Text(
        "${expense.date.day}/${expense.date.month}/${expense.date.year}",
      ),
      trailing: Text("₹${expense.amount}", style: TextStyle(fontSize: 17)),
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text("Edit"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddExpenseScreen(expense: expense),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Delete"),
                onTap: () async {
                  await db.deleteExpense(expense.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
