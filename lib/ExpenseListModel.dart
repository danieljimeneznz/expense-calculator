import 'dart:collection';
import 'package:scoped_model/scoped_model.dart';
import 'Expense.dart';
import 'Database.dart';

class ExpenseListModel extends Model {
  final List<Expense> _items = [];
  UnmodifiableListView<Expense> get items => UnmodifiableListView(_items);

  ExpenseListModel() {
    this.load();
  }

  double get totalExpense => items
      .map((item) => item.amount)
      .fold(0, (value, amount) => value + amount);

  void load() {
    Future<List<Expense>> list = SQLiteDbProvider.db.getAllExpenses();
    list.then((value) {
      value.forEach((e) => _items.add(e));
      notifyListeners();
    });
  }

  Expense byId(int id) {
    for(Expense e in _items) {
      if (e.id == id) {
        return e;
      }
    }
    return null;
  }

  void add(Expense item) {
    SQLiteDbProvider.db.insert(item).then((e) {
      _items.add(e);
      notifyListeners();
    });
  }

  void update(Expense item) {
    int index = _items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _items[index] = item;
      SQLiteDbProvider.db.update(item);
      notifyListeners();
    }
  }

  void delete(Expense item) {
    int index = _items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      SQLiteDbProvider.db.delete(item.id);
      _items.removeAt(index);
      notifyListeners();
    }
  }
}
