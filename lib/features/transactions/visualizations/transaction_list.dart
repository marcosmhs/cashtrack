import 'package:cashtrack/features/transaction_groups/transaction_group.dart';
import 'package:cashtrack/features/transactions/transaction.dart';
import 'package:cashtrack/features/transactions/transaction_controller.dart';
import 'package:cashtrack/features/transactions/widgets/transaction_card.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fb;
import 'package:flutter/material.dart';
import 'package:teb_package/teb_package.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({
    super.key,
    required User user,
  }) : _user = user;

  final User _user;

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  var _month = DateTime.now().month;
  var _year = DateTime.now().year;
  @override
  Widget build(BuildContext context) {
    var transactionController = TransactionController(user: widget._user);
    var size = MediaQuery.of(context).size;
    return Expanded(
      child: StreamBuilder<fb.QuerySnapshot>(
        stream: transactionController.stream,
        builder: (ctx, snapshot) {
          if ((!snapshot.hasData) || (snapshot.data!.docs.isEmpty)) {
            return TebSilverBarApp(
              context: context,
              title: 'Lançamentos',
              emptyListMessage: 'Nenhum lançamento encontrado',
            );
          } else if (snapshot.hasError) {
            return const Text('Ocorreu um erro!');
          }

          // transforma o retorno do snapshot em uma lista de categorias
          List<Transaction> transactionList = snapshot.data!.docs.map((e) => Transaction.fromDocument(e)).toList();

          transactionList = transactionList.where((t) => t.date!.month == _month && t.date!.year == _year).toList();

          var transactionGroupList = TransactionController(user: widget._user).getGroupList(transactionList);

          return TebSilverBarApp(
            context: context,
            listItens: transactionGroupList,
            listHeaderitemExtent: 60,
            listHeaderArea: Row(
              children: [
                TebText(
                  'Mês Selecionado: $_month / $_year',
                  padding: const EdgeInsets.only(left: 20),
                ),
                const Spacer(),
                SizedBox(
                    width: 160,
                    child: TebButton(
                      label: 'Selecionar mês',
                      padding: const EdgeInsets.only(right: 20),
                      onPressed: () {
                        TebMonthPicker.showMonthYearPickerDialog(
                          context: context,
                          size: Size(size.width * 0.7, size.height * 0.5),
                        ).then((date) {
                          _year = date.year;
                          _month = date.month;
                          setState(() {});
                        });
                      },
                    )),
              ],
            ),
            sliverChildBuilderDelegate: SliverChildBuilderDelegate(
              childCount: transactionGroupList.length,
              (context, index) {
                return ExpansionTile(
                  leading: Icon(TransactionGroup.icon),
                  title: TebText(transactionGroupList[index]),
                  subtitle: TebText(
                    TebUtil.formatedCurrencyValue(
                      value: transactionController.getGroupTotalValue(transactionList, transactionGroupList[index]),
                    ),
                  ),
                  initiallyExpanded: false,
                  children: [
                    Builder(builder: (BuildContext context) {
                      var list = transactionList.where((t) => t.transactionGroupName == transactionGroupList[index]).toList();
                      return ListView.builder(
                        itemCount: list.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => TransactionCard(transaction: list[index]),
                      );
                    }),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
