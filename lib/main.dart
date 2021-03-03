import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'ExpenseListModel.dart';
import 'Expense.dart';

void main() {
  final expenses = ExpenseListModel();
  runApp(ScopedModel<ExpenseListModel>(model: expenses, child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of the application

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Expense',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MyHomePage(title: 'Expense calculator'));
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(this.title)),
      body: ScopedModelDescendant<ExpenseListModel>(
        builder: (context, child, expenses) {
          return ListView.separated(
              itemBuilder: (context, index) {
                if (index == 0) {
                  return TotalExpensesHeader(
                      totalExpense: expenses.totalExpense.toString());
                }

                index = index - 1;
                Expense expense = expenses.items[index];
                return Dismissible(
                  key: Key(expense.id.toString()),
                  onDismissed: (direction) {
                    expenses.delete(expense);
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Item with id, ${expense.id.toString()} is dismissed")));
                  },
                  child: ListTile(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => null));
                    },
                    leading: Icon(Icons.monetization_on),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    title: Text(
                        "${expense.category} \nspent on ${expense.formattedDate}",
                        style: TextStyle(
                            fontSize: 18, fontStyle: FontStyle.italic)),
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount:
                  expenses.items == null ? 1 : expenses.items.length + 1);
        },
      ),
      floatingActionButton: ScopedModelDescendant<ExpenseListModel>(
        builder: (context, child, expenses) => FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ScopedModelDescendant<ExpenseListModel>(
                            builder: (context, child, expenses) => null)));
          },
          tooltip: 'Increment',
          child: Icon(Icons.add)
        ),
      ),
    );
  }
}

class TotalExpensesHeader extends StatelessWidget {
  TotalExpensesHeader({this.totalExpense});
  final String totalExpense;

  @override
  Widget build(BuildContext context) => ListTile(
      title: Text('Total expenses: $totalExpense',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
}
