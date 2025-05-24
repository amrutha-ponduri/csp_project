import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class YearlyChartPage extends StatelessWidget {
  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  final List<double> savedAmounts = [
    500,
    700,
    800,
    600,
    750,
    900,
    850,
    700,
    650,
    800,
    900,
    1000,
  ];

  final List<double> spentAmounts = [
    400,
    550,
    600,
    700,
    650,
    700,
    750,
    650,
    600,
    700,
    800,
    850,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yearly Saved & Spent'),
        centerTitle: true,
        backgroundColor: Color(0xFF0099FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: 1000,
            child: BarChart(
              BarChartData(
                maxY: 1450,
                barGroups: List.generate(months.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barsSpace: 8,
                    barRods: [
                      BarChartRodData(
                        toY: savedAmounts[i],
                        color: Color(0xFF0099FF),
                        width: 12, // ✅ Restored original width
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 1400,
                          color: Color(0xFFE0F2FF),
                        ),
                      ),
                      BarChartRodData(
                        toY: spentAmounts[i],
                        color: Color(0xFFFF4444),
                        width: 12, // ✅ Restored original width
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 1400,
                          color: Color(0xFFFFE0E0),
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
                        if (value.toInt() >= months.length) return Container();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            months[value.toInt()],
                            style: TextStyle(
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
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 200,
                      getTitlesWidget: (value, meta) {
                        if (value % 200 != 0 && value != 0) return Container();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
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
                        TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
