import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class YearlyChartPage extends StatefulWidget {
  @override
  _YearlyChartPageState createState() => _YearlyChartPageState();
}

class _YearlyChartPageState extends State<YearlyChartPage> {
  List<double> savedAmounts = List.filled(12, 0);
  List<double> spentAmounts = List.filled(12, 0);
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFirebaseData();
  }

  Future<void> fetchFirebaseData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final doc = await FirebaseFirestore.instance
          .collection('yearly_data')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data != null &&
          data.containsKey('saved') &&
          data.containsKey('spent')) {
        setState(() {
          savedAmounts =
              List<double>.from(data['saved'].map((e) => e.toDouble()));
          spentAmounts =
              List<double>.from(data['spent'].map((e) => e.toDouble()));
          isLoading = false;
        });
      } else {
        throw Exception("Missing fields in Firestore");
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Show default data or error state
      setState(() {
        savedAmounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        spentAmounts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yearly Saved & Spent'),
        centerTitle: true,
        backgroundColor: Color(0xFF0099FF),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: 1000,
                  child: BarChart(
                    BarChartData(
                      maxY: 2000,
                      barGroups: List.generate(12, (i) {
                        return BarChartGroupData(
                          x: i,
                          barsSpace: 8,
                          barRods: [
                            BarChartRodData(
                              toY: savedAmounts[i],
                              color: Color(0xFF0099FF),
                              width: 12,
                              borderRadius: BorderRadius.circular(4),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 2000,
                                color: Color(0xFFE0F2FF),
                              ),
                            ),
                            BarChartRodData(
                              toY: spentAmounts[i],
                              color: Color(0xFFFF4444),
                              width: 12,
                              borderRadius: BorderRadius.circular(4),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 2000,
                                color: Color(0xFFFFE0E0),
                              ),
                            ),
                          ],
                        );
                      }),
                      groupsSpace: 24,
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              const months = [
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
                              if (value.toInt() >= months.length)
                                return Container();
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
                              if (value % 200 != 0 && value != 0)
                                return Container();
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
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
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
