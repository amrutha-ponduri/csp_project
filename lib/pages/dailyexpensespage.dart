// ignore_for_file: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smart_expend/helper_classes/delete_helper.dart';
import 'package:smart_expend/loading_data/expensemodel.dart';
import 'package:smart_expend/loading_data/get_data.dart';
import 'package:smart_expend/pages/monthlychart.dart';
import 'package:smart_expend/pages/mothstartpage.dart';
import 'package:smart_expend/pages/profile_page.dart';
import 'package:smart_expend/pages/streak_page.dart';
import 'package:smart_expend/widgets/addexpense_modal.dart';
import 'package:smart_expend/widgets/snackbarwidget.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DailyExpenses extends StatefulWidget {
  const DailyExpenses({super.key});

  @override
  State<DailyExpenses> createState() => _DailyExpensesState();
}

class _DailyExpensesState extends State<DailyExpenses> {
  @override
  void initState() {
    // TODO: implement initState
    BatchDelete bd= BatchDelete();
    bd.batchDelete();
    bd.batchDeleteYears();
    super.initState();
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
        leading: Builder(
          builder: (context) {
            return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: Icon(Icons.menu));
          },
        ),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => StreaksPage(),));
          }, icon: Icon(FontAwesomeIcons.fireFlameCurved)),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
                //Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(),));
              },
              icon: Icon(Icons.person_outlined))
        ],
        backgroundColor: const Color.fromARGB(255, 180, 200, 234),
        title: const Text("Daily Expenses"),
        centerTitle: true,
      ),
      drawer: Drawer(
        width: 220, // Custom width
        child: SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.savings, color: Colors.lightBlue),
                  title: Text('Store Pocket Money',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MonthStartPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.bar_chart, color: Colors.lightBlue),
                  title: Text('View Monthly chart',
                      style: TextStyle(color: Colors.blue)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const YearlyChartPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Log Out'),
                  onTap: () async{
                    await FirebaseAuth.instance.signOut();
                  },
                )
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder(
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
                amount: data['expenseValue'],
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
                          color: const Color.fromARGB(255, 97, 127, 151),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.label,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 2, 61, 109)),
                          ),
                        ),
                      ),
                    );
                  } else if (item is ExpenseEntry) {
                    final e = item.expense;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClayContainer(
                        emboss: true,
                        borderRadius: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: ClayText(
                                  e.title,
                                  emboss: true,
                                  color:
                                      const Color.fromARGB(255, 145, 185, 218),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: ClayText(
                                  e.amount.toStringAsFixed(2),
                                  emboss: true,
                                  color:
                                      const Color.fromARGB(255, 145, 185, 218),
                                ),
                              ),
                              PopupMenuButton(onSelected: (value) async {
                                if (value == 'delete') {
                                  try {
                                    await deleteExpense(
                                        expenseDocRef: e.docReference);
                                    await e.docReference.delete();
                                  } on FirebaseException {
                                    Snackbarwidget snackbar = Snackbarwidget(
                                        backgroundColor: const Color.fromARGB(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showMaterialModalBottomSheet(
              context: context,
              builder: (context) => const AddexpenseModal(
                    option: 'add',
                  ));
          setState(() {});
        },
        backgroundColor: const Color.fromARGB(255, 180, 200, 234),
        child: const Icon(
          Icons.add,
          color: Colors.blue,
        ),
      ),
    );
  }

  showModal({expenseName, expenseValue, documentReference}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AddexpenseModal(
          option: 'edit',
          expenseName: expenseName,
          expenseValue: expenseValue,
          documentReference: documentReference,
        );
      },
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

    // Step 5: Delete the daily expense document
    await expenseDocRef.delete();
  }
}
