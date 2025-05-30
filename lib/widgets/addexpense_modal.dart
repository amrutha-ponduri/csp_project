// ignore_for_file: unused_import, use_build_context_synchronously

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddexpenseModal extends StatefulWidget {
  final String option;
  final String? expenseName;
  final double? expenseValue;
  final DocumentReference? documentReference;
  const AddexpenseModal(
      {super.key,
      required this.option,
      this.expenseName,
      this.expenseValue,
      this.documentReference});
  @override
  State<AddexpenseModal> createState() => _AddexpenseModalState();
}

class _AddexpenseModalState extends State<AddexpenseModal> {
  final _formKey = GlobalKey<FormState>();
  var db = FirebaseFirestore.instance;
  String expenseName = "";
  double expenseValue = 0;
  DateTime? lastActiveDate;
  int? currentStreak;
  int? maximumStreak;
  String currentMonth =
      DateFormat('MMM-yyyy').format(DateTime.now()); // e.g. "May-2025"
  @override
  Widget build(BuildContext context) {
    TextEditingController expenseNameController = TextEditingController();
    TextEditingController expenseValueController = TextEditingController();
    if (widget.option == 'edit') {
      expenseNameController.text = widget.expenseName!;
      expenseValueController.text = widget.expenseValue!.toString();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 300,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextFormField(
                controller: expenseNameController,
                autocorrect: true,
                decoration: InputDecoration(
                    hintText: 'What did you spend for?',
                    hintFadeDuration: const Duration(milliseconds: 30),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1,
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
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ))),
                validator: (value) {
                  return validateExpenseName(value);
                },
                onSaved: (newValue) => expenseName = newValue!,
              ),
              TextFormField(
                controller: expenseValueController,
                autocorrect: true,
                decoration: InputDecoration(
                    hintText: 'How much did you spend?',
                    hintFadeDuration: const Duration(milliseconds: 30),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1,
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
                        borderSide: const BorderSide(
                          color: Colors.black,
                          width: 1,
                        ))),
                validator: (value) {
                  return validateExpenseValue(value);
                },
                onSaved: (newValue) => expenseValue = double.parse(newValue!),
              ),
              widget.option == 'add'
                  ? ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          String? email =
                              FirebaseAuth.instance.currentUser!.email;
                          var userReference = db.collection("users").doc(email);
                          userReference
                              .collection("dailyExpenses")
                              .add(<String, dynamic>{
                            'expenseName': expenseName,
                            'expenseValue': expenseValue,
                            'timeStamp': DateTime.now(),
                          });
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
                          await setStreakActiveDetails();
                          await addExpenseToMonth();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          double previousExpense = await getPreviousExpense();
                          widget.documentReference!.update(<String, dynamic>{
                            'expenseName': expenseName,
                            'expenseValue': expenseValue,
                          });
                          await addExpenseToMonth(
                              previousExpense: previousExpense);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Update'))
            ],
          ),
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
    double previousExpense = data['expenseValue'];
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
    var documentSnapshot = await documentReference.get();
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      lastActiveDate = (data['lastActiveDate'] as Timestamp).toDate();
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
        maximumStreak = 1;
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

  Future<void> setStreakActiveDetails() async {
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
      // First ever streak entry
      await collectionReference.add({
        'timeStamp': today,
        'streakStatus': 1,
      });
    } else {
      // Fetch latest streak entry
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
        // Handle break in streak if needed
        if (lastActiveDate != today && lastActiveDate != yesterday) {
          await collectionReference.add({
            'timeStamp': lastActiveDate!.add(Duration(days: 1)),
            'streakStatus': -1,
          });
        }

        // Always add today's status
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
