import 'package:flutter/material.dart';
import 'package:smart_expend/loading_data/load_details_methods.dart';
import 'package:smart_expend/loading_data/set_details_methods.dart';

class TargetPage extends StatefulWidget {
  const TargetPage({super.key});

  @override
  State<TargetPage> createState() => _TargetPageState();
}

class _TargetPageState extends State<TargetPage> {
  String? targetProductName;
  final _formKey = GlobalKey<FormState>();
  double? targetProductPrice;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isEditing = false;
  @override
  void initState() {
    fetchTargetProductDetails();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: const Text("Target product",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue.shade700,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround, // No pushing apart
        children: [
          if (targetProductName != null && targetProductPrice != null && !_isEditing) ...[
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
                              _displayRow("Target product", targetProductName!, Colors.yellow.shade700),
                              const SizedBox(height: 10),
                              _displayRow("Target product price", targetProductPrice!, Colors.green.shade700),
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
      
          ] 
          else ...[
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
                                controller: _nameController,
                                label: 'Enter Product Name',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Must fill';
                                  }
                                  return null;
                                }
                              ),
                              const SizedBox(height: 20),
                              _buildTextField(
                                controller: _priceController,
                                label: 'Enter Price (₹)',
                                validator: (value) {
                                  if (value == null){
                                    return 'Must fill';
                                  }
                                  if (double.tryParse(value) == null || double.tryParse(value)! < 0) {
                                    return 'Invalid price';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _submitForm,
                                icon: const Icon(Icons.save),
                                label: Text(_isEditing ? "Update" : "Save"),
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

  //  Future<void> saveValues(
  //     {required double pocket, required double target}) async {
  //   final email = FirebaseAuth.instance.currentUser?.email;
  //   if (email == null) return;
  //   LoadDetailsMethods loadDetailsMethods = LoadDetailsMethods();
  //   double initPocketMoney = 0;
  //   Map<String, dynamic>? initPocketMoneyDetails = await loadDetailsMethods.fetchPocketMoneyDetails(month: DateTime.now().month, year: DateTime.now().year);
  //   if (initPocketMoneyDetails != null) {
  //     initPocketMoney = (initPocketMoneyDetails['pocketMoney'] as num).toDouble();
  //   }
  //   final docRef = FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(email)
  //       .collection('pocketMoney')
  //       .doc('${DateTime.now().year}-${DateTime.now().month}details');
  //   await docRef.set({
  //     'pocketMoney': pocket,
  //     'targetSavings': target,
  //     'month': DateFormat('MMM-yyyy').format(DateTime.now()),
  //   });
  //   Map<String, dynamic>? currentSavingsData = await loadDetailsMethods.getCurrentSavings();
  //   double updatedSavings;
  //   DateTime monthStamp = DateTime(DateTime.now().year, DateTime.now().month);
  //   if (currentSavingsData == null) {
  //     updatedSavings = pocket;
  //   }
  //   else {
  //     updatedSavings = (currentSavingsData['savings'] as num).toDouble()- initPocketMoney + pocket; 
  //   }
  //   Map<String, dynamic> updatedSavingsDetails = <String, dynamic> {
  //     'savings' : updatedSavings,
  //     'month' : monthStamp,
  //   };
  //   SetDetailsMethods setDetailsMethods = SetDetailsMethods();
  //   setDetailsMethods.updateCurrentSavings(updatedCurrentSavings : updatedSavingsDetails);
  //   setState(() {
  //     pocketMoney = pocket;
  //     targetSavings = target;
  //     isEditing = false;
  //   });
  // }
  Future<void> _saveValues({required Map<String, dynamic> newTarget}) async{
    SetDetailsMethods setDetailsMethods = SetDetailsMethods();
    setDetailsMethods.setNewTarget(newTarget: newTarget);
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.toString();
      final price = double.parse(_priceController.text);
      Map<String, dynamic> newTarget = <String, dynamic> {
        'targetProduct' : name,
        'targetAmount' : price,
      };
      _saveValues(newTarget: newTarget);
    }
  }

  void _startEditing() {
    _nameController.text = targetProductName?.toString() ?? '';
    _priceController.text = targetProductPrice?.toString() ?? '';
    setState(() {
      _isEditing = true;
    });
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

  Widget _displayRow(String title, dynamic value, Color iconColor) {
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
  
  Future<void> fetchTargetProductDetails() async{
    LoadDetailsMethods loadDetailsMethods = LoadDetailsMethods();
    Map<String, dynamic>? targetProduct = await loadDetailsMethods.fetchTargetProductDetails();
    if (targetProduct == null) {
      return;
    }
    targetProductName = targetProduct['productName'];
    targetProductPrice = targetProduct['targetAmount'];
    setState(() {
      
    });
  }
}
