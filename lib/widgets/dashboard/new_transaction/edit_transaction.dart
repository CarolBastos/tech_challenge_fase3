import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_fase3/models/user_model.dart';

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
  final _formKey = GlobalKey<FormState>(); // Chave para o formulário

  @override
  void initState() {
    super.initState();
    tipoTransacao = widget.tipoTransacao;
    valorController = TextEditingController(text: widget.valor);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey, // Associa o formulário à chave
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
              // Verifica se o valor é um número válido
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

      // Consulta a transação com base no campo `data` (Timestamp)
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('transacoes')
              .where('user_id', isEqualTo: usuario.uid)
              .where('data', isEqualTo: widget.data)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transação não encontrada.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Recupera o documento da transação
      DocumentSnapshot transactionDoc = querySnapshot.docs.first;
      double valorAntigo =
          double.tryParse(transactionDoc['valor'].replaceAll(',', '.')) ?? 0;

      // Atualiza a transação no Firestore
      await transactionDoc.reference.update({
        'tipo': tipoTransacao,
        'valor': valorController.text,
      });

      // Atualiza o saldo do usuário
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuario.uid)
              .get();

      double balanceCurrent = (userDoc['saldo'] ?? 0).toDouble();

      // Reverte o valor antigo e aplica o novo valor
      double newBalance =
          balanceCurrent + valorAntigo; // Reverte o valor antigo
      newBalance = calculateNewBalance(
        newBalance,
        valor,
        tipoTransacao!,
      ); // Aplica o novo valor

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(usuario.uid)
          .update({'saldo': newBalance});

      final userModel = Provider.of<UserModel>(context, listen: false);
      userModel.updateUser(userModel.displayName, newBalance);

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

      Navigator.of(context).pop(); // Fecha o diálogo ou a tela de edição
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
