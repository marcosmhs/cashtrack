import 'package:cashtrack/core/routes.dart';
import 'package:cashtrack/core/visualizations/main_menu.dart';
import 'package:cashtrack/features/transaction_groups/transaction_group.dart';
import 'package:cashtrack/features/transaction_types/transaction_type.dart';
import 'package:cashtrack/features/transactions/transaction.dart';
import 'package:cashtrack/features/transactions/visualizations/transaction_form.dart';
import 'package:cashtrack/features/transactions/visualizations/transaction_list.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:cashtrack/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  final Wallet? wallet;

  const MainScreen({super.key, this.user, this.wallet});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _initializing = true;
  var _user = User();
  var _wallet = Wallet();
  List<TransactionType> transactionTypeList = [];
  List<TransactionGroup> transactionGroupList = [];

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();
      _wallet = arguments['wallet'] ?? Wallet();

      if (widget.user != null && widget.user!.id.isNotEmpty) {
        _user = widget.user!;
        _wallet = widget.wallet!;
      }
      _initializing = false;
    }

    //var size = MediaQuery.of(context).size;

    return TebCustomScaffold(
      title: TebText(
        _wallet.name,
        textColor: Theme.of(context).colorScheme.primary,
      ),
      showAppBar: true,
      showAppDrawer: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(Routes.transactionForm, arguments: {'user': _user}),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: Icon(FontAwesomeIcons.plus, color: Theme.of(context).primaryColor, size: 30),
      ),
      drawer: Drawer(child: MainMenu(user: _user, wallet: _wallet)),
      body: Column(
        children: [
          ExpansionTile(
            leading: Icon(Transaction.icon),
            title: const TebText('Lançamento rápido'),
            initiallyExpanded: true,
            children: [
              Builder(builder: (BuildContext context) {
                return TransactionForm(user: _user, fastForm: true);
              }),
            ],
          ),
          TransactionList(user: _user),
        ],
      ),
    );
  }
}
