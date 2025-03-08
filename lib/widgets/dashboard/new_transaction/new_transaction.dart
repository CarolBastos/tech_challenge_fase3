import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/widgets/custom_button.dart';

class NewTransaction extends StatefulWidget {
  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  String? tipoTransacao;
  TextEditingController valorController = TextEditingController();
  List<String> tiposTransacao = ['Depósito', 'Saque', 'Transferência'];

  void concluirTransacao() {
    if (tipoTransacao != null && valorController.text.isNotEmpty) {
      print('Transação concluída');
      print('Tipo: $tipoTransacao');
      print('Valor: ${valorController.text}');
      setState(() {
        tipoTransacao = null;
        valorController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '00,00',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: AppColors.white,
          ),
          validator: (value) {
            if (value!.isEmpty) {
              return 'Por favor, insira um valor';
            }
            return null;
          },
        ),
        SizedBox(height: 20),
        Center(
          child: CustomButton(
            onPressed: concluirTransacao,
            text: 'Concluir a transação',
            backgroundColor: AppColors.darkTeal,
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
