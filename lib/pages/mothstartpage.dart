import 'package:flutter/material.dart';

class MonthStartPage extends StatefulWidget {
  const MonthStartPage({super.key});

  @override
  State<MonthStartPage> createState() => _MonthStartPageState();
}

class _MonthStartPageState extends State<MonthStartPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController pocketMoneyController = TextEditingController();
  final TextEditingController targetSavingsController = TextEditingController();

  @override
  void dispose() {
    pocketMoneyController.dispose();
    targetSavingsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final pocketMoney = double.parse(pocketMoneyController.text);
      final targetSavings = double.parse(targetSavingsController.text);

      // You can do something with the values here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Pocket Money: ₹$pocketMoney | Target Savings: ₹$targetSavings')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Month Start Page"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0BBE4), Color(0xFF957DAD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: Colors.deepPurple.shade900,
                ),
              ),
              const SizedBox(height: 20),
              // Pocket money field with neutral color and rounded corners
              TextFormField(
                controller: pocketMoneyController,
                decoration: InputDecoration(
                  labelText: "Pocket Money (₹)",
                  filled: true,
                  fillColor: Colors.white, // Neutral background for input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pocket money';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Target savings field with neutral color and rounded corners
              TextFormField(
                controller: targetSavingsController,
                decoration: InputDecoration(
                  labelText: "Target Savings (₹)",
                  filled: true,
                  fillColor: Colors.white, // Neutral background for input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter target savings';
                  }
                  final target = double.tryParse(value);
                  final pocket = double.tryParse(pocketMoneyController.text);
                  if (target == null || target < 0) {
                    return 'Enter a valid number';
                  }
                  if (pocket != null && target > pocket) {
                    return 'Target savings cannot exceed pocket money';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              // Submit button
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                  ),
                  child: const Text("Let's save money"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
