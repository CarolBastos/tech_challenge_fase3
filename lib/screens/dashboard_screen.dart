import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_app_bar.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_drawer.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/new_transaction/transaction_card.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/transaction_list/transaction_list.dart';

import '../app_colors.dart';
import '../widgets/dashboard/new_transaction/new_transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String displayName = "Usuário";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      setState(() {
        displayName = user.displayName!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.teaGreen,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: const CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Olá, $displayName! :)",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              TransactionCard(),
              SizedBox(height: 24),
              TransactionList(),
            ],
          ),
        ),
      ),
    );
  }
}
