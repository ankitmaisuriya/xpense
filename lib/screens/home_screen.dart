import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/expense_tile.dart';
import '../screens/add_expense_screen.dart';
import '../db/app_db.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? selectedCategoryFilter; // null = show all categories
  late Future<double> totalExpenseFuture;

  @override
  void initState() {
    super.initState();
    totalExpenseFuture = db.getTotalExpense();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Xpense Tracker")),

      body: Column(
        children: [
          // ----------------------------------------------------
          // 🔥 CATEGORY FILTER DROPDOWN
          // ----------------------------------------------------
          StreamBuilder<List<Category>>(
            stream: db.watchCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return SizedBox();

              final categories = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<int>(
                  value: selectedCategoryFilter ?? 0,  // 👈 if null → show "All"
                  decoration: InputDecoration(labelText: "Filter by Category"),
                  items: [
                    DropdownMenuItem(
                      value: 0,
                      child: Text("All"),
                    ),
                    ...categories.map(
                          (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value == 0) {
                        selectedCategoryFilter = null;
                        totalExpenseFuture = db.getTotalExpense();   // show all total
                      } else {
                        selectedCategoryFilter = value;
                        totalExpenseFuture = db.getTotalByCategory(selectedCategoryFilter!);
                      }
                    });
                  },
                )
                ,
              );
            },
          ),
          FutureBuilder<double>(
            future: totalExpenseFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Total Expense: ₹ ${snapshot.data!.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // ----------------------------------------------------
          // 🔥 FILTERED EXPENSE LIST
          // ----------------------------------------------------
          Expanded(
            child: StreamBuilder<List<ExpenseWithCategory>>(
              stream: db.watchExpensesWithCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var items = snapshot.data!;

                // Apply filter
                if (selectedCategoryFilter != null) {
                  items = items
                      .where((e) => e.expense.categoryId == selectedCategoryFilter)
                      .toList();
                }

                if (items.isEmpty) {
                  return Center(child: Text("No expenses"));
                }

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, index) => ExpenseTile(items[index]),
                );
              },
            ),
          ),
        ],
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
