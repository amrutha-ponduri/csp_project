import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(StreakPageApp());

class StreakPageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreakPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StreakPage extends StatefulWidget {
  @override
  _StreakPageState createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late int daysInMonth;
  late List<int> achievedDays;

  @override
  void initState() {
    super.initState();
    _generateMonthData();
  }

  void _generateMonthData() {
    daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    achievedDays = List.generate(
      (selectedMonth.month + 5) % daysInMonth,
      (index) => index + 1,
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      selectedMonth =
          DateTime(selectedMonth.year, selectedMonth.month + offset);
      _generateMonthData();
    });
  }

  @override
  Widget build(BuildContext context) {
    int currentStreak = 5;
    int consistencyScore = 82; // Show as raw score

    return Scaffold(
      appBar: AppBar(
        title: Text('Streak Tracker'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hello Welcome Icon
            Row(
              children: [
                Icon(Icons.tag_faces, color: Colors.orange, size: 28),
                SizedBox(width: 10),
                Text(
                  'Hello, Welcome Back!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Streaks Title
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.red),
                SizedBox(width: 6),
                Text(
                  'Your Streaks',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),

            // Streak Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                streakCard(
                  title: "Current Streak",
                  value: "$currentStreak days",
                  color: Colors.orange,
                  icon: Icons.local_fire_department,
                ),
                streakCard(
                  title: "Consistency Score",
                  value: "$consistencyScore / 100",
                  color: Colors.blue,
                  icon: Icons.insights,
                ),
              ],
            ),

            SizedBox(height: 24),

            // Month & Tracker Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 20, color: Colors.blueGrey),
                    SizedBox(width: 6),
                    Text(
                      'Monthly Tracker',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _changeMonth(-1),
                      icon: Icon(Icons.chevron_left),
                    ),
                    Text(
                      DateFormat.yMMMM().format(selectedMonth),
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    IconButton(
                      onPressed: () => _changeMonth(1),
                      icon: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),

            // Calendar Grid
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(daysInMonth, (index) {
                int day = index + 1;
                bool achieved = achievedDays.contains(day);
                return Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: achieved ? Colors.green : Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$day',
                    style: TextStyle(
                      fontSize: 12,
                      color: achieved ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 16),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                legendItem(Colors.green, "Achieved"),
                legendItem(Colors.white, "Missed"),
                legendItem(Colors.blue, "Streak Freeze",
                    isIcon: Icons.whatshot),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget streakCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        width: 140,
        height: 80,
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget legendItem(Color color, String label, {IconData? isIcon}) {
    return Row(
      children: [
        isIcon != null
            ? Icon(isIcon, size: 16, color: color)
            : Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(color: Colors.grey),
                ),
              ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
