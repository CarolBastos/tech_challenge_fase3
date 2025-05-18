import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/app_state.dart';
import 'package:tech_challenge_fase3/screens/components/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:tech_challenge_fase3/domain/models/user_state.dart';
import 'package:tech_challenge_fase3/screens/components/dashboard/new_transaction/upload_transaction.dart';
import 'package:tech_challenge_fase3/provider/transaction_provider.dart';

import 'package:flutter_redux/flutter_redux.dart';

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

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    return StoreConnector<AppState, UserState>(
      converter: (store) => store.state.userState,
      builder: (context, userState) {
        return Form(
          key: _formKey,
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
                  final valorNumerico = double.tryParse(
                    value.replaceAll(',', '.'),
                  );
                  if (valorNumerico == null) {
                    return 'Por favor, insira um valor numérico válido.';
                  }
                  if (valorNumerico <= 0) {
                    return 'O valor deve ser maior que zero.';
                  }
                  if (tipoTransacao == 'Saque' ||
                      tipoTransacao == 'Transferência') {
                    if (valorNumerico > userState.balance) {
                      return 'Saldo insuficiente. Saldo atual: R\$ ${userState.balance.toStringAsFixed(2)}';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              UploadTransaction(
                key: uploadKey,
                onLoadingChange: _updateLoading,
              ),
              SizedBox(height: 20),
              Center(
                child: CustomButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && !isLoading) {
                      try {
                        setState(() => isLoading = true);

                        // Executa a transação primeiro
                        await transactionProvider.addTransaction(
                          context: context,
                          type: tipoTransacao!,
                          amount: valorController.text,
                        );

                        // Se a transação foi bem sucedida, faz o upload
                        await uploadKey.currentState?.uploadToFirebase();
                        uploadKey.currentState?.reset();

                        // Limpa o formulário
                        setState(() {
                          tipoTransacao = null;
                          valorController.clear();
                        });
                      } catch (_) {
                        // O erro já foi tratado no Provider
                      } finally {
                        setState(() => isLoading = false);
                      }
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
      },
    );
  }
}
