import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/charts/chart_investments.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_app_bar.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/menu/custom_drawer.dart';
import 'package:tech_challenge_fase3/models/user_model.dart';
import '../app_colors.dart';

class InvestmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.teaGreen,
      appBar: CustomAppBar(scaffoldKey: _scaffoldKey),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Olá, ${userModel.displayName}! :)",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              InvestmentPieChart(),
            ],
          ),
        ),
      ),
    );
  }
}
