import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/daily_expenses_page.dart';
import '../pages/month_end_page.dart';
import '../pages/signin_page.dart';
import '../loading_data/load_details_methods.dart';

class AuthenticateCheck extends StatefulWidget {
  const AuthenticateCheck({super.key});

  @override
  State<AuthenticateCheck> createState() => _AuthenticateCheckState();
}

class _AuthenticateCheckState extends State<AuthenticateCheck> {
  @override
  Widget build(BuildContext context) {
    return MonthEndPage(goalAmount: 2000, savedAmount: 1500, month: 'May', year: 2025);
    // return StreamBuilder<User?>(
    //   stream: FirebaseAuth.instance.authStateChanges(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //
    //     if (snapshot.hasData) {
    //       return FutureBuilder<Map<String, dynamic>?>(
    //         future: shouldShowSummaryWithData(),
    //         builder: (context, snapshot) {
    //           if (snapshot.connectionState == ConnectionState.waiting) {
    //             return const Center(child: CircularProgressIndicator());
    //           }
    //
    //           if (snapshot.hasData && snapshot.data != null) {
    //             // Trigger page push
    //             WidgetsBinding.instance.addPostFrameCallback((_) {
    //               Navigator.of(context)
    //                   .pushReplacement(
    //                 MaterialPageRoute(
    //                   builder: (context) => MonthEndPage(
    //                     goalAmount: snapshot.data!['goalAmount'],
    //                     savedAmount: snapshot.data!['savedAmount'],
    //                     month: snapshot.data!['month'],
    //                     year: snapshot.data!['year'],
    //                   ),
    //
    //                 ),
    //               )
    //                   .then((_) {
    //                 // Trigger rebuild when MonthEndPage is popped
    //                 setState(() {});
    //               });
    //             });
    //
    //             // While waiting for MonthEndPage to pop, show something minimal
    //             return const SizedBox.shrink();
    //           }
    //           return const DailyExpenses();
    //         },
    //       );
    //     }
    //
    //     return const SignInPage();
    //   },
    // );
  }

  Future<Map<String, dynamic>?> shouldShowSummaryWithData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();

    if (today.day != 1) return null;

    final currentMonth = today.month;
    final currentYear = today.year;

    final prevMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    final prevYear = currentMonth == 1 ? currentYear - 1 : currentYear;

    // If you want to skip showing twice, uncomment this:
    final lastShownMonth = prefs.getInt('lastShownMonth');
    final lastShownYear = prefs.getInt('lastShownYear');
    if (lastShownMonth == prevMonth && lastShownYear == prevYear) return null;

    await prefs.setInt('lastShownMonth', prevMonth);
    await prefs.setInt('lastShownYear', prevYear);

    LoadDetailsMethods loader = LoadDetailsMethods();
    final expenses = await loader.fetchMonthlyExpensesDetails(
        month: prevMonth, year: prevYear);
    final pocket =
        await loader.fetchPocketMoneyDetails(month: prevMonth, year: prevYear);

    if (expenses.isEmpty || pocket == null) return null;

    return {
      'goalAmount': pocket['targetSavings'],
      'savedAmount': pocket['pocketMoney'] - expenses['expenseValue'],
      'month': DateFormat('MMMM').format(DateTime(prevYear, prevMonth)),
      'year': prevYear,
    };
  }
}
