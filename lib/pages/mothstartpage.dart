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
        pocketMoney = doc['pocketMoney'];
        targetSavings = doc['targetSavings'];
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Saved: ₹$pocket pocket money, ₹$target target savings")),
      );
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
    final MainAxisAlignment alignment = pocketMoney != null && targetSavings != null && !isEditing?MainAxisAlignment.spaceBetween:MainAxisAlignment.end;
    return Scaffold(
        backgroundColor: Colors.lightBlue.shade50,
        appBar: AppBar(
          title: const Text("Doraemon Monthly Start",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.lightBlue.shade700,
          centerTitle: true,
        ),
        body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image :AssetImage('assets/images/doraemon_sleeping1.png')),
        ),
        child: Column(
          mainAxisAlignment: alignment,
          children: [
            //const SizedBox(height: 20),
            if (pocketMoney != null && targetSavings != null && !isEditing) ...[
              Padding(
                padding: const EdgeInsets.only(left: 70.0),
                child: Image.asset("assets/images/doraemon_dream.png",height: 280),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 75.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
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
              )
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
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
                          if (target == null || target < 0) return 'Invalid target amount';
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
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]
          ],
        ),
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
