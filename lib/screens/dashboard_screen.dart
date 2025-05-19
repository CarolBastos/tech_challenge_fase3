// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:tech_challenge_fase3/app_state.dart';
import 'package:tech_challenge_fase3/domain/models/user_state.dart';
import 'package:tech_challenge_fase3/data/api/user_api.dart';
import 'package:tech_challenge_fase3/screens/components/dashboard/charts/chart_transactions.dart';
import 'package:tech_challenge_fase3/screens/components/dashboard/menu/custom_app_bar.dart';
import 'package:tech_challenge_fase3/screens/components/dashboard/menu/custom_drawer.dart';
import 'package:tech_challenge_fase3/screens/components/dashboard/new_transaction/transaction_card.dart';
import 'package:tech_challenge_fase3/screens/components/dashboard/transaction_list/transaction_list.dart';
import '../app_colors.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController(initialPage: 0);
  late UserApi _userApi;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = StoreProvider.of<AppState>(context);
    _userApi = UserApi(store);
  }

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    await _userApi.createUserIfNotExists();
    await _syncUserWithRedux();
  }

  Future<void> _syncUserWithRedux() async {
    if (!mounted) return;
    await _userApi.syncUserWithRedux();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, UserState>(
      converter: (store) => store.state.userState,
      builder: (context, userState) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.teaGreen,
          appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
          drawer: const CustomDrawer(),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Text(
                  "Olá, ${userState.displayName}! :)",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Saldo: R\$ ${userState.balance.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            TransactionCard(),
                            SizedBox(height: 24),
                            TransactionList(),
                          ],
                        ),
                      ),
                      TransactionChartSummary(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
