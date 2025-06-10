// ignore_for_file: unused_import
import 'package:smart_expend/pages/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_expend/firebase_options.dart';
import 'package:smart_expend/pages/month_end_page.dart';
import 'package:smart_expend/pages/month_start_page.dart';
import 'package:smart_expend/pages/signin_page.dart';
import 'package:smart_expend/helper_classes/authenticationhandler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthenticateCheck(),
    );
  }
}
