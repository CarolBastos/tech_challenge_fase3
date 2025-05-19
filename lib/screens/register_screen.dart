import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/domain/business/auth_workflow.dart';
import 'package:tech_challenge_fase3/routes.dart';
import 'package:tech_challenge_fase3/screens/components/custom_button.dart';

import '../app_colors.dart';
import 'components/custom_text_field.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:tech_challenge_fase3/app_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _errorMessage = '';
  bool isLoading = false;
  late AuthWorkflow _authWorkflow;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = StoreProvider.of<AppState>(context);
    _authWorkflow = AuthWorkflow(store);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                'assets/images/ilustracao_register.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 32),
              Text(
                "Criar Conta",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CustomTextField(
                labelText: 'Nome',
                placeholder: 'Digite seu nome',
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
              CustomTextField(
                labelText: 'Confirmar Senha',
                placeholder: 'Confirme sua senha',
                isPassword: true,
                controller: _confirmPasswordController,
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
                  Navigator.pushReplacementNamed(context, Routes.login);
                },
                child: Text(
                  'Já tenho uma conta',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 8),
              CustomButton(
                onPressed: isLoading ? null : _handleRegister,
                width: 144,
                text: 'Criar Conta',
                backgroundColor: AppColors.primary,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    setState(() {
      isLoading = true;
      _errorMessage = '';
    });

    if (!_validate()) {
      setState(() => isLoading = false);
      return;
    }

    try {
      await _authWorkflow.register(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao criar conta. Tente novamente.';
          isLoading = false;
        });
      }
    }
  }

  bool _validate() {
    if (_nameController.text.isEmpty) {
      _errorMessage = 'Informe seu nome';
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

    if (_passwordController.text != _confirmPasswordController.text) {
      _errorMessage = 'As senhas não coincidem';
      return false;
    }

    return true;
  }
}