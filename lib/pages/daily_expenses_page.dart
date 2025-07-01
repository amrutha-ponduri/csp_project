// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smart_expend/helper_classes/delete_helper.dart';
import 'package:smart_expend/loading_data/expensemodel.dart';
import 'package:smart_expend/loading_data/load_details_methods.dart';
import 'package:smart_expend/loading_data/set_details_methods.dart';
import 'package:smart_expend/pages/store_pocketmoney.dart';
import 'package:smart_expend/pages/profile_page.dart';
import 'package:smart_expend/pages/streak_page.dart';
import 'package:smart_expend/pages/target_page.dart';
import 'package:smart_expend/widgets/add_expense_modal.dart';
import 'package:smart_expend/widgets/snackbar.dart';

class DailyExpenses extends StatefulWidget {
  const DailyExpenses({super.key});

  @override
  State<DailyExpenses> createState() => _DailyExpensesState();
}

class _DailyExpensesState extends State<DailyExpenses> {

  showModal({expenseName, expenseValue, documentReference}) {

    showModalBottomSheet(
        backgroundColor: Colors.transparent,

        context: context,
        isScrollControlled: true,
        builder: (context) {
          return AddExpenseModal(
            option: 'edit',
            expenseName: expenseName,
            expenseValue: expenseValue,
            documentReference: documentReference,
          );
        }
    );
  }

  double? previousSavings;
  double? targetAmount;
  double? pocketMoney;
  Color doraemonBlue = Color(0xFF2196F3);
  Color daisyWhite = Color(0xFFFFFDE7);
  Color pearlWhite = Color(0xFFFBFCF8);
  @override
  void initState() {
    super.initState();
    _initAsync();
  }

  Future<void> _initAsync() async {
    BatchDelete bd = BatchDelete();
    await bd.batchDelete();
    await bd.batchDeleteYears();

    await loadPocketMoney(); // This might show dialog & navigate
    if (!mounted) return; // If user navigated away, stop here

    await loadTargetandSavingsDetails(); // May show dialog
    if (!mounted) return;

    updatePreviousSavings(); // No async, but good practice to check anyway
  }

