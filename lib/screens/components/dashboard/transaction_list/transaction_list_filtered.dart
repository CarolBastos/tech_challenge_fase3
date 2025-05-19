import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tech_challenge_fase3/provider/transaction_provider.dart';
import 'package:tech_challenge_fase3/screens/components/dashboard/new_transaction/edit_transaction.dart';
import 'package:tech_challenge_fase3/domain/models/transaction_model.dart';

class TransactionListFiltered extends StatelessWidget {
  final DateTime? data;
  final double? valor;
  final String? tipoTransferencia;

  const TransactionListFiltered({
    super.key,
    this.data,
    this.valor,
    this.tipoTransferencia,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final transacoesFiltradas = _filtrarTransacoes(provider.transactions);

    if (transacoesFiltradas.isEmpty) {
      return const Center(child: Text("Nenhuma transação encontrada."));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transacoesFiltradas.length,
      itemBuilder: (context, index) {
        final transacao = transacoesFiltradas[index];
        return GestureDetector(
          onTap: () => _openEditTransactionDialog(context, transacao),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(
                transacao.tipo,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Valor: R\$ ${transacao.valor.toStringAsFixed(2)}\n'
                'Data: ${DateFormat('dd/MM/yyyy').format(transacao.data)}',
              ),
              trailing: const Icon(Icons.edit),
            ),
          ),
        );
      },
    );
  }

  List<TransactionModel> _filtrarTransacoes(List<TransactionModel> transacoes) {
    return transacoes.where((transacao) {
      final matchesData = data == null ||
          (transacao.data.year == data!.year &&
              transacao.data.month == data!.month &&
              transacao.data.day == data!.day);

      final matchesValor = valor == null || transacao.valor == valor;
      final matchesTipo = tipoTransferencia == null || transacao.tipo == tipoTransferencia;

      return matchesData && matchesValor && matchesTipo;
    }).toList();
  }

  void _openEditTransactionDialog(BuildContext context, TransactionModel transacao) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: EditTransaction(
          data: transacao.data,
          tipoTransacao: transacao.tipo,
          valor: transacao.valor.toString(),
        ),
      ),
    );
  }
}
