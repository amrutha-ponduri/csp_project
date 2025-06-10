import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyExpenseChart extends StatefulWidget {
  const DailyExpenseChart({super.key});

  @override
  State<DailyExpenseChart> createState() => _DailyExpenseChartState();
}

class _DailyExpenseChartState extends State<DailyExpenseChart> {
  GlobalKey chartKey = GlobalKey();

  String currentMonthName = DateFormat('MMMM').format(DateTime.now());

  Stream<List<Map<String, dynamic>>> getDailyExpensesStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('dailyExpenses')
        .snapshots()
        .map((snapshot) {
      Map<String, double> dailyTotals = {};

      for (var doc in snapshot.docs) {
        if (!doc.data().containsKey('timeStamp') ||
            !doc.data().containsKey('expenseValue')) {
          continue;
        }

        // Convert Firestore Timestamp to DateTime
        DateTime fullDate = (doc['timeStamp'] as Timestamp).toDate();

        // Reduce to only date (strip time)
        String dateKey =
            "${fullDate.year}-${fullDate.month.toString().padLeft(2, '0')}-${fullDate.day.toString().padLeft(2, '0')}";

        double amount = (doc['expenseValue'] as num).toDouble();
        dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + amount;
      }

      // Convert to list of maps
      List<Map<String, dynamic>> result = dailyTotals.entries.map((entry) {
        DateTime date = DateTime.parse(entry.key);
        return {
          'day': date.day,
          'amount': entry.value,
        };
      }).toList();

      result.sort((a, b) => a['day'].compareTo(b['day']));
      return result;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark ? Colors.tealAccent : Colors.blueAccent;

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getDailyExpensesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No expense data found.'));
        }

        final data = snapshot.data!;
        return Center(
          child: RepaintBoundary(
            key: chartKey,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: SizedBox(
                height: 300, // You can adjust the height as needed
                child: _buildLineChart(primaryColor, data),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLineChart(Color color, List<Map<String, dynamic>> data) {
    return LineChart(
      LineChartData(
        minX: 1,
        maxX: 31,
        minY: 0,
        maxY: 1000,
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItems: (touchedSpots) {
              // Create map from day to data entry
              final dayToData = {for (var d in data) d['day']: d};

              return touchedSpots
                  .map((spot) {
                    int day = spot.x.toInt();
                    final matchedData = dayToData[day];
                    if (matchedData == null) {
                      return null;
                    }
                    return LineTooltipItem(
                      "$currentMonthName $day\n₹${matchedData['amount'].toInt()}",
                      const TextStyle(color: Colors.white),
                    );
                  })
                  .whereType<LineTooltipItem>()
                  .toList();
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade300, strokeWidth: 1),
          getDrawingVerticalLine: (value) =>
              FlLine(color: Colors.grey.shade300, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        titlesData: _buildTitles(),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: color,
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
            spots: data.map((item) {
              double day =
                  item['day'].toDouble(); // ✅ Use actual day of the month
              return FlSpot(day, item['amount'].toDouble());
            }).toList(),
          ),
        ],
      ),
    );
  }

  FlTitlesData _buildTitles() {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 5,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            int day = value.toInt();
            if (day != 30 && day % 5 == 0 || day == 1 || day == 31) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${DateFormat('MMM').format(DateTime.now())} $day',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 200,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              '₹${value.toInt()}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ),
      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
}
