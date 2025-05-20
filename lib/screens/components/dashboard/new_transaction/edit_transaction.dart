// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/app_state.dart';
import 'package:tech_challenge_fase3/data/api/transaction_api.dart';
import 'package:tech_challenge_fase3/data/api/user_api.dart';
import 'package:tech_challenge_fase3/screens/components/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class EditTransaction extends StatefulWidget {
  final DateTime data;
  final String tipoTransacao;
  final String valor;

  const EditTransaction({
    Key? key,
    required this.data,
    required this.tipoTransacao,
    required this.valor,
  }) : super(key: key);

  @override
  _EditTransactionState createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  late String? tipoTransacao;
  late TextEditingController valorController;
  final List<String> tiposTransacao = ['Depósito', 'Saque', 'Transferência'];
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TransactionApi _transactionApi = TransactionApi();
  late UserApi _userApi;
  late Store<AppState> _store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _store = StoreProvider.of<AppState>(context);
    _userApi = UserApi(_store);
  }

  @override
  void initState() {
    super.initState();
    tipoTransacao = widget.tipoTransacao;
    valorController = TextEditingController(text: widget.valor);
  }

  @override
  void dispose() {
    valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Editar Transação',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: tipoTransacao,
            onChanged: (newValue) {
              setState(() {
                tipoTransacao = newValue;
              });
            },
            items: tiposTransacao.map((tipo) {
              return DropdownMenuItem(
                value: tipo,
                child: Text(tipo),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Tipo de Transação',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.white,
            ),
            isExpanded: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, selecione um tipo de transação.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Valor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: valorController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '00,00',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira um valor.';
              }
              final valorNumerico = double.tryParse(value.replaceAll(',', '.'));
              if (valorNumerico == null) {
                return 'Por favor, insira um valor numérico válido.';
              }
              if (valorNumerico <= 0) {
                return 'O valor deve ser maior que zero.';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: CustomButton(
              onPressed: isLoading ? null : () => _handleSubmit(),
              text: 'Salvar alterações',
              backgroundColor: AppColors.darkTeal,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    await _editarTransacao();
  }

  Future<void> _editarTransacao() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      _showSnackBar('Usuário não autenticado.', Colors.orange);
      return;
    }

    try {
      FocusScope.of(context).unfocus();
      setState(() => isLoading = true);

      await _transactionApi.editTransaction(
        date: widget.data,
        newType: tipoTransacao!,
        newValue: valorController.text,
      );

      // Atualiza o estado do usuário diretamente via UserApi
      await _userApi.syncUserWithRedux();

      _showSnackBar('Transação editada com sucesso!', Colors.green);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showSnackBar('Erro ao editar transação: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}