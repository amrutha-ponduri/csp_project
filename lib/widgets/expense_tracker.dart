import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class DoraemonSummaryChart extends StatefulWidget {
  const DoraemonSummaryChart({
    super.key,
  });

  @override
  State<DoraemonSummaryChart> createState() => _DoraemonSummaryChartState();
}

class _DoraemonSummaryChartState extends State<DoraemonSummaryChart> with SingleTickerProviderStateMixin{
  late AnimationController _animationController;
  late Animation<double> _chartScaleAnimation;
  double? expenses;
  double?  pocketMoney;
  @override
  void initState() {
    loadData();
     _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _chartScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    super.initState();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String fullMonthName = DateFormat.MMMM().format(now);
    if (pocketMoney == null) {
      return Center(
        child : Text('Enter pocket money details'),
      );
    }
    expenses = expenses??0;
    final double savings = pocketMoney! - expenses!;
    final double expensePercentage =
        (pocketMoney! > 0) ? (expenses! / pocketMoney!) * 100 : 0;
    final double savingsPercentage =
        (pocketMoney! > 0) ? (savings / pocketMoney!) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 234, 239, 244), Color.fromARGB(255, 108, 157, 244)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ]),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Doraemon Face
            SizedBox(
              height: 100,
              child: Image.asset("assets/images/doraemon.png"),
            ),
      
            const SizedBox(height: 16),
      
            // Title
            Text(
              "$fullMonthName Summary",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.amber,
                shadows: [
                  Shadow(
                      color: Colors.black45, offset: Offset(1, 1), blurRadius: 3)
                ],
              ),
            ),
      
            const SizedBox(height: 32),
      
            // Pie Chart
            ScaleTransition(
              scale: _chartScaleAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 220,
                    width: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 70,
                        sections: [
                          PieChartSectionData(
                            value: expenses,
                            color: const Color(0xFFF7C948),
                            radius: 70,
                            title: '${expensePercentage.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          PieChartSectionData(
                            value: savings,
                            color: const Color(0xFF1B9CFC),
                            radius: 70,
                            title: '${savingsPercentage.toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                    
                  // Center Pancake icon
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: Image.asset("assets/images/doracake.png"),
                  ),
                ],
              ),
            ),
      
            const SizedBox(height: 40),
      
            // Expenses Text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Text(
                  "Expenses: ₹${expenses!.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Future<void> loadData() async{
    await fetchExpenses();
    await fetchPocketMoney();
    setState(() {
      // trigger rebuild after data is fetched
      _animationController.forward();
    });
  }
  Future<void> fetchExpenses() async {
    final db = FirebaseFirestore.instance;
    final year = DateTime.now().year;
    final month = DateTime.now().month;
    final docPath = '$year-${month}details';
    final String? email = FirebaseAuth.instance.currentUser!.email;
    final DocumentReference documentReference = db
        .collection('users')
        .doc(email)
        .collection('monthlyExpenses')
        .doc(docPath);
    final snapshot = await documentReference.get();
    final data = snapshot.data() as Map<String, dynamic>;
    expenses = await (data['expenseValue'] as num).toDouble();
  }

  Future<void> fetchPocketMoney() async {
    final db = FirebaseFirestore.instance;
    final int year = DateTime.now().year;
    final int month = DateTime.now().month;
    final docPath = '$year-${month}details';
    print(docPath);
    final String? email = FirebaseAuth.instance.currentUser!.email;
    final DocumentReference documentReference = db
        .collection('users')
        .doc(email)
        .collection('pocketMoney')
        .doc(docPath);
    final snapshot = await documentReference.get();
    final data = snapshot.data() as Map<String, dynamic>;
    pocketMoney = await (data['pocketMoney'] as num).toDouble();
  }
}
