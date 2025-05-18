import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/screens/dashboard_screen.dart';
import 'package:tech_challenge_fase3/screens/investment_screen.dart';
import 'package:tech_challenge_fase3/screens/transactions_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(height: 40),
          ListTile(
            title: Text('Início'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Transações'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FilteredTransactionScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: Text('Investimentos'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InvestmentScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Outros Serviços'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