  var db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    Timestamp startTimeStamp = Timestamp.fromDate(startDate);
    User? user = FirebaseAuth.instance.currentUser;
    String? emailAddress = user!.email;
    return Scaffold(
      appBar: AppBar(
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StreaksPage(),
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.only(right : 6.0),
              child: Image.asset(
                'assets/images/fire_streaks.png',
                width: 40,
                height: 40,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
            },
            child: Padding(
              padding: const EdgeInsets.only(right : 5.0),
              child: Image.asset('assets/images/doraemon.png',width: 40, height: 40,),
            ),
          ),
        ],
        backgroundColor: Color(0xFF78d5fa), // Light sky blue
        title: Text(
          "Daily Expenses",
          style: TextStyle(
              color: Color(0xFF00008B),
              fontFamily: 'Baloo2',
              fontWeight: FontWeight.w500
            ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            'assets/images/background_bells.jpg',
            fit: BoxFit.fill,
            repeat: ImageRepeat.repeatY,
          )),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(emailAddress)
                .collection('dailyExpenses')
                .where('timeStamp', isGreaterThanOrEqualTo: startTimeStamp)
                .orderBy('timeStamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No expenses added'),
                  );
                }
                final expenses = snapshot.data!.docs.map((doc) {
                  final data = doc.data();
                  return Expense(
                    title: data['expenseName'],
                    amount: (data['expenseValue'] as num).toDouble(),
                    date: (data['timeStamp'] as Timestamp).toDate(),
                    docReference: doc.reference,
                  );
                }).toList();
                final items = buildGroupedExpenseList(expenses);
                return ListView.separated(
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        height: 0,
                        width: double.infinity,
                      );
                    },
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      if (item is ExpenseHeader) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              color : pearlWhite
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                item.label,
                                style: const TextStyle(
                                    color: Color(0xFF00008B),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Baloo2'),
                              ),
                            ),
                          ),
                        );
                      } else if (item is ExpenseEntry) {
                        final e = item.expense;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: pearlWhite,
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      toInitCap(e.title),
                                      style: TextStyle(
                                          color: doraemonBlue,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Nunito'),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      e.amount.toStringAsFixed(2),
                                      style: TextStyle(
                                          color: doraemonBlue,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Nunito'),
                                    ),
                                  ),
                                  PopupMenuButton(onSelected: (value) async {
                                    if (value == 'delete') {
                                      try {
                                        await deleteExpense(
                                            expenseDocRef: e.docReference);
                                        await e.docReference.delete();
                                      } on FirebaseException {
                                        Snackbarwidget snackbar =
                                            Snackbarwidget(
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        255, 239, 156, 151),
                                                content: 'Unable to delete',
                                                textColor: const Color.fromARGB(
                                                    255, 83, 9, 9));
                                        snackbar.showSnackBar();
                                      }
                                    } else if (value == 'edit') {
                                      Future.microtask(() {
                                        showModal(
                                          expenseName: e.title,
                                          expenseValue: e.amount,
                                          documentReference: e.docReference,
                                        );
                                      });
                                    }
                                  }, itemBuilder: (context) {
                                    return [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      )
                                    ];
                                  })
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    });
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(onPressed: () async {
            await showMaterialModalBottomSheet(
                context: context,
                builder: (context) => const AddExpenseModal(
                      option: 'add',
                    ));
          },
      backgroundColor: doraemonBlue,
        child: Icon(Icons.add, color: Colors.white, weight: 20,),
      
      ),
      // floatingActionButton: EnterExpenseButton(
      //   onPressed: () async {
      //     await showMaterialModalBottomSheet(
      //         context: context,
      //         builder: (context) => const AddexpenseModal(
      //               option: 'add',
      //             ));
      //   },
      // ),
    );
  }



  Future<void> deleteExpense({required DocumentReference expenseDocRef}) async {
    final userEmail = FirebaseAuth.instance.currentUser!.email;
    final monthlyDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail)
        .collection('monthlyExpenses')
        .doc('${DateTime.now().year}-${DateTime.now().month}details');

    // Step 1: Get the deleted expense value
    final docSnapshot = await expenseDocRef.get();
    if (!docSnapshot.exists) return;

    final data = docSnapshot.data() as Map<String, dynamic>;
    final double deletedValue = (data['expenseValue'] as num).toDouble();

    // Step 2: Get the current monthly total
    final monthlySnapshot = await monthlyDocRef.get();
    double currentTotal = 0.0;
    if (monthlySnapshot.exists) {
      final monthData = monthlySnapshot.data() as Map<String, dynamic>;
      final value = monthData['expenseValue'];
      if (value is int) {
        currentTotal = value.toDouble();
      } else if (value is double) {
        currentTotal = value;
      }
    }

    // Step 3: Subtract deleted value from monthly total
    final updatedTotal = currentTotal - deletedValue;

    // Step 4: Update Firestore
    await monthlyDocRef.update({'expenseValue': updatedTotal});
    SetDetailsMethods setDetailsMethods = SetDetailsMethods();
    await setDetailsMethods.updateOnlySavingsOfCurrentSavings(
        removedExpense: deletedValue);

    // Step 5: Delete the daily expense document
    await expenseDocRef.delete();
  }

  Future<void> loadTargetandSavingsDetails() async {
    LoadDetailsMethods loadDetailsMethods = LoadDetailsMethods();
    previousSavings = await loadDetailsMethods.getPreviousSavings();
    // if (previousSavings == null) {
    //   return;
    // }
    Map<String, dynamic>? targetProductDetails =
        await loadDetailsMethods.fetchTargetProductDetails();
    // if (!mounted) return;

    if (targetProductDetails == null) {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Please set your target'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TargetPage()),
                  );
                },
                child: Text('Set Target'),
              ),
            ],
          );
        },
      );
    } else {
      targetAmount = await targetProductDetails['targetAmount'];
      previousSavings = previousSavings ?? 0;
      if (targetAmount! <= previousSavings!) {
        await setData(remainingSavings: previousSavings! - targetAmount!);
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                title: Text('Hurray! Target Acheived'),
                actions: [
                  TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TargetPage()));
                      },
                      child: Text('Set your next target')),
                ],
              );
            });
      }
    }
  }

  Future<void> setData({required double remainingSavings}) async {
    SetDetailsMethods setDetailsMethods = SetDetailsMethods();
    await setDetailsMethods.setNewTarget(newTarget: <String, dynamic>{
      'targetProduct': null,
      'targetAmount': 0.0
    });
    await setDetailsMethods.setPreviousSavings(
        remainingSavings: remainingSavings);
  }

  Future<void> loadPocketMoney() async {
    LoadDetailsMethods loadDetailsMethods = LoadDetailsMethods();
    Map<String, dynamic>? pocketMoneyDetails =
        await loadDetailsMethods.fetchPocketMoneyDetails(
      month: DateTime.now().month,
      year: DateTime.now().year,
    );

    if (pocketMoneyDetails == null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Please save your pocket money details'),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close the dialog
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StorePocketMoney()),
                  );
                },
                child: Text('Add pocket money details'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> updatePreviousSavings() async {
    LoadDetailsMethods loadDetailsMethods = LoadDetailsMethods();
    Map<String, dynamic>? currentSavings =
        await loadDetailsMethods.getCurrentSavings();
    if (currentSavings == null) {
      return;
    }
    if ((currentSavings['month'] as Timestamp).toDate() !=
        DateTime(DateTime.now().year, DateTime.now().month)) {
      SetDetailsMethods setDetailsMethods = SetDetailsMethods();
      await setDetailsMethods.updatePreviousSavings(
          addedSavings: (currentSavings['savings'] as num).toDouble());
    }
  }

  String toInitCap(String title) {
    if (title.length < 2) {
      return title.toUpperCase();
    }
    return title[0].toUpperCase() + title.substring(1);
  }
}
