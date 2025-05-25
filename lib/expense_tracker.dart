import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ExpensePieChartPage extends StatefulWidget {
  const ExpensePieChartPage({super.key});

  @override
  State<ExpensePieChartPage> createState() => _ExpensePieChartPageState();
}

class _ExpensePieChartPageState extends State<ExpensePieChartPage>
    with SingleTickerProviderStateMixin {
  final double expenses = 4500.0;
  final double savings = 5500.0;
  final String currency = 'INR';

  late AnimationController _animationController;
  late Animation<double> _chartScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _chartScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String formatCurrency(double amount) {
    final formatter = NumberFormat.simpleCurrency(name: currency);
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final total = expenses + savings;
    final expensePercentage = total > 0 ? (expenses / total) * 100 : 0;
    final savingsPercentage = total > 0 ? (savings / total) * 100 : 0;

    const borderColor = Color(0xFF003366);
    const backgroundColor = Color(0xFF74B9FF);
    final expenseShadowColor = const Color(0xFFF7C948).withOpacity(0.5);
    final savingsShadowColor = const Color(0xFF1B9CFC).withOpacity(0.5);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, // full height for full background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF74B9FF), Color(0xFF1B9CFC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _chartScaleAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 240,
                          width: 240,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              centerSpaceColor: backgroundColor,
                              sections: [
                                PieChartSectionData(
                                  color: expenseShadowColor,
                                  value: expenses,
                                  radius: 80,
                                  borderSide:
                                      BorderSide(color: borderColor, width: 4),
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: savingsShadowColor,
                                  value: savings,
                                  radius: 80,
                                  borderSide:
                                      BorderSide(color: borderColor, width: 4),
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 240,
                          width: 240,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              centerSpaceColor: backgroundColor,
                              sections: [
                                PieChartSectionData(
                                  color: const Color(0xFFF7C948),
                                  value: expenses,
                                  title:
                                      '${expensePercentage.toStringAsFixed(0)}%',
                                  radius: 75,
                                  borderSide:
                                      BorderSide(color: borderColor, width: 4),
                                  titleStyle: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFF1B9CFC),
                                  value: savings,
                                  title:
                                      '${savingsPercentage.toStringAsFixed(0)}%',
                                  radius: 75,
                                  borderSide:
                                      BorderSide(color: borderColor, width: 4),
                                  titleStyle: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: Image.asset(
                            "assets/images/doraemon.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      expenses > savings
                          ? "Try saving more, friend! 😟"
                          : "Great job saving! 🥳",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
