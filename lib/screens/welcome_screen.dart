import 'package:flutter/material.dart';
import '../app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text(
          'Welcome page',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF7F3FC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[const Text("pagina welcome")],
            ),
          ),
        ),
      ),
    );
  }
}
