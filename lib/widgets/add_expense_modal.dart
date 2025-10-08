import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smart_expend/helper_classes/insights_helpers.dart';
import 'package:smart_expend/loading_data/set_details_methods.dart';

class AddExpenseModal extends StatefulWidget {
  final String option;
  final String? expenseName;
  final double? expenseValue;
  final DocumentReference? documentReference;
  const AddExpenseModal(
      {super.key,
      required this.option,
      this.expenseName,
      this.expenseValue,
      this.documentReference});
  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> with SingleTickerProviderStateMixin {
  late SetDetailsMethods setDetailsMethods;
  final Color doraemonBlue = Color(0xFF2196F3);
  final Color daisyWhite = Color(0xFFFFFFFF);
  _AddExpenseModalState() {
    setDetailsMethods = SetDetailsMethods();
  }
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  double? currentSavings;
  final _formKey = GlobalKey<FormState>();
  var db = FirebaseFirestore.instance;
  DateTime? initLastActiveDate;
  String expenseName = "";
  double expenseValue = 0;
  DateTime? lastActiveDate;
  int? currentStreak;
  int? maximumStreak;
  String currentMonth =
      DateFormat('MMM-yyyy').format(DateTime.now()); // e.g. "May-2025"

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // now THIS will animate slowly
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));


    _controller.forward();

  }


  @override
  Widget build(BuildContext context) {
    TextEditingController expenseNameController = TextEditingController();
    TextEditingController expenseValueController = TextEditingController();
    if (widget.option == 'edit') {
      expenseNameController.text = widget.expenseName!;
      expenseValueController.text = widget.expenseValue!.toString();
    }
    return SlideTransition(
      position: _slideAnimation,
      child: SizedBox(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color : Colors.white,
                    borderRadius: BorderRadius.circular(30)
                  ),
                  child: IconButton(onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.close, color: doraemonBlue, weight: 50,)),
                )
              ],
            ),

            Image.asset('assets/images/dialog1.png'),

            Container(
              height: 510,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/images/doraemon_flying.png'), fit: BoxFit.cover, alignment: Alignment.center),
                color: Colors.transparent
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: daisyWhite
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextFormField(
                                controller: expenseNameController,
                                cursorColor: doraemonBlue,
                                style: TextStyle(color: doraemonBlue, fontWeight: FontWeight.w600),
                                autocorrect: true,
                                decoration: InputDecoration(
                                    hintText: 'What did you spend for?',
                                    hintStyle: TextStyle(color: doraemonBlue),
                                    hintFadeDuration: const Duration(milliseconds: 30),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: doraemonBlue,
                                        width: 2.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            const BorderSide(color: Colors.red, width: 1.5)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            const BorderSide(color: Colors.red, width: 1.5)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: doraemonBlue,
                                          width: 2.5,
                                        ))),
                                validator: (value) {
                                  return validateExpenseName(value);
                                },
                                onSaved: (newValue) => expenseName = newValue!,
                              ),
                              TextFormField(
                                controller: expenseValueController,
                                cursorColor: doraemonBlue,
                                style: TextStyle(color: doraemonBlue, fontWeight: FontWeight.w400),
                                autocorrect: true,
                                decoration: InputDecoration(
                                    hintText: 'How much did you spend?',
                                    hintStyle: TextStyle(color : doraemonBlue),
                                    hintFadeDuration: const Duration(milliseconds: 30),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: doraemonBlue,
                                        width: 2.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            const BorderSide(color: Colors.red, width: 1.5)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide:
                                            const BorderSide(color: Colors.red, width: 1.5)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: doraemonBlue,
                                          width: 2.5,
                                        ))),
                                validator: (value) {
                                  return validateExpenseValue(value);
                                },
                                onSaved: (newValue) => expenseValue = double.parse(newValue!),
                              ),
                              widget.option == 'add'
                                  ? SizedBox(
                                    width: 100,
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!.validate()) {
                                            _formKey.currentState!.save();
                                            Insights insights = Insights();
                                            String response = await insights.categorizeExpenses(expenses : <String, dynamic> {
                                              'name' : expenseName,
                                              'amount' : expenseValue,
                                            });
                                            print(response);
                                            if (response == 'Invalid') {
                                              response = 'Others';
                                            }
                                            String? email =
                                                FirebaseAuth.instance.currentUser!.email;
                                            var userReference = db.collection("users").doc(email);
                                            await userReference
                                                .collection("dailyExpenses")
                                                .add(<String, dynamic>{
                                              'expenseName': expenseName,
                                              'expenseValue': expenseValue,
                                              'category' : response,
                                              'timeStamp': DateTime.now(),
                                            });
                                            await setDetailsMethods.addToCurrentSavings(currentSavings: currentSavings, expenseValue: expenseValue);
                                            await getStreakDetails();
                                            await db
                                                .collection('users')
                                                .doc(email)
                                                .collection('streaksDetails')
                                                .doc('details')
                                                .set(<String, dynamic>{
                                              'currentStreak': currentStreak,
                                              'maximumStreak': maximumStreak,
                                              'lastActiveDate': lastActiveDate
                                            }, SetOptions(merge: true));
                                            await setStreakActiveDetails(lastActiveDate: lastActiveDate!);
                                            await addExpenseToMonth();
                                            Navigator.pop(context);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                          ),
                                          backgroundColor: doraemonBlue
                                        ),
                                        child: const Text('Add', style: TextStyle(color: Colors.white),)
                                      ),
                                  )
                                  : SizedBox(
                                    width: 100,
                                    child: ElevatedButton(
                                        onPressed: () async {
                                          if (_formKey.currentState!.validate()) {
                                            _formKey.currentState!.save();

                                            Insights insights = Insights();

                                            String response = await insights.categorizeExpenses(expenses : <String, dynamic> {
                                              'name' : expenseName,
                                              'amount' : expenseValue,
                                            });
                                            if (response == 'Invalid') {
                                              response = 'Other';
                                            }

                                            double previousExpense = await getPreviousExpense();
                                            widget.documentReference!.update(<String, dynamic>{
                                              'expenseName': expenseName,
                                              'category' : response,
                                              'expenseValue': expenseValue,
                                            });
                                            await setDetailsMethods.addToCurrentSavings(previousExpense : previousExpense, currentSavings : currentSavings, expenseValue : expenseValue);
                                            await addExpenseToMonth(
                                                previousExpense: previousExpense);
                                            Navigator.pop(context);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            backgroundColor: doraemonBlue
                                        ),
                                        child: const Text('Update', style: TextStyle(color: Colors.white),)),
                                  )
                            ],
                          ),
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
    );
  }

  validateExpenseName(String? value) {
    if (value == null || value.isEmpty) {
      return "Must fill an expense name";
    }
    return null;
  }

  validateExpenseValue(String? value) {
    if (value == null || value.isEmpty) {
      return "Must fill expense value";
    }
    if (double.tryParse(value) == null) {
      return "Enter valid expense value";
    }
    return null;
  }

  Future<void> addExpenseToMonth({double? previousExpense}) async {
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    final monthlyDocRef = db
        .collection('users')
        .doc(userEmail)
        .collection('monthlyExpenses')
        .doc('${DateTime.now().year}-${DateTime.now().month}details');

    double totalExpense = await getExpenseOfCurrentMonth();

    if (previousExpense != null) {
      totalExpense = totalExpense - previousExpense + expenseValue;
    } else {
      totalExpense += expenseValue;
    }

    final docSnapshot = await monthlyDocRef.get();
    if (docSnapshot.exists) {
      await monthlyDocRef.update({'expenseValue': totalExpense});
    } else {
      await monthlyDocRef.set({
        'expenseValue': totalExpense,
        'month': DateFormat('MMM-yyyy').format(DateTime.now()),
      });
    }
  }

  Future<double> getExpenseOfCurrentMonth() async {
    final db = FirebaseFirestore.instance;
    final DocumentReference documentReference = db
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('monthlyExpenses')
        .doc('${DateTime.now().year}-${DateTime.now().month}details');
    DocumentSnapshot documentSnapshot = await documentReference.get();

    final data = documentSnapshot.data() as Map<String, dynamic>? ?? {};

    double currentExpense = 0.0;
    if (data.containsKey('expenseValue')) {
      final value = data['expenseValue'];
      if (value is int) {
        currentExpense = value.toDouble();
      } else if (value is double) {
        currentExpense = value;
      } else if (value is String) {
        currentExpense = double.tryParse(value) ?? 0.0;
      }
    }
    return currentExpense;
  }

  Future<double> getPreviousExpense() async {
    final DocumentReference<Object?>? documentReference =
        widget.documentReference;
    final DocumentSnapshot documentSnapshot = await documentReference!.get();
    final data = documentSnapshot.data() as Map<String, dynamic>;
    double previousExpense = (data['expenseValue'] as num).toDouble();
    return previousExpense;
  }

  Future<void> getStreakDetails() async {
    String? email = FirebaseAuth.instance.currentUser!.email;
    final db = FirebaseFirestore.instance;
    var documentReference = db
        .collection('users')
        .doc(email)
        .collection('streaksDetails')
        .doc('details');
    DateTime todaysDate = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
    var documentSnapshot = await documentReference.get();
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      Timestamp? temp = data['lastActiveDate'];
      if (temp == null) {
        lastActiveDate = todaysDate;
      }
      else {
        lastActiveDate =
            (data['lastActiveDate'] ?? todaysDate as Timestamp).toDate();
      }
      initLastActiveDate = lastActiveDate;
      currentStreak = data['currentStreak'];
      maximumStreak = data['maximumStreak'];
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (currentStreak == null || maximumStreak == null) {
        currentStreak = 1;
        maximumStreak = 1;
        lastActiveDate = today;
      } else if (lastActiveDate == today.subtract(Duration(days: 1))) {
        currentStreak = currentStreak! + 1;
        maximumStreak = max(currentStreak!, maximumStreak!);
        lastActiveDate = today;
      } else if (lastActiveDate != today) {
        currentStreak = 1;
        maximumStreak = max(maximumStreak!,1);
        lastActiveDate = today;
      }
    } else {
      currentStreak = 1;
      maximumStreak = 1;
      final now = DateTime.now();
      final onlyDate = DateTime(now.year, now.month, now.day);
      lastActiveDate = onlyDate;
    }
  }

  Future<void> setStreakActiveDetails({required DateTime lastActiveDate}) async {
  final db = FirebaseFirestore.instance;
  final String? email = FirebaseAuth.instance.currentUser!.email;
  final CollectionReference collectionReference =
      db.collection('users').doc(email).collection('activeStreak');

  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime yesterday = today.subtract(Duration(days: 1));

  final doesCollectionExist =
      await collectionExists(collectionReference: collectionReference);

  if (!doesCollectionExist) {
    await collectionReference.add({
      'timeStamp': today,
      'streakStatus': 1,
    });
  } else {
    final latestSnapshot = await collectionReference
        .orderBy('timeStamp', descending: true)
        .limit(1)
        .get();

    final latestDoc = latestSnapshot.docs.firstOrNull;
    final latestDate = latestDoc != null
        ? (latestDoc['timeStamp'] as Timestamp).toDate()
        : null;
    final latestOnlyDate = latestDate != null
        ? DateTime(latestDate.year, latestDate.month, latestDate.day)
        : null;

    if (latestOnlyDate != today) {
      // ✅ Fix: compare only date parts
      final DateTime lastActiveOnlyDate = DateTime(
      initLastActiveDate!.year, initLastActiveDate!.month, initLastActiveDate!.day);
      if (lastActiveOnlyDate != today && lastActiveOnlyDate != yesterday) {
        await collectionReference.add({
          'timeStamp': lastActiveOnlyDate.add(Duration(days: 1)),
          'streakStatus': -1,
        });
      }
      await collectionReference.add({
        'timeStamp': today,
        'streakStatus': 1,
      });
    }
  }
}

  Future<bool> collectionExists(
      {required CollectionReference collectionReference}) async {
    final snapshot = await collectionReference.limit(1).get();
    return snapshot.docs.isNotEmpty;
  }
  
  
}
