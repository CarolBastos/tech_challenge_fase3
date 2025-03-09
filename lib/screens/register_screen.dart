import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tech_challenge_fase3/routes.dart';
import 'package:tech_challenge_fase3/screens/login_screen.dart';
import 'package:tech_challenge_fase3/widgets/custom_button.dart';

import '../app_colors.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _errorMessage = '';
  bool isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

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
              const SizedBox(height: 15),
              Text(
                "Abrir Conta",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                labelText: 'Nome',
                placeholder: 'Digite seu nome completo',
                controller: _nameController,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                labelText: 'Email',
                placeholder: 'Digite seu email',
                controller: _emailController,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                labelText: 'Senha',
                placeholder: 'Digite sua senha',
                isPassword: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14.0,
                  ),
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
              CustomButton(
                onPressed: () {
                  isLoading ? null : _register();
                },
                width: 144,
                text: 'Cadastrar',
                backgroundColor: AppColors.error,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _register() async {
    try {
      setState(() {
        isLoading = true;
        _errorMessage = '';
      });

      bool isValid = _validate();
      if (!isValid) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

      User? user = userCredential.user;
      if (user != null) {
        await user.updateProfile(displayName: _nameController.text);
        await user.reload();
      }

      Navigator.pushReplacementNamed(context, Routes.login);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  bool _validate() {
    if (_nameController.text.isEmpty) {
      _errorMessage = 'Informe o nome';
      return false;
    }

    if (_emailController.text.isEmpty) {
      _errorMessage = 'Informe o email';
      return false;
    }

    if (_passwordController.text.isEmpty) {
      _errorMessage = 'Informe a senha';
      return false;
    }

    return true;
  }
}
