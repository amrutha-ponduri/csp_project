// ignore_for_file: unused_import
import 'package:flutter_popup/flutter_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:smart_expend/loading_data/expensemodel.dart';
import 'package:smart_expend/loading_data/get_data.dart';
import 'package:smart_expend/widgets/addexpense_modal.dart';
import 'package:smart_expend/widgets/snackbarwidget.dart';

class DailyExpenses extends StatefulWidget {
  const DailyExpenses({super.key});

  @override
  State<DailyExpenses> createState() => _DailyExpensesState();
}

class _DailyExpensesState extends State<DailyExpenses> {
  var db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    DateTime startDate=DateTime(DateTime.now().year,DateTime.now().month,1);
    Timestamp startTimeStamp=Timestamp.fromDate(startDate);
    return Scaffold(
      appBar: AppBar(
        actions: const [],
        backgroundColor: const Color.fromARGB(255, 180, 200, 234),
        title: const Text("Daily Expenses"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc('user1')
            .collection('dailyExpenses')
            .where('timeStamp',isGreaterThanOrEqualTo: startTimeStamp)
            .orderBy('timeStamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if(snapshot.data!.docs.isEmpty){
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
                final item=items[index];
                if(item is ExpenseHeader){
                  return Center(
                    child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    child: Text(
                      item.label,
                      style: const TextStyle(color: Color.fromARGB(255, 2, 61, 109)),
                    ),
                                    ),
                  );
                }
                else if(item is ExpenseEntry){
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
                              color: const Color.fromARGB(255, 145, 185, 218),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: ClayText(
                              e.amount.toStringAsFixed(2),
                              emboss: true,
                              color: const Color.fromARGB(255, 145, 185, 218),
                            ),
                          ),
                          PopupMenuButton(onSelected: (value) async {
                            if (value == 'delete') {
                              try {
                                await e.docReference.delete();
                              } on FirebaseException {
                                Snackbarwidget snackbar = Snackbarwidget(
                                    backgroundColor: const Color.fromARGB(
                                        255, 239, 156, 151),
                                    content: 'Unable to delete',
                                    textColor:
                                        const Color.fromARGB(255, 83, 9, 9));
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
              }
            );
          }
          return const Center(child: CircularProgressIndicator(),);
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
}
