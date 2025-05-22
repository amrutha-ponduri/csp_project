// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TargetPage extends StatefulWidget {
  const TargetPage({super.key});

  @override
  TargetPageState createState() => TargetPageState();
}

class TargetPageState extends State<TargetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;
  //File? _imageFile;

  final List<String> _currencies = [
    'USD (\$)',
    'EUR (€)',
    'INR (₹)',
    'GBP (£)',
    'JPY (¥)'
  ];
  String _selectedCurrency = 'USD (\$)';

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _handleAdd() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        _showSnackbar('Please select a date.');
        return;
      }

      final newTarget = <String, dynamic>{
        'product': _productController.text,
        'amount': _amountController.text,
        'currency': _selectedCurrency,
        'date': _selectedDate,
      };
      FirebaseFirestore db = FirebaseFirestore.instance;
      DocumentReference documentReference = db
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('targetProduct')
          .doc('productDetails');
      documentReference.set(newTarget);
      _clearForm();
      _showSnackbar('Target added!');
    }
  }

  void _clearForm() {
    _productController.clear();
    _amountController.clear();
    _selectedDate = null;
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.teal) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'Plan Your Purchase',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _productController,
                              label: 'What do you want to buy?',
                              icon: Icons.shopping_cart,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter a product name'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _pickDate,
                              child: AbsorbPointer(
                                child: _buildTextField(
                                  label: _selectedDate == null
                                      ? 'By when do you want to buy?'
                                      : 'Buy by: ${DateFormat('dd-MM-yyyy').format(_selectedDate!)}',
                                  icon: Icons.calendar_today,
                                  validator: (_) => null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedCurrency,
                                    items: _currencies.map((currency) {
                                      return DropdownMenuItem<String>(
                                        value: currency,
                                        child: Text(currency),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCurrency = value!;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Currency',
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 3,
                                  child: _buildTextField(
                                    controller: _amountController,
                                    label: 'Amount',
                                    icon: Icons.attach_money,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an amount';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Enter a valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: _handleAdd,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Add'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
