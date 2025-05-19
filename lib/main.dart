// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_expend/pages/monthlychart.dart';
import 'package:smart_expend/pages/signinpage.dart';
import 'package:smart_expend/widget/delete.dart';
import 'pages/monthendpage.dart';
import 'pages/mothstartpage.dart'; // ✅ Import MonthStartPage
import 'pages/dailychart.dart';

// import 'package:smart_expend/firebase_options.dart';
void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // if (kReleaseMode) {
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: YearlyChartPage(),
    );
  }
}

class MyWidgetPage extends StatelessWidget {
  const MyWidgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const AddButton(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 40),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 40),
                const Text('Tap to view the month-start details:'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MonthStartPage(),
                      ),
                    );
                  },
                  child: const Text('View Month-Start Details'),
                ),
                const SizedBox(height: 40),
                const Text('Tap to view the month-end summary:'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MonthEndPage(
                          savedAmount: 1200,
                          goalAmount: 1000,
                          monthlySavedAmount: 300,
                        ),
                      ),
                    );
                  },
                  child: const Text('View Month-End Summary'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
