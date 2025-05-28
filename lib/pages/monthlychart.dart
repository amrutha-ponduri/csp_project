import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class YearlyChartPage extends StatefulWidget {
  const YearlyChartPage({super.key});

  @override
  State<YearlyChartPage> createState() => _YearlyChartPageState();
}

class _YearlyChartPageState extends State<YearlyChartPage> {
  final List<String> months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  Map<String, double> pocketMap = {};
  Map<String, double> spentMap = {};

  List<_ChartData> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadChartData();
  }

  Future<void> loadChartData() async {
    setState(() => isLoading = true);
    await getSpentAmounts();
    await getPocketMoney();

    chartData.clear();
    for (int i = 0; i < months.length; i++) {
      String key = '${months[i]}-${DateTime.now().year}';
      double spent = spentMap[key] ?? 0;
      double pocket = pocketMap[key] ?? 0;
      double saved = pocket - spent;

      chartData.add(_ChartData(
        months[i],
        saved.clamp(0, double.infinity),
        spent.clamp(0, double.infinity),
      ));
    }

    setState(() => isLoading = false);
  }

  Future<void> getPocketMoney() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) return;

    final db = FirebaseFirestore.instance;
    final collectionRef = db.collection('users').doc(userEmail).collection('pocketMoney');
    pocketMap.clear();

    final snapshot = await collectionRef.get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final month = data['month'];
      final amount = data['pocketMoney'];
      if (month != null && amount is num) {
        pocketMap[month] = amount.toDouble();
      }
    }
  }

  Future<void> getSpentAmounts() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) return;

    final db = FirebaseFirestore.instance;
    final collectionRef = db.collection('users').doc(userEmail).collection('monthlyExpenses');
    spentMap.clear();

    final snapshot = await collectionRef.get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final month = data['month'];
      final value = data['expenseValue'];
      if (month != null && value is num) {
        spentMap[month] = value.toDouble();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F4FF), // Light Doraemon blue background
      appBar: AppBar(
        title: const Text(
          'Doraemon’s Yearly Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'ComicSans',
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF0099FF), // Doraemon blue
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0099FF)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 5,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SfCartesianChart(
                    title: ChartTitle(
                      text: '💰 POCKET SAVINGS V/S 🍜 SPENT',
                      textStyle: const TextStyle(
                        color: Color.fromARGB(255, 1, 19, 110),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        fontFamily: 'ComicSans',
                      ),
                    ),
                    primaryXAxis: CategoryAxis(
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ComicSans',
                      ),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: '₹ Amount',
                        textStyle: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'ComicSans',
                        ),
                      ),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ComicSans',
                      ),
                    ),
                    legend: const Legend(
                      isVisible: true,
                      textStyle: TextStyle(fontFamily: 'ComicSans'),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    isTransposed: true,
                    series: <CartesianSeries<dynamic, dynamic>>[
                      BarSeries<_ChartData, String>(
                        name: 'Saved 💙',
                        dataSource: chartData,
                        xValueMapper: (_ChartData data, _) => data.month,
                        yValueMapper: (_ChartData data, _) => data.saved,
                        color: const Color(0xFF0099FF),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        width: 0.5,
                        spacing: 0.0,
                      ),
                      BarSeries<_ChartData, String>(
                        name: 'Spent 🔴',
                        dataSource: chartData,
                        xValueMapper: (_ChartData data, _) => data.month,
                        yValueMapper: (_ChartData data, _) => data.spent,
                        color: const Color(0xFFFF4444),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        width: 0.5,
                        spacing: 0.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _ChartData {
  final String month;
  final double saved;
  final double spent;

  _ChartData(this.month, this.saved, this.spent);
}
