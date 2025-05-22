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
      selectedDate = DateTime(selectedDate.year, selectedDate.month + offset);
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
          color = Colors.blue;
          break;
        case 'neutral':
          icon = Icons.sentiment_neutral;
          color = Colors.blue;
          break;
        default:
          icon = Icons.sentiment_dissatisfied;
          color = Colors.blue;
      }
      return Icon(icon, color: color, size: 32);
    }).toList();
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
                  _infoBox("EXPENSES", "5 days", Icons.local_fire_department),
                  _infoBox("Score", "82/100", Icons.check_circle_outline),
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
              // Year at the bottom has been removed
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoBox(String title, String value, IconData icon) {
    return Container(
      width: 140,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade400, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orange, size: 32),
          SizedBox(height: 5),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
