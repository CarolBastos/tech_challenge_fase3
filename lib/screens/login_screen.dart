import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/domain/business/auth_workflow.dart';
import 'package:tech_challenge_fase3/screens/components/custom_button.dart';
import '../app_colors.dart';
import '../routes.dart';
import 'components/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool isLoading = false;

  final AuthWorkflow _authWorkflow = AuthWorkflow();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                'assets/images/ilustracao_login.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 32),
              Text(
                "Login",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                  Navigator.pushReplacementNamed(context, Routes.register);
                },
                child: Text(
                  'Abrir minha conta',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              CustomButton(
                onPressed: () => isLoading ? null : _handleLogin(),
                width: 144,
                text: 'Entrar',
                backgroundColor: AppColors.error,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      isLoading = true;
      _errorMessage = '';
    });

    if (!_validate()) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      await _authWorkflow.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.pushReplacementNamed(context, Routes.dashboard);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao fazer login. Verifique suas credenciais.';
        isLoading = false;
      });
    }
  }

  bool _validate() {
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
