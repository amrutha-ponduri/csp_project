import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_expend/widgets/info_card_widget.dart';
import 'package:smart_expend/widgets/streak_badge_widget.dart';

class StreaksPage extends StatefulWidget {
  const StreaksPage({super.key});

  @override
  State<StreaksPage> createState() => _StreaksPageState();
}

class _StreaksPageState extends State<StreaksPage> {
  DateTime selectedMonth = DateTime.now();
  DateTime? signUpDate;
  // Generate mock streak data per month
  Map<int, bool> generateStreakDataForMonth(DateTime month) {
    int days = DateTime(month.year, month.month + 1, 0).day;
    Map<int, bool> data = {};
    for (int i = 1; i <= days; i++) {
      // Mock logic: streaked if not a multiple of 6
      data[i] = i % 6 != 0;
    }
    return data;
  }

  Map<int, bool> get currentStreakData =>
      generateStreakDataForMonth(selectedMonth);

  int get daysInMonth {
    return DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
  }

  int get totalStreakDays {
    return currentStreakData.entries.where((e) => e.value).length;
  }

  int get continuousStreakCount {
    final now = DateTime.now();
    if (now.month != selectedMonth.month || now.year != selectedMonth.year) {
      return 0;
    }

    final data = currentStreakData;
    int today = now.day;
    int count = 0;

    // Count backwards from today
    for (int i = today; i >= 1; i--) {
      if (data[i] == true) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  void _changeMonth(int offset) {
    DateTime newMonth =
        DateTime(selectedMonth.year, selectedMonth.month + offset);

    final now = DateTime.now();
    final DateTime currentMonthStart = DateTime(now.year, now.month);
    final DateTime signupMonthStart =
        DateTime(signUpDate!.year, signUpDate!.month);

    if (newMonth.isBefore(signupMonthStart) ||
        newMonth.isAfter(currentMonthStart)) {
      return; // Don't allow navigation beyond bounds
    }

    setState(() {
      selectedMonth = newMonth;
    });
  }

  final Color doraemonBlue = const Color(0xFF2196F3);
  final Color doraemonRed = const Color(0xFFD32F2F);
  bool isLoading = true;
  int? currentStreak;
  int? maximumStreaks;
  @override
  void initState() {
    super.initState();
    fetchstreakDetails();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double spacing = 8;
    Color arrowColor = const Color.fromARGB(255, 2, 51, 91);
    const double cellSize = 40;
    int rowCount = (daysInMonth / 7).ceil();
    double gridHeight = rowCount * (cellSize + spacing) - spacing;
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final now = DateTime.now();
    final currentMonthStart = DateTime(now.year, now.month);
    final signupMonthStart = DateTime(signUpDate!.year, signUpDate!.month);
    final canGoBack = selectedMonth.isAfter(signupMonthStart);
    final canGoForward = selectedMonth.isBefore(currentMonthStart);
    return Scaffold(
      backgroundColor: const Color(0xFFD5EDF4),
      body: signUpDate == null
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
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
                          InfoCard(
                            title: "EXPENSES",
                            subtitle:
                                "🔥 $currentStreak days continuous streak",
                            background: const Color(0xFFFFE6B3),
                            width: screenWidth * 0.42,
                          ),
                          InfoCard(
                            title: "MAXIMUM STREAK",
                            subtitle: "✅ $maximumStreaks days",
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
                            icon: Icon(Icons.arrow_left,
                                size: 32,
                                color: canGoBack ? arrowColor : Colors.grey),
                            onPressed:
                                canGoBack ? () => _changeMonth(-1) : null,
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
                            icon: Icon(Icons.arrow_right,
                                size: 32,
                                color: canGoForward ? arrowColor : Colors.grey),
                            onPressed:
                                canGoForward ? () => _changeMonth(1) : null,
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
                                  final completed =
                                      currentStreakData[day] ?? false;
                                  final isToday = DateTime.now().year ==
                                          selectedMonth.year &&
                                      DateTime.now().month ==
                                          selectedMonth.month &&
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

  Future<void> fetchstreakDetails() async {
    final db = FirebaseFirestore.instance;
    final String? email = FirebaseAuth.instance.currentUser!.email;
    final docReference = db
        .collection('users')
        .doc(email)
        .collection('streaksDetails')
        .doc('details');
    final documentSnapshot = await docReference.get();

    final data = documentSnapshot.data() as Map<String, dynamic>;
    signUpDate = (data['signUpDate'] as Timestamp).toDate();
    currentStreak = data['currentStreak'];
    maximumStreaks = data['maximumStreak'];
    setState(() {
      isLoading = false;
    });
  }
}
