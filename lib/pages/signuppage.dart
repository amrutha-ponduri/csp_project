import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:smart_expend/helper_classes/sign_in_methods.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? emailAddress;
  String? password;
  String? name;
  int? age;
  String? phoneNumber;

  File? _image;
  bool _isPasswordVisible = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // All fields are valid
      name = nameController.text.toString();
      emailAddress = emailController.text.toString();
      phoneNumber = phoneController.text.toString();
      age = int.parse(ageController.text.toString());
      password = passwordController.text.toString();
      SignInHelper signInHelper=SignInHelper();
      signInHelper.signUpWithEmailPassword(context: context,emailAddress: emailAddress,password: password);
      // Handle actual registration logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUnfocus,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildTextField(
                    label: 'Name',
                    controller: nameController,
                    icon: Icons.person,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  buildTextField(
                    label: 'Age',
                    controller: ageController,
                    icon: Icons.cake,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter your age';
                      final age = int.tryParse(value);
                      if (age == null || age < 1 || age > 120) {
                        return 'Enter a valid age';
                      }
                      return null;
                    },
                  ),
                  buildTextField(
                    label: 'Email',
                    controller: emailController,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) return 'Please enter email';
                      if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}')
                          .hasMatch(value)) {
                        return 'Enter valid email';
                      }
                      return null;
                    },
                  ),
                  buildTextField(
                    label: 'Phone',
                    controller: phoneController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter phone number';
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                        return 'Enter a 10-digit phone number';
                      }
                      return null;
                    },
                  ),
                  buildTextField(
                    label: 'Password',
                    controller: passwordController,
                    icon: Icons.lock,
                    obscure: true,
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter password';
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  buildTextField(
                    label: 'Password',
                    controller: confirmPasswordController,
                    icon: Icons.lock,
                    obscure: true,
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter confirm password';
                      if (value != passwordController.text) {
                        return "Password and confir password do not match";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Register'),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const Text("Or sign up with"),
                  const SizedBox(height: 10),
                  GoogleAuthButton(
                    onPressed: () {
                      SignInHelper signInHelper = SignInHelper();
                      signInHelper.signInWithGoogle();
                    },
                  ),
                  const SizedBox(height: 10),
                  FacebookAuthButton(
                    onPressed: () {
                      SignInHelper signInHelper = SignInHelper();
                      signInHelper.signInWithFacebook();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    IconData? icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    bool isPasswordField = label.toLowerCase() == 'password';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPasswordField ? !_isPasswordVisible : obscure,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[100],
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: isPasswordField
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  // void _signUpWithEmailPassword() async {
  //   try {
  //     final credential =
  //         await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: emailAddress!,
  //       password: password!,
  //     );
  //     await credential.user!.updateDisplayName(name);
  //     await credential.user!.reload();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Registration Successful!')),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     String message = '';
  //     if (e.code == 'weak-password') {
  //       message = 'The password provided is too weak.';
  //     } else if (e.code == 'email-already-in-use') {
  //       message = 'The account already exists for that email.';
  //     } else {
  //       message = 'Authentication failed: ${e.message}';
  //     }
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(message)),
  //     );
  //   } catch (e) {
  //     const message = "An unexpected error ocurred";
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(const SnackBar(content: Text(message)));
  //   }
  // }
}
