import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_app_bar.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_drawer.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/new_transaction/transaction_card.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/transaction_list/transaction_list.dart';

import '../app_colors.dart';
import '../widgets/dashboard/new_transaction/new_transaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  void loadUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await createUserFirestore(user);
      setState(() {
        displayName = user.displayName ?? "Usuário";
      });
    }
  }

  Future<void> createUserFirestore(User user) async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);

    DocumentSnapshot userDoc = await userRef.get();

    if (!userDoc.exists) {
      await userRef.set({
        'nome': user.displayName ?? 'Usuário',
        'email': user.email,
        'saldo': 0.0,
        'criado_em': FieldValue.serverTimestamp(),
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
