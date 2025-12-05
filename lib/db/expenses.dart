import 'package:drift/drift.dart';

class Expenses extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();

  IntColumn get categoryId => integer().references(Categories, #id)();
}

class Categories extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1,max: 50)();
}