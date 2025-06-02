// ignore_for_file: unused_import
import 'package:smart_expend/pages/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_expend/firebase_options.dart';
import 'package:smart_expend/pages/monthendpage.dart';
import 'package:smart_expend/pages/mothstartpage.dart';
import 'package:smart_expend/pages/signinpage.dart';
import 'package:smart_expend/helper_classes/authenticationhandler.dart';
import 'package:smart_expend/pages/targetpage.dart';

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
