import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_expend/pages/dailyexpensespage.dart';
import 'package:smart_expend/pages/signinpage.dart';

class AuthenticateCheck extends StatefulWidget {
  const AuthenticateCheck({super.key});

  @override
  State<AuthenticateCheck> createState() => _AuthenticateCheckState();
}

class _AuthenticateCheckState extends State<AuthenticateCheck> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if(snapshot.connectionState==ConnectionState.waiting){
        return const Center(child: CircularProgressIndicator(),);
      }
      if(snapshot.hasData){
        return const DailyExpenses();
      }
      return const SignInPage();
    },
    );
  }
}
