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
  Map<int, bool> _monthlyStreakData = {};
  Map<int, bool> get currentStreakData => _monthlyStreakData;
  final Map<String, Map<int, bool>> _streakCache = {};

  DateTime selectedMonth = DateTime.now();
  DateTime? signUpDate;

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

  void _changeMonth(int offset) async {
    DateTime newMonth =
        DateTime(selectedMonth.year, selectedMonth.month + offset);

    final now = DateTime.now();
    final DateTime currentMonthStart = DateTime(now.year, now.month);
    int signUpMonth = signUpDate!.month;
    int signUpYear = signUpDate!.year;
    if (signUpDate!.month == 12) {
      signUpYear = signUpYear + 1;
      signUpMonth = 1;
    }
    else {
      signUpMonth = signUpMonth + 1;
    }
    final DateTime signupMonthStart =
        DateTime(signUpDate!.year, signUpDate!.month);

    if (newMonth.isBefore(signupMonthStart) ||
        newMonth.isAfter(currentMonthStart)) {
      return; // Don't allow navigation beyond bounds
    }

    setState(() {
      selectedMonth = newMonth;
      isLoading = true;
    });

    await getStreakOfCurrentMonth();

    setState(() {
      isLoading = false;
    });
  }

  DateTime? lastActiveDate;
  final Color doraemonBlue = const Color(0xFF2196F3);
  final Color doraemonRed = const Color(0xFFD32F2F);
  bool isLoading = true;
  int? currentStreak;
  int? maximumStreaks;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await getStreakOfCurrentMonth();
    });
    loadData();
  }
  Future<void> loadData() async{
    await fetchstreakDetails();
    await fetchLastActiveDate();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double spacing = 8;
    Color arrowColor = const Color.fromARGB(255, 2, 51, 91);
    const double cellSize = 40;
    int rowCount = (daysInMonth / 7).ceil();
    double gridHeight = rowCount * (cellSize + spacing) ;
    if (signUpDate == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final now = DateTime.now();
    //fetchLastActiveDate();
    final currentMonthStart = DateTime(now.year, now.month);
    final signupMonthStart = DateTime(signUpDate!.year, signUpDate!.month);
    final canGoBack = selectedMonth.isAfter(signupMonthStart);
    final canGoForward = selectedMonth.isBefore(currentMonthStart);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doraemon Monthly Start",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue.shade700,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFD5EDF4),
      body: signUpDate == null
          ? Center(child: CircularProgressIndicator())
          : Column(
            mainAxisAlignment:  MainAxisAlignment.center,
            children: [SafeArea(
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
                                color: selectedMonth.isAfter(signupMonthStart) ? arrowColor : Colors.grey),
                            onPressed: canGoBack
                                ? () {
                                    _changeMonth(-1);
                                  }
                                : null,
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
                            onPressed: canGoForward
                                ? () {
                                    _changeMonth(1);
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        child: SizedBox(
                          height: gridHeight,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : GridView.builder(
                                        //shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
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
                                          final date = DateTime(
                                              selectedMonth.year,
                                              selectedMonth.month,
                                              day);
                                          final today = DateTime(
                                              DateTime.now().year,
                                              DateTime.now().month,
                                              DateTime.now().day);
                                          final isFuture =
                                              date.isAfter(DateTime.now());
                                          final isBeforeSignUp =
                                              signUpDate != null &&
                                                  date.isBefore(signUpDate!.subtract(Duration(days:1)));
                                          final completed =
                                              currentStreakData[day] ?? false;
                                          final isToday = DateTime.now().year ==
                                                  selectedMonth.year &&
                                              DateTime.now().month ==
                                                  selectedMonth.month &&
                                              DateTime.now().day == day;

                                          String imageAsset;
                                          Color labelColor;
                                          Color textColor = Colors.white;
                                          if (isFuture ||
                                              isBeforeSignUp ||
                                              (isToday &&
                                                  (lastActiveDate != today))) {
                                            imageAsset =
                                                'assets/images/neutral_doraemon.png';
                                            labelColor = Colors.white;
                                            textColor = Colors.black;
                                          } else {
                                            if (completed) {
                                              imageAsset =
                                                  'assets/images/happy_doraemon.png';
                                              labelColor = const Color.fromARGB(
                                                  255, 5, 82, 3);
                                            } else {
                                              imageAsset =
                                                  'assets/images/sad_doraemon.png';
                                              labelColor = const Color.fromARGB(
                                                  255, 189, 17, 5);
                                            }
                                          }

                                          return DayStreakBadge(
                                            day: day,
                                            completed: completed,
                                            doraemonBlue: doraemonBlue,
                                            doraemonRed: doraemonRed,
                                            isToday: isToday,
                                            imageAsset: imageAsset,
                                            labelColor: labelColor,
                                            textColor: textColor,
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
                      ),
                    ],
                  ),
                ),
              ),]
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

  Future<void> fetchLastActiveDate() async {
    final db = FirebaseFirestore.instance;
    final String? email = FirebaseAuth.instance.currentUser!.email;
    DateTime today = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
    DateTime yesterday = today.subtract(Duration(days : 1));
    final docReference = db
        .collection('users')
        .doc(email)
        .collection('streaksDetails')
        .doc('details');
    final documentSnapshot = await docReference.get();
    final data = documentSnapshot.data() as Map<String, dynamic>;
    Timestamp? temp = data['lastActiveDate'];
    if(temp==null) {
      currentStreak = 0;
      maximumStreaks = 0;
    }
    else {
      lastActiveDate = (data['lastActiveDate'] as Timestamp).toDate();
      if (lastActiveDate != today && lastActiveDate != yesterday) {
        currentStreak = 0;
      }
      docReference.update({
        'currentStreak': currentStreak,
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> getStreakOfCurrentMonth() async {
    final cacheKey =
        '${selectedMonth.year}-${selectedMonth.month.toString().padLeft(2, '0')}';

    // If cached, use it immediately
    if (_streakCache.containsKey(cacheKey)) {
      setState(() {
        _monthlyStreakData = _streakCache[cacheKey]!;
        isLoading = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final db = FirebaseFirestore.instance;
    final String? email = FirebaseAuth.instance.currentUser!.email;

    final userDoc = await db
        .collection('users')
        .doc(email)
        .collection('streaksDetails')
        .doc('details')
        .get();

    if (!userDoc.exists) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    //final data = userDoc.data()!;
    final DateTime currentMonthStart =
        DateTime(selectedMonth.year, selectedMonth.month, 1);
    final DateTime currentMonthEnd =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    final QuerySnapshot lastChangeBeforeMonth = await db
        .collection('users')
        .doc(email)
        .collection('activeStreak')
        .where('timeStamp', isLessThan: currentMonthStart)
        .orderBy('timeStamp', descending: true)
        .limit(1)
        .get();

    int status = -1; // default value

    if (lastChangeBeforeMonth.docs.isNotEmpty) {
      status = lastChangeBeforeMonth.docs.first['streakStatus'] as int;
    }

// STEP 2: Get all streak changes in the current month
    final QuerySnapshot streakChangesSnapshot = await db
        .collection('users')
        .doc(email)
        .collection('activeStreak')
        .where('timeStamp', isGreaterThanOrEqualTo: currentMonthStart)
        .orderBy('timeStamp', descending: false)
        .get();

    List<QueryDocumentSnapshot> changeDocs = streakChangesSnapshot.docs;

// Generate streak map for the current month
    Map<int, bool> newStreakData = {};
    DateTime pointer = currentMonthStart;
    int index = 0;

    while (pointer.isBefore(currentMonthEnd.add(const Duration(days: 1)))) {
      if (index < changeDocs.length) {
        DateTime changeDate =
            (changeDocs[index]['timeStamp'] as Timestamp).toDate();
        if (isSameDate(changeDate, pointer)) {
          status = changeDocs[index]['streakStatus'] as int;
          index++;
        }
      }
      if (pointer.month == selectedMonth.month &&
          pointer.year == selectedMonth.year) {
        newStreakData[pointer.day] = status == 1;
      }
      pointer = pointer.add(const Duration(days: 1));
    }
    // After generating newStreakData...

// Ensure active streaks don't go beyond lastActiveDate
    final today = DateTime.now();
    final DateTime lastDate = DateTime(today.year, today.month, today.day);
    if (lastActiveDate != null) {
      final DateTime lastActiveDay = DateTime(
          lastActiveDate!.year, lastActiveDate!.month, lastActiveDate!.day);

      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(selectedMonth.year, selectedMonth.month, i);

        // If date is after lastActiveDate and before today, force inactive
        if (date.isAfter(lastActiveDay) && date.isBefore(lastDate)) {
          newStreakData[i] = false;
        }
      }
    }

    // Cache the result
    _streakCache[cacheKey] = newStreakData;

    setState(() {
      _monthlyStreakData = newStreakData;
      isLoading = false;
    });
  }

// Helper to compare dates (ignores time)
  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
