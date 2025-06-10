import 'dart:core';
import 'package:flutter/material.dart';
import 'package:smart_expend/widgets/daily_chart.dart';
import 'package:smart_expend/widgets/expense_tracker.dart';

class MonthlyReportPage extends StatefulWidget {
  const MonthlyReportPage({super.key});

  @override
  State<MonthlyReportPage> createState() => _MonthlyReportPageState();
}

class _MonthlyReportPageState extends State<MonthlyReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
      children: [
        DailyExpenseChart(),
        DoraemonSummaryChart(),
      ],
      )
    );
  }
}