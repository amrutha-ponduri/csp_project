import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      home: TrackerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TrackerPage extends StatefulWidget {
  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  DateTime selectedDate = DateTime.now();

  void _changeMonth(int offset) {
    setState(() {
      int newYear = selectedDate.year;
      int newMonth = selectedDate.month + offset;

      while (newMonth > 12) {
        newMonth -= 12;
        newYear += 1;
      }
      while (newMonth < 1) {
        newMonth += 12;
        newYear -= 1;
      }

      selectedDate = DateTime(newYear, newMonth);
    });
  }

  List<Widget> _buildMonthlyTracker() {
    List<String> moods = List.generate(15, (_) => 'happy') +
        List.generate(8, (_) => 'neutral') +
        List.generate(8, (_) => 'sad');

    return moods.map((mood) {
      IconData icon;
      Color color;
      switch (mood) {
        case 'happy':
          icon = Icons.sentiment_very_satisfied;
          color = Colors.green;
          break;
        case 'neutral':
          icon = Icons.sentiment_neutral;
          color = Colors.amber;
          break;
        default:
          icon = Icons.sentiment_dissatisfied;
          color = Colors.red;
      }
      return Icon(icon, color: color, size: 32);
    }).toList();
  }

  Widget imageCardWithStreak(
      {required String label, required String imagePath}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.local_fire_department, color: Colors.red, size: 24),
          ],
        ),
        SizedBox(height: 8),
        Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget imageCardScore({required String label, required String imagePath}) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
            ),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blueAccent, width: 2),
          ),
        ),
        SizedBox(height: 8),
        Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text("82/100", style: TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String monthYear = DateFormat.yMMMM().format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("HELLO, WELCOME BACK!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  imageCardWithStreak(
                    label: "EXPENSES",
                    imagePath: 'lib/assets/images/doremon.png',
                  ),
                  imageCardScore(
                    label: "SCORE",
                    imagePath: 'lib/assets/images/nobita.png',
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, size: 30),
                    onPressed: () => _changeMonth(-1),
                  ),
                  Text(
                    monthYear,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, size: 30),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _buildMonthlyTracker(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
