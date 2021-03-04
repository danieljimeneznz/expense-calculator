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
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FormPage(
                                  id: expense.id, expenses: expenses)));
                    },
                    leading: Icon(Icons.monetization_on),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    title: Text(
                        "${expense.category}: ${expense.amount}\nspent on ${expense.formattedDate}",
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
                              builder: (context, child, expenses) =>
                                  FormPage(id: 0, expenses: expenses))));
            },
            tooltip: 'Increment',
            child: Icon(Icons.add)),
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

class FormPage extends StatefulWidget {
  final int id;
  final ExpenseListModel expenses;

  FormPage({this.id, this.expenses});

  @override
  _FormPageState createState() => _FormPageState(id: id, expenses: expenses);
}

class _FormPageState extends State<FormPage> {
  final int id;
  final ExpenseListModel expenses;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  double _amount;
  DateTime _date;
  String _category;

  _FormPageState({this.id, this.expenses});

  void _submit() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      this.id == 0
          ? expenses.add(Expense(0, _amount, _date, _category))
          : expenses.update(Expense(this.id, _amount, _date, _category));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Expense expense = id != 0 ? expenses.byId(id) : null;
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(title: Text('Enter expense details')),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      style: TextStyle(fontSize: 22),
                      decoration: InputDecoration(
                          icon: Icon(Icons.monetization_on),
                          labelText: "Amount",
                          labelStyle: TextStyle(fontSize: 18)),
                      validator: (val) {
                        RegExp regex = new RegExp(r'^[1-9]\d*(\.\d+)?');
                        return !regex.hasMatch(val)
                            ? 'Enter a valid number'
                            : null;
                      },
                      initialValue:
                          expense == null ? '' : expense.amount.toString(),
                      onSaved: (val) => _amount = double.parse(val),
                    ),
                    TextFormField(
                      style: TextStyle(fontSize: 22),
                      decoration: InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          hintText: "Enter Date",
                          labelText: 'Date',
                          labelStyle: TextStyle(fontSize: 18)),
                      validator: (val) {
                        RegExp regex =
                            new RegExp(r'^((?:19|20)\d\d)-(0[1-9]|1[012])-(0[1-9]|[12][0-9]|3[01])$');
                        return !regex.hasMatch(val)
                            ? 'Enter a valid date'
                            : null;
                      },
                      initialValue:
                          expense == null ? '' : expense.formattedDate,
                      keyboardType: TextInputType.datetime,
                      onSaved: (val) => _date = DateTime.parse(val),
                    ),
                    TextFormField(
                      style: TextStyle(fontSize: 22),
                      decoration: InputDecoration(
                          icon: Icon(Icons.category),
                          labelText: 'Category',
                          labelStyle: TextStyle(fontSize: 18)),
                      initialValue: expense == null ? '' : expense.category,
                      onSaved: (val) => _category = val,
                    ),
                    RaisedButton(onPressed: _submit, child: new Text('Submit'))
                  ],
                ))));
  }
}
