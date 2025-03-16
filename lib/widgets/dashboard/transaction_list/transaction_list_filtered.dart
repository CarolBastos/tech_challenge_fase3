import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'convertMonthToPortuguese.dart';

class TransactionListFiltered extends StatelessWidget {
  final DateTime? data;
  final double? valor;
  final String? tipoTransferencia;

  TransactionListFiltered({this.data, this.valor, this.tipoTransferencia});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('transacoes')
              .where(
                'user_id',
                isEqualTo: FirebaseAuth.instance.currentUser?.uid,
              )
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Nenhuma transação encontrada'));
        }

        var transacoes = snapshot.data!.docs;
        var format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

        // Filtra as transações com base nos parâmetros fornecidos
        var transacoesFiltradas =
            transacoes.where((transacao) {
              var dataTransacao = transacao['data'];
              if (dataTransacao == null || dataTransacao is! Timestamp) {
                return false;
              }

              DateTime dataTransacaoDate = dataTransacao.toDate();
              double transacaoValor =
                  transacao['valor'] is double
                      ? transacao['valor']
                      : double.tryParse(transacao['valor'].toString()) ?? 0.0;
              String transacaoTipo = transacao['tipo'];

              bool matchesData =
                  data == null ||
                  (dataTransacaoDate.year == data!.year &&
                      dataTransacaoDate.month == data!.month &&
                      dataTransacaoDate.day == data!.day);

              bool matchesValor = valor == null || transacaoValor == valor;
              bool matchesTipo =
                  tipoTransferencia == null ||
                  transacaoTipo == tipoTransferencia;

              return matchesData && matchesValor && matchesTipo;
            }).toList();

        if (transacoesFiltradas.isEmpty) {
          return Center(
            child: Text(
              'Nenhuma transação encontrada com os filtros aplicados',
            ),
          );
        }

        return Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Extrato',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: transacoesFiltradas.length,
                  itemBuilder: (context, index) {
                    var transacao = transacoesFiltradas[index];

                    var dataTransacao = transacao['data'];
                    if (dataTransacao == null || dataTransacao is! Timestamp) {
                      return ListTile(title: Text('Erro: Data inválida'));
                    }

                    DateTime data = dataTransacao.toDate();
                    String dataFormatada = DateFormat(
                      'dd/MM/yyyy',
                    ).format(data);
                    var month = DateFormat('MMMM').format(data);
                    var monthInPortuguese = convertMonthToPortuguese(month);

                    double valor =
                        transacao['valor'] is double
                            ? transacao['valor']
                            : double.tryParse(transacao['valor'].toString()) ??
                                0.0;

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$monthInPortuguese',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text(
                                '${transacao['tipo']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Text(
                                '${format.format(valor)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$dataFormatada',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.greyPlaceholder,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
