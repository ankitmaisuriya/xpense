import 'package:flutter/material.dart';
import '../db/app_db.dart';
import '../main.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  AddExpenseScreen({this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      titleCtrl.text = widget.expense!.title;
      amountCtrl.text = widget.expense!.amount.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? "Add Expense" : "Edit Expense"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Amount"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(widget.expense == null ? "Save" : "Update"),
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;

                if (widget.expense == null) {
                  await db.insertExpense(
                    ExpensesCompanion.insert(
                      title: title,
                      amount: amount,
                      date: DateTime.now(),
                    ),
                  );
                } else {
                  await db.updateExpense(
                    widget.expense!.copyWith(
                      title: title,
                      amount: amount,
                    ),
                  );
                }

                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
