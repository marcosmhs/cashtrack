import 'package:cashtrack/features/transactions/transaction.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/teb_package.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TebText(transaction.description.isNotEmpty ? transaction.description : 'Lançamento rápido (sem descrição)'),
      subtitle: TebText(TebUtil.dateTimeFormat(date: transaction.date!)),
      trailing: TebText(
        transaction.formatedValue(),
        textColor: transaction.transactionOperationFontColor,
      ),
    );
  }
}
