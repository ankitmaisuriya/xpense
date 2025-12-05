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

  int? selectedCategoryId;
  List<Category> categoryList = [];

  @override
  void initState() {
    super.initState();
    db.getAllCategories().then((value) {
      setState(() {
        categoryList = value;

        if (widget.expense != null) {
          selectedCategoryId = widget.expense!.categoryId;
        }
      });
    });

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
            SizedBox(height: 15),
            // 🔥 FIXED DROPDOWN USING STREAMBUILDER
            StreamBuilder<List<Category>>(
              stream: db.watchCategories(),   // <- will include default categories
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final categories = snapshot.data!;

                if (selectedCategoryId == null && categories.isNotEmpty) {
                  selectedCategoryId = categories.first.id;
                }

                return DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  items: categories.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Select Category",
                    border: OutlineInputBorder(),
                  ),
                );
              },
            )
,

            SizedBox(height: 30),
            ElevatedButton(
              child: Text(widget.expense == null ? "Save" : "Update"),
              onPressed: () async {
                final title = titleCtrl.text.trim();
                final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;

                if (selectedCategoryId == null) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Please select category")));
                  return;
                }

                if (widget.expense == null) {
                  await db.insertExpense(
                    ExpensesCompanion.insert(
                      title: title,
                      amount: amount,
                      date: DateTime.now(),
                      categoryId: selectedCategoryId!,
                    ),
                  );
                } else {
                  await db.updateExpense(
                    widget.expense!.copyWith(
                      title: title,
                      amount: amount,
                      categoryId: selectedCategoryId!,
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
