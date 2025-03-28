import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_fase3/models/user_model.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/new_transaction/upload_transaction.dart';

class NewTransaction extends StatefulWidget {
  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  String? tipoTransacao;
  TextEditingController valorController = TextEditingController();
  List<String> tiposTransacao = ['Depósito', 'Saque', 'Transferência'];
  bool isLoading = false;
  final GlobalKey<UploadTransactionState> uploadKey =
      GlobalKey<UploadTransactionState>();

  void _updateLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  final _formKey = GlobalKey<FormState>(); // Chave para o formulário

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return Form(
      key: _formKey, // Associa o formulário à chave
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nova Transação',
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
              // Verifica se o valor é um número válido
              final valorNumerico = double.tryParse(value.replaceAll(',', '.'));
              if (valorNumerico == null) {
                return 'Por favor, insira um valor numérico válido.';
              }
              if (valorNumerico <= 0) {
                return 'O valor deve ser maior que zero.';
              }
              // Verifica se o valor excede o saldo disponível para saque ou transferência
              if (tipoTransacao == 'Saque' ||
                  tipoTransacao == 'Transferência') {
                if (valorNumerico > userModel.balance) {
                  return 'Saldo insuficiente. Saldo atual: R\$ ${userModel.balance.toStringAsFixed(2)}';
                }
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          UploadTransaction(key: uploadKey, onLoadingChange: _updateLoading),
          SizedBox(height: 20),
          Center(
            child: CustomButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  isLoading ? null : concluirTransacao();
                }
              },
              text: 'Concluir a transação',
              backgroundColor: AppColors.darkTeal,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> concluirTransacao() async {
    User? usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário não autenticado.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (tipoTransacao == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecione o tipo de transação.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (valorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, insira o valor da transação.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    double valor =
        double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0;
    if (valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('O valor da transação deve ser maior que zero.'),
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

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuario.uid)
              .get();

      double balanceCurrent = (userDoc['saldo'] ?? 0).toDouble();
      double newBalance = calculateNewBalance(
        balanceCurrent,
        valor,
        tipoTransacao!,
      );

      if (newBalance < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saldo insuficiente para esta transação.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('transacoes').add({
        'user_id': usuario.uid,
        'tipo': tipoTransacao,
        'valor': valorController.text,
        'data': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .update({'saldo': newBalance});

      final userModel = Provider.of<UserModel>(context, listen: false);
      userModel.updateUser(userModel.displayName, newBalance);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transação concluída com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      await uploadKey.currentState?.uploadToFirebase();

      uploadKey.currentState?.reset();

      setState(() {
        tipoTransacao = null;
        valorController.clear();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar transação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool isNegativeTransaction(String type) {
    return type == 'Saque' || type == 'Transferência';
  }

  double calculateNewBalance(
    double currentBalance,
    double amount,
    String type,
  ) {
    return isNegativeTransaction(type)
        ? currentBalance - amount
        : currentBalance + amount;
  }
}
