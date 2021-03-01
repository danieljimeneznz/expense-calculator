import 'package:intl/intl.dart';

class Expense {
  final int id;
  final double amount;
  final DateTime date;
  final String category;

  String get formattedDate {
    DateFormat formatter = new DateFormat('yyyy-MM-dd');
    return formatter.format(this.date);
  }

  static final columns = ['id', 'amount', 'date', 'category'];

  Expense(this.id, this.amount, this.date, this.category);

  factory Expense.fromMap(Map<String, dynamic> data) {
    return Expense(
      data['id'],
      data['amount'],
      DateTime.parse(data['date']),
      data['category']
    );
  }

  Map<String, dynamic> toMap() => {
    "id": this.id,
    "amount": this.amount,
    "date": this.date.toString(),
    "category": this.category
  };
}