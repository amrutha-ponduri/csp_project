import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class YearlyChartPage extends StatelessWidget {
  YearlyChartPage({Key? key}) : super(key: key);

  List<String> getMonthsOfCurrentYear() {
    return List.generate(12, (index) {
      final date = DateTime(DateTime.now().year, index + 1, 1);
      return DateFormat('MMM').format(date);
    });
  }

  List<List<double>> generateDummyData() {
    return [
      [800, 400],
      [600, 500],
      [750, 300],
      [500, 700],
      [1000, 100],
      [450, 600],
      [700, 400],
      [850, 350],
      [300, 800],
      [950, 200],
      [400, 600],
      [650, 500],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final months = getMonthsOfCurrentYear();
    final monthlyData = generateDummyData();

    return Scaffold(
      appBar: AppBar(title: const Text("Yearly Expense Chart")),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 800,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                maxY: monthlyData
                        .map((e) => e[0] + e[1])
                        .reduce((a, b) => a > b ? a : b) +
                    200,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final saved = monthlyData[group.x.toInt()][0];
                      final spent = monthlyData[group.x.toInt()][1];
                      return BarTooltipItem(
                        '${months[group.x.toInt()]}\n'
                        'Saved: ₹${saved.toInt()}\n'
                        'Spent: ₹${spent.toInt()}',
                        const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt();
                        if (index < 0 || index >= months.length)
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(months[index],
                              style: const TextStyle(fontSize: 12)),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 200,
                      getTitlesWidget: (value, meta) {
                        return Text(value.toInt().toString());
                      },
                      reservedSize: 36,
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true),
                barGroups: List.generate(monthlyData.length, (index) {
                  final saved = monthlyData[index][0];
                  final spent = monthlyData[index][1];
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: saved + spent,
                        width: 20,
                        rodStackItems: [
                          BarChartRodStackItem(0, spent, Colors.red),
                          BarChartRodStackItem(
                              spent, saved + spent, Colors.green),
                        ],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
