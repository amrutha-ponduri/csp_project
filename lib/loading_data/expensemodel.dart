import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
class Expense {
  final String title;
  final double amount;
  final DateTime date;
  final DocumentReference docReference;
  Expense({required this.title, required this.amount, required this.date,required this.docReference});
}
abstract class ExpenseItem {}

class ExpenseHeader implements ExpenseItem {
  final String label;
  ExpenseHeader(this.label);
}

class ExpenseEntry implements ExpenseItem {
  final Expense expense;
  ExpenseEntry(this.expense);
}
List<ExpenseItem> buildGroupedExpenseList(List<Expense> expenses) {
  final Map<String, List<Expense>> grouped = {};

  for (var e in expenses) {
    final label = getDateLabel(e.date);
    grouped.putIfAbsent(label, () => []).add(e);
  }

  List<ExpenseItem> finalList = [];

  grouped.forEach((label, items) {
    finalList.add(ExpenseHeader(label));
    finalList.addAll(items.map((e) => ExpenseEntry(e)));
  });

  return finalList;
}

String getDateLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final d = DateTime(date.year, date.month, date.day);

  if (d == today) return 'Today';
  if (d == yesterday) return 'Yesterday';
  return DateFormat('dd MMM yyyy').format(date);
}
