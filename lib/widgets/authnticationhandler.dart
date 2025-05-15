import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_expend/pages/dailyexpensespage.dart';
import 'package:smart_expend/pages/signuppage.dart';

class AuthenticateCheck extends StatefulWidget {
  const AuthenticateCheck({super.key});

  @override
  State<AuthenticateCheck> createState() => _AuthenticateCheckState();
}

class _AuthenticateCheckState extends State<AuthenticateCheck> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user == null) {
        push(widget: const RegistrationScreen());
      } else {
        push(widget: const DailyExpenses());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
  push({required Widget widget}){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>widget));
  }
}
