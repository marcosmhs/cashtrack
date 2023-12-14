// ignore: depend_on_referenced_packages
// ignore_for_file: use_build_context_synchronously

import 'package:cashtrack/core/consts.dart';
import 'package:cashtrack/core/routes.dart';
import 'package:cashtrack/features/transaction_groups/transaction_group.dart';
import 'package:cashtrack/features/transaction_groups/transaction_group_controller.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/messaging/teb_custom_dialog.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class TransactionGroupCard extends StatefulWidget {
  final TransactionGroup transactionGroup;
  final User user;
  final ScreenMode screenMode;
  final bool cropped;
  final double elevation;

  const TransactionGroupCard({
    Key? key,
    required this.transactionGroup,
    required this.user,
    this.screenMode = ScreenMode.screenOptions,
    this.cropped = false,
    this.elevation = 1,
  }) : super(key: key);

  Widget _structure({Widget? leading, Widget? title, Widget? subtitle, Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      elevation: elevation,
      child: ListTile(
        visualDensity: cropped ? const VisualDensity(horizontal: 0, vertical: -4) : null,
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
      ),
    );
  }

  Widget emptyCard(BuildContext context) {
    return _structure(
      leading: Icon(TransactionGroup.icon, size: 30),
      title: const Text('Clique para selecionar'),
    );
  }

  @override
  State<TransactionGroupCard> createState() => _TransactionGroupCardState();
}

class _TransactionGroupCardState extends State<TransactionGroupCard> {
  void _delete({required User user}) async {
    var retorno = await TransactionGroupController(user: user).delete(
      transactionGroup: widget.transactionGroup,
    );

    if (retorno.returnType == TebReturnType.sucess) {
      TebCustomMessage(
        context: context,
        messageText: 'Dados salvos com sucesso',
        messageType: TebMessageType.sucess,
      );
    }
    // se houve um erro no login ou no cadastro exibe o erro
    if (retorno.returnType == TebReturnType.error) {
      TebCustomMessage(
        context: context,
        messageText: retorno.message,
        messageType: TebMessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget._structure(
      leading: Icon(
        TransactionGroup.icon,
        color: widget.transactionGroup.active ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
        size: 30,
      ),
      title: TebText(widget.transactionGroup.name),
      subtitle: TebText(widget.transactionGroup.transactionTypeName),
      trailing: widget.screenMode == ScreenMode.list
          ? null
          : widget.screenMode == ScreenMode.showItem
              ? null
              : SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      // Edit Button
                      IconButton(
                        icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          Routes.transactionGroupForm,
                          arguments: {'user': widget.user, 'transactionGroup': widget.transactionGroup},
                        ),
                      ),
                      // delete buttom
                      IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.primary),
                        onPressed: () async {
                          final deletedConfirmed = await TebCustomDialog(context: context).confirmationDialog(
                            message: 'Confirma a exclusão?',
                          );

                          if (deletedConfirmed ?? false) {
                            _delete(user: widget.user);
                          } else {
                            TebCustomMessage(
                              context: context,
                              messageType: TebMessageType.info,
                              messageText: 'Exclusão cancelada',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
