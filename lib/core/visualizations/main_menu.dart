import 'package:cashtrack/core/local_data_controller.dart';
import 'package:cashtrack/core/routes.dart';
import 'package:cashtrack/features/transaction_groups/transaction_group.dart';
import 'package:cashtrack/features/transaction_types/transaction_type.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:cashtrack/features/users/user_controller.dart';
import 'package:cashtrack/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_package/teb_package.dart';

class MainMenu extends StatefulWidget {
  final User user;
  final Wallet wallet;

  const MainMenu({super.key, required this.user, required this.wallet});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  var _info = TebUtil.packageInfo;
  var _initializing = true;

  Widget _menuHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      width: double.maxFinite,
      padding: const EdgeInsets.only(left: 10, top: 20, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TebText(
            widget.user.name,
            textSize: 20,
            textWeight: FontWeight.bold,
          ),
          TebText(
            widget.wallet.name,
            textSize: 15,
          ),
        ],
      ),
    );
  }

  Widget _menuOption({
    required BuildContext context,
    required IconData icon,
    required String text,
    String route = '',
    Object? args,
    Function()? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(text),
          onTap: route == ''
              ? onTap
              : () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, route, arguments: args);
                },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      TebUtil.version.then((info) => setState(() => _info = info));
      _initializing = false;
    }

    return Column(
      children: [
        _menuHeader(context),
        _menuOption(
          context: context,
          icon: FontAwesomeIcons.user,
          text: 'Meus dados',
          route: Routes.userForm,
          args: {'user': widget.user, 'wallet': widget.wallet},
        ),
        _menuOption(
          context: context,
          icon: TransactionType.icon,
          text: 'Tipos de lançamento',
          route: Routes.transactionTypeScreen,
          args: {'user': widget.user, 'wallet': widget.wallet},
        ),
        _menuOption(
          context: context,
          icon: TransactionGroup.icon,
          text: 'Agrupamentos de lançamentos',
          route: Routes.transactionGroupScreen,
          args: {'user': widget.user, 'wallet': widget.wallet},
        ),
        Expanded(child: Text("v${_info.version}.${_info.buildNumber}")),
        _menuOption(
          context: context,
          icon: FontAwesomeIcons.doorClosed,
          text: 'Sair',
          onTap: () {
            UserController().clearCurrentUser();
            LocalDataController().clearWalletData();
            Navigator.of(context).popAndPushNamed(Routes.landingScreen);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
