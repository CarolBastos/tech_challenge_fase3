import 'package:flutter/material.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/screens/components/dashboard/new_transaction/new_transaction.dart';
import 'package:visibility_detector/visibility_detector.dart';

class TransactionCard extends StatefulWidget {
  const TransactionCard({super.key});

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('transaction-card'),
      onVisibilityChanged: (info) {
        if (!_isVisible && info.visibleFraction > 0) {
          setState(() {
            _isVisible = true;
          });
        }
      },
      child: Card(
        elevation: 0,
        color: AppColors.gray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isVisible ? const NewTransaction() : const SizedBox(height: 200),
        ),
      ),
    );
  }
}
