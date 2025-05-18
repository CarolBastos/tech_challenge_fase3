// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/app_state.dart';
import 'package:tech_challenge_fase3/data/api/transaction_api.dart';
import 'package:tech_challenge_fase3/data/api/user_api.dart';
import 'package:tech_challenge_fase3/domain/models/user_actions.dart';
import 'package:tech_challenge_fase3/screens/components/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_redux/flutter_redux.dart';

class EditTransaction extends StatefulWidget {
  final DateTime data;
  final String tipoTransacao;
  final String valor;

  EditTransaction({
    required this.data,
    required this.tipoTransacao,
    required this.valor,
  });

  @override
  _EditTransactionState createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  late String? tipoTransacao;
  late TextEditingController valorController;
  List<String> tiposTransacao = ['Depósito', 'Saque', 'Transferência'];
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _transactionApi = TransactionApi();
  final UserApi _userApi = UserApi();

  @override
  void initState() {
    super.initState();
    tipoTransacao = widget.tipoTransacao;
    valorController = TextEditingController(text: widget.valor);
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
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: tipoTransacao,
            onChanged: (newValue) {
              setState(() {
                tipoTransacao = newValue;
              });
            },
            items:
                tiposTransacao.map((tipo) {
                  return DropdownMenuItem(value: tipo, child: Text(tipo));
                }).toList(),
            decoration: InputDecoration(
              labelText: 'Tipo de Transação',
              border: OutlineInputBorder(),
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
          SizedBox(height: 20),
          Text(
            'Valor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: valorController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '00,00',
              border: OutlineInputBorder(),
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
          SizedBox(height: 20),
          Center(
            child: CustomButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  isLoading ? null : editarTransacao();
                }
              },
              text: 'Salvar alterações',
              backgroundColor: AppColors.darkTeal,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> editarTransacao() async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário não autenticado.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      FocusScope.of(context).unfocus();
      setState(() {
        isLoading = true;
      });

      await _transactionApi.editTransaction(
        date: widget.data,
        newType: tipoTransacao!,
        newValue: valorController.text,
      );

      final newBalance = await _userApi.getUserBalanceEditTransaction(
        usuario.uid,
      );

      final store = StoreProvider.of<AppState>(context);
      store.dispatch(
        UpdateUserAction(
          uid: usuario.uid,
          displayName: store.state.userState.displayName,
          balance: newBalance,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transação editada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        tipoTransacao = null;
        valorController.clear();
        isLoading = false;
      });

      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao editar transação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
