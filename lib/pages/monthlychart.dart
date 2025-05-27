import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class YearlyChartPage extends StatefulWidget {
  const YearlyChartPage({super.key});

  @override
  State<YearlyChartPage> createState() => _YearlyChartPageState();
}

class _YearlyChartPageState extends State<YearlyChartPage> {
  final List<String> months = [
    'Jan-${DateTime.now().year}',
    'Feb-${DateTime.now().year}',
    'Mar-${DateTime.now().year}',
    'Apr-${DateTime.now().year}',
    'May-${DateTime.now().year}',
    'Jun-${DateTime.now().year}',
    'Jul-${DateTime.now().year}',
    'Aug-${DateTime.now().year}',
    'Sep-${DateTime.now().year}',
    'Oct-${DateTime.now().year}',
    'Nov-${DateTime.now().year}',
    'Dec-${DateTime.now().year}'
  ];

  Map<String, double> pocketMap = {};
  Map<String, double> spentMap = {};

  List<double> spentAmounts = List.filled(12, 0);
  List<double> pocketMoney = List.filled(12, 0);
  List<double> savedAmounts = List.filled(12, 0);

  bool isLoading = true; // to show loading until data is fetched

  @override
  void initState() {
    super.initState();
    loadChartData();
  }

  Future<void> loadChartData() async {
    setState(() {
      isLoading = true;
    });

    await getSpentAmounts();
    await getPocketMoney();

    // Build spentAmounts and pocketMoney lists in order of months
    spentAmounts = List.generate(12, (index) {
      return spentMap[months[index]] ?? 0;
    });

    pocketMoney = List.generate(12, (index) {
      return pocketMap[months[index]] ?? 0;
    });

    // Calculate savedAmounts
    savedAmounts = List.generate(12, (index) {
      return pocketMoney[index] - spentAmounts[index];
    });

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Yearly Saved & Spent'),
          centerTitle: true,
          backgroundColor: Color(0xFF0099FF),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yearly Saved & Spent'),
        centerTitle: true,
        backgroundColor: const Color(0xFF0099FF),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1000,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: BarChart(
                  BarChartData(
                    maxY: getMaxY(),
                    barGroups: List.generate(months.length, (i) {
                      // Safety: clamp saved and spent to >= 0 for chart
                      final double saved = savedAmounts.length > i
                          ? savedAmounts[i].clamp(0, double.infinity)
                          : 0;
                      final double spent = spentAmounts.length > i
                          ? spentAmounts[i].clamp(0, double.infinity)
                          : 0;

                      return BarChartGroupData(
                        x: i,
                        barsSpace: 8,
                        barRods: [
                          BarChartRodData(
                            toY: saved,
                            color: const Color(0xFF0099FF),
                            width: 12,
                            borderRadius: BorderRadius.circular(4),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: getMaxY(),
                              color: const Color(0xFFE0F2FF),
                            ),
                          ),
                          BarChartRodData(
                            toY: spent,
                            color: const Color(0xFFFF4444),
                            width: 12,
                            borderRadius: BorderRadius.circular(4),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: getMaxY(),
                              color: const Color(0xFFFFE0E0),
                            ),
                          ),
                        ],
                      );
                    }),
                    groupsSpace: 24,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= months.length){
                              return Container();
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                months[value.toInt()],
                                style: const TextStyle(
                                  color: Color(0xFF0099FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          reservedSize: 20,
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 200,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.black87,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String label = rodIndex == 0 ? "Saved" : "Spent";
                          return BarTooltipItem(
                            '$label\n${rod.toY.toInt()}',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getPocketMoney() async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) return;

    final db = FirebaseFirestore.instance;
    final collectionRef =
        db.collection('users').doc(userEmail).collection('pocketMoney');

    pocketMap.clear();

    final snapshot = await collectionRef.get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final month = data['month']; // e.g. "Jan-2025"
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
    final collectionRef =
        db.collection('users').doc(userEmail).collection('monthlyExpenses');

    spentMap.clear();

    final snapshot = await collectionRef.get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final month = data['month']; // e.g. "Jan-2025"
      final value = data['expenseValue'];

      if (month != null && value is num) {
        spentMap[month] = value.toDouble();
      }
    }
  }

  double getMaxY() {
    final maxDataValue = [
      ...spentAmounts,
      ...pocketMoney,
      ...savedAmounts,
    ].fold<double>(0, (prev, curr) => curr > prev ? curr : prev);

    return maxDataValue;
  }
}
