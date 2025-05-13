import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

class DailyExpenseChart extends StatefulWidget {
  const DailyExpenseChart({Key? key}) : super(key: key);

  @override
  State<DailyExpenseChart> createState() => _DailyExpenseChartState();
}

class _DailyExpenseChartState extends State<DailyExpenseChart> {
  final List<Map<String, dynamic>> dailyExpenses = List.generate(
    31,
    (index) => {
      'day': (index + 1).toString(),
      'amount': [200, 400, 600, 800, 1000][index % 5],
    },
  );

  final String currentMonthName = DateFormat('MMMM').format(DateTime.now());

  GlobalKey chartKey = GlobalKey();

  Future<void> _exportChartAsImage() async {
    RenderRepaintBoundary boundary =
        chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    if (await Permission.storage.request().isGranted) {
      final directory = await getExternalStorageDirectory();
      final path =
          '${directory!.path}/chart_${DateTime.now().millisecondsSinceEpoch}.png';
      File(path).writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chart saved at $path')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission not granted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color primaryColor = isDark ? Colors.tealAccent : Colors.blueAccent;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Daily Expense Chart",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.grey.withOpacity(0.5),
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _exportChartAsImage,
            tooltip: 'Export Chart',
          ),
        ],
      ),
      body: Center(
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
            child: _buildLineChart(primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(Color color) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 30,
        minY: 0,
        maxY: 1000,
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          getTouchedSpotIndicator:
              (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(color: Colors.transparent), // Hides the line
                FlDotData(show: true), // Still show the dot
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                String day = dailyExpenses[spot.x.toInt()]['day'];
                return LineTooltipItem(
                  "$currentMonthName $day\n₹${spot.y.toInt()}",
                  const TextStyle(color: Colors.white),
                );
              }).toList();
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
            spots: List.generate(
              dailyExpenses.length,
              (index) => FlSpot(
                index.toDouble(),
                dailyExpenses[index]['amount'].toDouble(),
              ),
            ),
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
            int day = value.toInt() + 1;
            if (day % 5 == 1 || day == 31) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Day $day',
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
