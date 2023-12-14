import 'package:cashtrack/core/consts.dart';
import 'package:cashtrack/core/routes.dart';
import 'package:cashtrack/features/transaction_groups/transaction_group.dart';
import 'package:cashtrack/features/transaction_groups/transaction_group_controller.dart';
import 'package:cashtrack/features/transaction_groups/widgets/transaction_group_card.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/visual_elements/teb_silverappbar.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class TransactionGroupScreen extends StatefulWidget {
  const TransactionGroupScreen({super.key});

  @override
  State<TransactionGroupScreen> createState() => _TransactionGroupScreenState();
}

class _TransactionGroupScreenState extends State<TransactionGroupScreen> {
  var _initializing = true;
  var _user = User();

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();

      _initializing = false;
    }
    return TebCustomScaffold(
      title: const TebText('Agrupamentos de lançamento'),
      responsive: true,
      body: StreamBuilder<QuerySnapshot>(
        stream: TransactionGroupController(user: _user).stream,
        builder: (context, snapshot) {
          if ((!snapshot.hasData) || (snapshot.data!.docs.isEmpty)) {
            return TebSilverBarApp(
              context: context,
              title: 'Grupos de Lançamento',
              emptyListMessage: 'Nenhum tipo de lançamento foi cadastrado',
            );
          } else if (snapshot.hasError) {
            return const Text('Ocorreu um erro!');
          }
          // transforma o retorno do snapshot em uma lista de categorias
          List<TransactionGroup> transactionTypeList = snapshot.data!.docs.map((e) => TransactionGroup.fromDocument(e)).toList();

          return TebSilverBarApp(
            context: context,
            listItens: transactionTypeList,
            //listHeaderitemExtent: 120,
            sliverChildBuilderDelegate: SliverChildBuilderDelegate(
              childCount: transactionTypeList.length,
              (BuildContext context, int index) => TransactionGroupCard(
                transactionGroup: transactionTypeList[index],
                screenMode: ScreenMode.screenOptions,
                user: _user,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(Routes.transactionTypeForm, arguments: {'user': _user}),
        child: const Icon(Icons.add),
      ),
    );
  }
}
