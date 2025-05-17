import 'package:flutter/material.dart';

class MonthEndPage extends StatefulWidget {
  final double savedAmount;
  final double goalAmount;
  final double monthlySavedAmount; // 👈 New field added

  const MonthEndPage({
    super.key,
    required this.savedAmount,
    required this.goalAmount,
    required this.monthlySavedAmount,
  });

  @override
  State<MonthEndPage> createState() => _MonthEndPageState();
}

class _MonthEndPageState extends State<MonthEndPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = widget.savedAmount / widget.goalAmount;
    final int monthsTaken =
        (widget.savedAmount / widget.monthlySavedAmount).ceil();

    final String resultMessage = widget.savedAmount >= widget.goalAmount
        ? "You can buy your desired product 🎉"
        : "You need more money to buy your desired product 💰";

    final DateTime now = DateTime.now();
    final String monthName = _getMonthName(now.month);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Month End Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                color: Colors.white.withOpacity(0.9),
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$monthName ${now.year}",
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "You saved ₹${widget.savedAmount.toStringAsFixed(2)} this month!",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Saved: ₹${widget.savedAmount.toStringAsFixed(2)} / ₹${widget.goalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: progress > 1 ? 1.0 : progress,
                        backgroundColor: Colors.grey.shade300,
                        color: progress >= 1 ? Colors.green : Colors.blue,
                        minHeight: 12,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        resultMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "It took you $monthsTaken month(s) to save this amount.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  String _getMonthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }
>>>>>>> origin/monthpage
}
