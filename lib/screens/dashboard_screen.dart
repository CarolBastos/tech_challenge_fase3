import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_app_bar.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_drawer.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/new_transaction/transaction_card.dart';

import '../app_colors.dart';
import '../widgets/dashboard/new_transaction/new_transaction.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.teaGreen,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [TransactionCard(), SizedBox(height: 20)]),
      ),
    );
  }
}
