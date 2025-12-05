import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'expenses.dart';

part 'app_db.g.dart';

@DriftDatabase(tables: [Expenses, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;



  // Run only on first database creation
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      if (details.wasCreated) {
        await into(categories).insert(CategoriesCompanion.insert(name: "Food"));
        await into(
          categories,
        ).insert(CategoriesCompanion.insert(name: "Travel"));
        await into(
          categories,
        ).insert(CategoriesCompanion.insert(name: "Shopping"));
        await into(
          categories,
        ).insert(CategoriesCompanion.insert(name: "Bills"));
        await into(
          categories,
        ).insert(CategoriesCompanion.insert(name: "Other"));
      }
    },
  );

  // -------------------------- EXPENSE QUERIES ------------------------------

  Future<List<Expense>> getAllExpenses() =>
      (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  Stream<List<Expense>> watchAllExpenses() =>
      (select(expenses)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();

  Future<int> insertExpense(ExpensesCompanion data) =>
      into(expenses).insert(data);

  Future updateExpense(Expense row) => update(expenses).replace(row);

  Future deleteExpense(int id) =>
      (delete(expenses)..where((tbl) => tbl.id.equals(id))).go();

  // -------------------------- CATEGORY QUERIES ------------------------------

  Stream<List<Category>> watchCategories() => select(categories).watch();

  Future<List<Category>> getAllCategories() => select(categories).get();

  Future<int> insertCategory(CategoriesCompanion data) =>
      into(categories).insert(data);

  Future deleteCategory(int id) =>
      (delete(categories)..where((t) => t.id.equals(id))).go();

  // ----------------------- EXPENSE + CATEGORY JOIN --------------------------

  Stream<List<ExpenseWithCategory>> watchExpensesWithCategories() {
    final query = select(expenses).join([
      leftOuterJoin(categories, categories.id.equalsExp(expenses.categoryId)),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return ExpenseWithCategory(
          row.readTable(expenses),
          row.readTable(categories),
        );
      }).toList();
    });
  }

  Stream<List<Expense>> watchExpensesByCategory(int categoryId) {
    return (select(expenses)
          ..where((tbl) => tbl.categoryId.equals(categoryId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<Expense>> watchTotalExpenses() {
    return (select(expenses)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<double> getTotalByCategory(int categoryId) async {
    final result = await customSelect(
      'SELECT SUM(amount) AS total FROM expenses WHERE category_id = ?',
      variables: [Variable.withInt(categoryId)],
      readsFrom: {expenses},
    ).getSingle();

    return result.data['total'] == null
        ? 0.0
        : (result.data['total'] as double);
  }

  Stream<List<CategoryTotal>> watchCategoryTotals() {
    final query = customSelect(
      '''
      SELECT c.id, c.name, 
      SUM(e.amount) AS total 
      FROM categories c
      LEFT JOIN expenses e ON e.category_id = c.id
      GROUP BY c.id
    ''',
      readsFrom: {categories, expenses},
    );

    return query.watch().map((rows) {
      return rows.map((row) {
        return CategoryTotal(
          id: row.data['id'] as int,
          name: row.data['name'] as String,
          total: (row.data['total'] ?? 0.0) as double,
        );
      }).toList();
    });
  }

  Future<double> getTotalExpense() async {
    final exp = expenses.amount.sum();
    final query = selectOnly(expenses)..addColumns([exp]);
    final result = await query.map((row) => row.read(exp) ?? 0).getSingle();
    return result;
  }

  // Future<double> getTotalByCategory(String category) async {
  //   final sumExp = expenses.amount.sum();
  //
  //   final query = selectOnly(expenses)
  //     ..addColumns([sumExp])
  //     ..where(expenses.category.equals(category));
  //
  //   final result = await query.map((row) => row.read(sumExp) ?? 0).getSingle();
  //   return result;
  // }
}

// ----------------------------- DATABASE OPENING -------------------------------

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'expense.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// ----------------------------- MODEL CLASS -----------------------------------

class ExpenseWithCategory {
  final Expense expense;
  final Category? category;

  ExpenseWithCategory(this.expense, this.category);
}

class CategoryTotal {
  final int id;
  final String name;
  final double total;

  CategoryTotal({required this.id, required this.name, required this.total});
}
