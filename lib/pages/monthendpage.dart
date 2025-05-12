// monthendpage.dart
class MonthEndData {
  static double expenses = 0.0;
  static double savings = 0.0;
  static String currency = 'USD'; // Default currency code

  static void updateData(
      {required double newExpenses, required double newSavings}) {
    expenses = newExpenses;
    savings = newSavings;
  }

  static void updateCurrency(String newCurrency) {
    currency = newCurrency;
  }
}
