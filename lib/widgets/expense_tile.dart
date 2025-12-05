import 'package:flutter/material.dart';
import '../db/app_db.dart';
import '../main.dart';
import '../screens/add_expense_screen.dart';

class ExpenseTile extends StatelessWidget {
  final ExpenseWithCategory data;

  ExpenseTile(this.data);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        data.expense.title,
        style: TextStyle(fontSize: 18),
      ),
      subtitle: Text(
        "Category: ${data.category?.name ?? 'No Category'}\n"
            "${data.expense.date.day}/${data.expense.date.month}/${data.expense.date.year}",
      ),
      trailing: Text(
        "₹${data.expense.amount}",
        style: TextStyle(fontSize: 17),
      ),

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
                      builder: (_) => AddExpenseScreen(expense: data.expense),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text("Delete"),
                onTap: () async {
                  await db.deleteExpense(data.expense.id);
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
