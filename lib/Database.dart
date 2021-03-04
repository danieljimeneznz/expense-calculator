import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'Expense.dart';

class SQLiteDbProvider {
  // Don't want the constructor to be called publicly so this
  // is declared private by the underscore.
  SQLiteDbProvider._();

  static final SQLiteDbProvider db = SQLiteDbProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "ExpenseDB2.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE IF NOT EXISTS expense (id INTEGER PRIMARY KEY AUTOINCREMENT, amount REAL, date TEXT, category TEXT)");
    });
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    List<Map> results = await db.query("expense",
        columns: Expense.columns, orderBy: "date DESC");
    return results.map((result) => Expense.fromMap(result)).toList();
  }

  Future<Expense> getTotalExpenseById(int id) async {
    final db = await database;
    List<Map> result =
        await db.query("expense", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? Expense.fromMap(result.first) : null;
  }

  Future<double> getTotalExpense() async {
    final db = await database;
    List<Map> result =
        await db.rawQuery(("SELECT SUM(amount) as amount from expense"));
    return result.isNotEmpty ? result.first["amount"] : null;
  }

  Future<Expense> insert(Expense expense) async {
    final db = await database;
    int id = await db.insert("expense", {
      "amount": expense.amount,
      "date": expense.date.toString(),
      "category": expense.category
    });
    return Expense(id, expense.amount, expense.date, expense.category);
  }

  Future<void> update(Expense expense) async {
    final db = await database;
    await db.update("expense", expense.toMap(), where: "id = ?", whereArgs: [expense.id]);
  }

  Future<void> delete(int id) async {
    final db = await database;
    db.delete("expense", where: "id = ?", whereArgs: [id]);
  }
}
