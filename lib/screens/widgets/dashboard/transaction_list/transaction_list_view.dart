import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/models/transaction_model.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:tech_challenge_fase3/screens/widgets/dashboard/transaction_list/convertMonthToPortuguese.dart';

class TransactionListView extends StatelessWidget {
  final List<TransactionModel> transactions;

  const TransactionListView({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(child: Text("Nenhuma transação encontrada."));
    }

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extrato',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 21),
            ...transactions.map((transaction) {
              DateTime date = transaction.data;
              String monthInEnglish = DateFormat('MMMM').format(date);
              String monthPortuguese = convertMonthToPortuguese(monthInEnglish);
              String formattedDate = DateFormat('dd/MM/yyyy').format(date);
              String formattedValue = NumberFormat.currency(
                locale: 'pt_BR',
                symbol: 'R\$',
              ).format(transaction.valor);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    monthPortuguese,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      transaction.tipo,
                      style: TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      formattedValue,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    trailing: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color:
                            transaction.valor < 0
                                ? Colors.red
                                : AppColors.greyPlaceholder,
                      ),
                    ),
                  ),
                  Divider(color: Colors.grey[300], thickness: 1, height: 10),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
