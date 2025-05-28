import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StreaksPage extends StatefulWidget {
  const StreaksPage({super.key});

  @override
  State<StreaksPage> createState() => _StreaksPageState();
}

class _StreaksPageState extends State<StreaksPage> {
  DateTime selectedMonth = DateTime.now();

  final Map<int, bool> streakData = {
    for (int i = 1; i <= 31; i++) i: i % 7 != 0
  };

  int get continuousStreakCount {
    int count = 0;
    for (int day = 1; day <= daysInMonth; day++) {
      if (streakData[day] == true) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  int get totalStreakDays =>
      streakData.entries.where((e) => e.key <= daysInMonth && e.value).length;

  void _changeMonth(int offset) {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + offset,
      );
    });
  }

  final Color doraemonBlue = const Color(0xFF2196F3);
  final Color doraemonRed = const Color(0xFFD32F2F);

  int get daysInMonth {
    final nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    return nextMonth.day;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double spacing = 8;
    const double cellSize = 40;

    int rowCount = (daysInMonth / 7).ceil();
    double gridHeight = rowCount * (cellSize + spacing) - spacing;

    return Scaffold(
      backgroundColor: const Color(0xFFD5EDF4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'HELLO,\nWELCOME BACK!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      'assets/images/doraemon_wallet.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    Image.asset(
                      'assets/images/nobita_money.png',
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoCard(
                      title: "EXPENSES",
                      subtitle:
                          "🔥 $continuousStreakCount days continuous streak",
                      background: const Color(0xFFFFE6B3),
                      width: screenWidth * 0.42,
                    ),
                    _buildInfoCard(
                      title: "STREAKS",
                      subtitle: "✅ $totalStreakDays / $daysInMonth days",
                      background: const Color(0xFFCCE5FF),
                      width: screenWidth * 0.42,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left, size: 32),
                      onPressed: () => _changeMonth(-1),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        DateFormat.yMMMM().format(selectedMonth),
                        key: ValueKey(selectedMonth),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right, size: 32),
                      onPressed: () => _changeMonth(1),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: gridHeight,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: daysInMonth,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final day = index + 1;
                            final completed = streakData[day] ?? false;
                            final isToday = DateTime.now().year ==
                                    selectedMonth.year &&
                                DateTime.now().month == selectedMonth.month &&
                                DateTime.now().day == day;

                            return DayStreakBadge(
                              day: day,
                              completed: completed,
                              doraemonBlue: doraemonBlue,
                              doraemonRed: doraemonRed,
                              isToday: isToday,
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Image.asset(
                            'assets/images/shizuka.png',
                            height: gridHeight - 10,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required Color background,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class DayStreakBadge extends StatelessWidget {
  final int day;
  final bool completed;
  final bool isToday;
  final Color doraemonBlue;
  final Color doraemonRed;

  const DayStreakBadge({
    Key? key,
    required this.day,
    required this.completed,
    required this.doraemonBlue,
    required this.doraemonRed,
    this.isToday = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageAsset = completed
        ? 'assets/images/doraemon_happy.png'
        : 'assets/images/doraemon_sad.png';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isToday ? Colors.green : Colors.transparent,
              width: 2,
            ),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Image.asset(
            imageAsset,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          top: -10, // pushed further out
          right: -10, // pushed further out
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                )
              ],
            ),
            child: Text(
              '$day',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
