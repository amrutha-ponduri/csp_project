//import 'package:smart_expend/pages/signuppage.dart';
// import 'package\:firebase\_core/firebase\_core.dart';

// import 'package\:flutter/foundation.dart';
import 'package\:flutter/material.dart';
import 'package:smart_expend/pages/profile%20page.dart';
import 'package:smart_expend/pages/signuppage.dart';
import 'package:smart_expend/pages/streak_page.dart';
import 'package:smart_expend/widget/camera%20icon_widget.dart';
import 'package:smart_expend/widget/floatingaction%20button_widget.dart';
import 'package:smart_expend/widget/listtilewidget.dart';

// import 'package\:smart\_expend/firebase\_options.dart';
void main() async {
// WidgetsFlutterBinding.ensureInitialized();git
// if(kReleaseMode){
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
// }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyWidgetPage(),
    );
  }
}

class MyWidgetPage extends StatelessWidget {
  const MyWidgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfilePictureWidget(),
    );
  }
}
