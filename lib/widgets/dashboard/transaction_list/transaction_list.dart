import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/provider/transaction_provider.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/transaction_list/convertMonthToPortuguese.dart';
import 'package:tech_challenge_fase3/widgets/dashboard/transaction_list/transaction_list_view.dart';

class TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        if (transactionProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return TransactionListView(
          transactions: transactionProvider.transactions,
        );
      },
    );
  }
}
