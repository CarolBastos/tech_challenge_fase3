import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_fase3/provider/transaction_provider.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/graficos/grafico.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/graficos/grafico-atividades.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_app_bar.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_drawer.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/new_transaction/transaction_card.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/transaction_list/transaction_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_challenge_fase3/models/user_model.dart';
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
    DateTime dataAtual = DateTime.now();

    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: Color(0xFF9AC595),
      backgroundColor: Color(0xFF26771C),
      // appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      // drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  //Topo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Olá, ${userModel.displayName}!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Acessado em ${dataAtual.day}/${dataAtual.month}/${dataAtual.year}",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFE4EDE3),
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Icon(Icons.person, color: Color(0xFF26771C)),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  //Total na conta e investimentos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFE4EDE3),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Saldo total",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "R\$ ${userModel.balance}",
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFE4EDE3),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total investido",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "R\$ ${userModel.balance}",
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    LineChartSample1(),
                    PieChartSample1(),
                    // TransactionCard(),
                    SizedBox(height: 24),
                    // TransactionList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
