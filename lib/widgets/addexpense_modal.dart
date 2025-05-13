// ignore_for_file: unused_import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          var userReference =
                              db.collection("users").doc("user1");
                          userReference
                              .collection("dailyExpenses")
                              .add(<String, dynamic>{
                            'expenseName': expenseName,
                            'expenseValue': expenseValue,
                            'timeStamp': DateTime.now(),
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          widget.documentReference!.set(<String, dynamic>{
                            'expenseName': expenseName,
                            'expenseValue': expenseValue,
                            'timeStamp': DateTime.now(),
                          });
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
}
