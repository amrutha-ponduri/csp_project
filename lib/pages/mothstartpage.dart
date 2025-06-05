import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthStartPage extends StatefulWidget {
  const MonthStartPage({super.key});

  @override
  State<MonthStartPage> createState() => _MonthStartPageState();
}

class _MonthStartPageState extends State<MonthStartPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController pocketMoneyController = TextEditingController();
  final TextEditingController targetSavingsController = TextEditingController();

  double? pocketMoney;
  double? targetSavings;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    fetchMonthData();
  }

  Future<void> fetchMonthData() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('pocketMoney')
        .doc('${DateTime.now().year}-${DateTime.now().month}details');

    final doc = await docRef.get();
    if (doc.exists) {
      setState(() {
        pocketMoney = (doc['pocketMoney'] as num).toDouble();
        targetSavings = (doc['targetSavings'] as num).toDouble();
      });
    }
  }

  Future<void> saveValues(
      {required double pocket, required double target}) async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection('pocketMoney')
        .doc('${DateTime.now().year}-${DateTime.now().month}details');
    await docRef.set({
      'pocketMoney': pocket,
      'targetSavings': target,
      'month': DateFormat('MMM-yyyy').format(DateTime.now()),
    });
    setState(() {
      pocketMoney = pocket;
      targetSavings = target;
      isEditing = false;
    });
  }

  void _startEditing() {
    pocketMoneyController.text = pocketMoney?.toString() ?? '';
    targetSavingsController.text = targetSavings?.toString() ?? '';
    setState(() {
      isEditing = true;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final pocket = double.parse(pocketMoneyController.text);
      final target = double.parse(targetSavingsController.text);
      saveValues(pocket: pocket, target: target);
    }
  }

  @override
  void dispose() {
    pocketMoneyController.dispose();
    targetSavingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MainAxisAlignment alignment =
        pocketMoney != null && targetSavings != null && !isEditing
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.end;
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text("Doraemon Monthly Start",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue.shade700,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround, // No pushing apart
        children: [
          if (pocketMoney != null && targetSavings != null && !isEditing) ...[
            SizedBox(
              height: MediaQuery.of(context).size.height - 150, // adjust based on your screen
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 40,
                    left: MediaQuery.of(context).size.width*0.3+10,
                    child: Image.asset("assets/images/doraemon_dream.png", height: 250),
                  ),
                  Positioned(
                    top: 185,
                    child: Image.asset("assets/images/doraemon_sleeping1.png", height: 270),
                  ),
                  Positioned(
                    top: 395,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: Colors.white,
                        elevation: 6,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _displayRow("Pocket Money", pocketMoney!, Colors.yellow.shade700),
                              const SizedBox(height: 10),
                              _displayRow("Target Savings", targetSavings!, Colors.green.shade700),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text("Edit"),
                                onPressed: _startEditing,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue.shade600,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )

          ] else ...[
            SizedBox(
              height: MediaQuery.of(context).size.height - 250, // adjust based on your screen
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 100,
                    child: Image.asset("assets/images/doraemon_sleeping1.png", height: 270),
                  ),
                  Positioned(
                    top: 310,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      constraints: const BoxConstraints(maxHeight: 350),
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: pocketMoneyController,
                                label: 'Enter Pocket Money (₹)',
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: targetSavingsController,
                                label: 'Enter Target Savings (₹)',
                                validator: (value) {
                                  final target = double.tryParse(value ?? '');
                                  final pocket = double.tryParse(pocketMoneyController.text);
                                  if (target == null || target < 0)
                                    return 'Invalid target amount';
                                  if (pocket != null && target > pocket) {
                                    return 'Target cannot exceed pocket money';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _submitForm,
                                icon: const Icon(Icons.save),
                                label: Text(isEditing ? "Update" : "Save"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightBlue.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )

          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            if (double.tryParse(value) == null) {
              return 'Enter a valid number';
            }
            return null;
          },
    );
  }

  Widget _displayRow(String title, double value, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$title:",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Text("₹$value", style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Icon(Icons.check_circle, color: iconColor, size: 24),
          ],
        )
      ],
    );
  }
}
