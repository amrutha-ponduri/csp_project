// ignore_for_file: unused_import
import 'package:flutter_popup/flutter_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
  dynamic document;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
        backgroundColor: const Color.fromARGB(255, 180, 200, 234),
        title: const Text("Daily Expenses"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc('user1')
            .collection('dailyExpenses')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!.docs.isEmpty
                ? const Center(child: Text('No expenses added'))
                : ListView.separated(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      document = snapshot.data!.docs[index];
                      Map<String, dynamic> data = document.data();
                      LoadData dataObj = LoadData.fromJson(data);
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
                                    dataObj.name,
                                    emboss: true,
                                    color: const Color.fromARGB(
                                        255, 145, 185, 218),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: ClayText(
                                    dataObj.value.toString(),
                                    emboss: true,
                                    color: const Color.fromARGB(
                                        255, 145, 185, 218),
                                  ),
                                ),
                                PopupMenuButton(onSelected: (value) async {
                                  if (value == 'delete') {
                                    try {
                                      await document.reference.delete();
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
                                          context: context,
                                          expenseName: dataObj.name,
                                          expenseValue: dataObj.value);
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
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(
                        height: 0,
                        width: double.infinity,
                      );
                    },
                  );
          }
          return const Center(child: Text('No expenses added'));
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

  showModal({context, expenseName, expenseValue}) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AddexpenseModal(
          option: 'edit',
          expenseName: expenseName,
          expenseValue: expenseValue,
        );
      },
    );
  }
}
