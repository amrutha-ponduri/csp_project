import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      // TODO: Add real authentication logic here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, ${_nameController.text}!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Please add your name",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter your name" : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: "Enter your age",
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter your age" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? "Enter your phone number"
                    : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || !value.contains("@")
                    ? "Enter valid email"
                    : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) => value == null || value.length < 6
                    ? "Minimum 6 characters"
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signIn,
                child: const Text("Sign In"),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Or sign in with "),
                  IconButton(
                    icon: const Icon(Icons.g_mobiledata),
                    onPressed: () {
                      // TODO: Google sign-in
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.facebook),
                    onPressed: () {
                      // TODO: Facebook sign-in
                    },
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // TODO: Forgot password action
                },
                child: const Text("Forgot Password?"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to actual sign-up screen if this is login
                    },
                    child: const Text("Sign Up Now"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
