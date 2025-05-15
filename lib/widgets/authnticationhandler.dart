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
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        pushReplacement(widget: const RegistrationScreen());
      } else {
        pushReplacement(widget: const DailyExpenses());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
  pushReplacement({required Widget widget}){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>widget));
  }
}
