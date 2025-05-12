import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'pages/monthendpage.dart';
// import your data module

class ExpensePieChartPage extends StatefulWidget {
  const ExpensePieChartPage({super.key});

  @override
  State<ExpensePieChartPage> createState() => _ExpensePieChartPageState();
}

class _ExpensePieChartPageState extends State<ExpensePieChartPage> {
  final TextEditingController _expensesController = TextEditingController();
  final TextEditingController _savingsController = TextEditingController();
  String _selectedCurrency = MonthEndData.currency;

  final List<String> _currencyOptions = ['USD', 'EUR', 'INR', 'GBP', 'JPY'];

  @override
  void initState() {
    super.initState();
    _expensesController.text = MonthEndData.expenses.toString();
    _savingsController.text = MonthEndData.savings.toString();
  }

  void _updateData() {
    setState(() {
      MonthEndData.updateData(
        newExpenses: double.tryParse(_expensesController.text) ?? 0.0,
        newSavings: double.tryParse(_savingsController.text) ?? 0.0,
      );
      MonthEndData.updateCurrency(_selectedCurrency);
    });
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.simpleCurrency(name: MonthEndData.currency);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final expenses = MonthEndData.expenses;
    final savings = MonthEndData.savings;
    final total = expenses + savings;

    final expensePercentage = total > 0 ? (expenses / total) * 100 : 0;
    final savingsPercentage = total > 0 ? (savings / total) * 100 : 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Summary")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Inputs Section
            TextField(
              controller: _expensesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Expenses'),
              onChanged: (_) => _updateData(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _savingsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Savings'),
              onChanged: (_) => _updateData(),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              items: _currencyOptions.map((currency) {
                return DropdownMenuItem(value: currency, child: Text(currency));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                  _updateData();
                });
              },
              decoration: const InputDecoration(labelText: 'Currency'),
            ),
            const SizedBox(height: 30),

            // Pie Chart Section
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 5,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.pink.shade200,
                      value: expenses,
                      title: '${expensePercentage.toStringAsFixed(1)}%',
                      radius: 80,
                      titleStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      color: Colors.green.shade200,
                      value: savings,
                      title: '${savingsPercentage.toStringAsFixed(1)}%',
                      radius: 80,
                      titleStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Indicator(
                    color: Colors.pink.shade200,
                    text: "Expenses: ${formatCurrency(expenses)}"),
                const SizedBox(width: 20),
                Indicator(
                    color: Colors.green.shade200,
                    text: "Savings: ${formatCurrency(savings)}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;

  const Indicator({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
