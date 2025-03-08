import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/screens/login_screen.dart';

import '../app_colors.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/ilustracao_cadastro.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 32),
              Text(
                "Abrir Conta",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 32),
              const CustomTextField(
                labelText: 'Email',
                placeholder: 'Digite seu email',
              ),
              const SizedBox(height: 10),
              const CustomTextField(
                labelText: 'Senha',
                placeholder: 'Digite sua senha',
                isPassword: true,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  'Já tem uma conta? Faça login',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(144, 48),
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
