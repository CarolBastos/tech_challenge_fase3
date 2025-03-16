import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_app_bar.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_drawer.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/new_transaction/transaction_card.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/transaction_list/transaction_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_challenge_fase3/widgets/user/user.dart';
import '../app_colors.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => loadUser());
  }

  void loadUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await createUserFirestore(user);
      await getUserBalance(user);

      if (mounted) {
        setState(() {
          final userModel = Provider.of<UserModel>(context, listen: false);
          userModel.updateUser(
            user.displayName ?? "Usuário",
            userModel.balance,
          );
        });
      }
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

  Future<void> getUserBalance(User user) async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid);

    DocumentSnapshot userDoc = await userRef.get();

    if (userDoc.exists) {
      final userModel = Provider.of<UserModel>(context, listen: false);
      userModel.updateUser(userModel.displayName, userDoc['saldo'] ?? 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

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
                "Olá, ${userModel.displayName}! :)",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "Saldo: R\$ ${userModel.balance}",
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
