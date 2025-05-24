import 'package:flutter/material.dart';

class DoraemonTextFieldApp extends StatefulWidget {
  const DoraemonTextFieldApp({Key? key}) : super(key: key);

  @override
  State<DoraemonTextFieldApp> createState() => _DoraemonTextFieldAppState();
}

class _DoraemonTextFieldAppState extends State<DoraemonTextFieldApp> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  Widget _gradientTextField({
    required TextEditingController controller,
    required String label,
    required String iconAssetPath,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF99D9F3),
            Color(0xFF00A0DE)
          ], // light blue to Doraemon blue
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(
            color: Color(0xFF005EA2), fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(iconAssetPath, width: 24, height: 24),
          ),
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Color(0xFF005EA2)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up - Doraemon Theme'),
        backgroundColor: const Color(0xFF005EA2),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: _gradientTextField(
            controller: _nameController,
            label: 'Name',
            iconAssetPath: 'assets/icons/doraemon_name.png',
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Please enter your name';
              return null;
            },
          ),
        ),
      ),
    );
  }
}
