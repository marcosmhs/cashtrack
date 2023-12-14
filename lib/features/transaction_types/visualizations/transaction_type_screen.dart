import 'package:cashtrack/core/consts.dart';
import 'package:cashtrack/core/routes.dart';
import 'package:cashtrack/features/transaction_types/transaction_type.dart';
import 'package:cashtrack/features/transaction_types/transaction_type_controller.dart';
import 'package:cashtrack/features/transaction_types/widgets/transaction_type_card.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/visual_elements/teb_silverappbar.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class TransactionTypeScreen extends StatefulWidget {
  const TransactionTypeScreen({super.key});

  @override
  State<TransactionTypeScreen> createState() => _TransactionTypeScreenState();
}

class _TransactionTypeScreenState extends State<TransactionTypeScreen> {
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
      title: const TebText('Tipos de Lançamento'),
      responsive: true,
      body: StreamBuilder<QuerySnapshot>(
        stream: TransactionTypeController(user: _user).stream,
        builder: (context, snapshot) {
          if ((!snapshot.hasData) || (snapshot.data!.docs.isEmpty)) {
            return TebSilverBarApp(
              context: context,
              title: 'Tipos de Lançamento',
              emptyListMessage: 'Nenhum tipo de lançamento foi cadastrado',
            );
          } else if (snapshot.hasError) {
            return const Text('Ocorreu um erro!');
          }
          // transforma o retorno do snapshot em uma lista de categorias
          List<TransactionType> transactionTypeList = snapshot.data!.docs.map((e) => TransactionType.fromDocument(e)).toList();

          return TebSilverBarApp(
            context: context,
            listItens: transactionTypeList,
            //listHeaderitemExtent: 120,
            sliverChildBuilderDelegate: SliverChildBuilderDelegate(
              childCount: transactionTypeList.length,
              (BuildContext context, int index) => TransactionTypeCard(
                transactionType: transactionTypeList[index],
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
