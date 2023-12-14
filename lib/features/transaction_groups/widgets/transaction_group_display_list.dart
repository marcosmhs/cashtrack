// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:cashtrack/core/consts.dart';
import 'package:cashtrack/features/transaction_groups/transaction_group.dart';
import 'package:cashtrack/features/transaction_groups/transaction_group_controller.dart';
import 'package:cashtrack/features/transaction_groups/widgets/transaction_group_card.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/teb_package.dart';

class TransactionGroupPicker {
  static Widget transactionGroupButton({
    required BuildContext context,
    required TransactionGroup transactionGroup,
    required User user,
    required void Function(TransactionGroup selected) onSelected,
  }) {
    return GestureDetector(
      onTap: () => TransactionGroupPicker.open(
        picked: transactionGroup,
        context: context,
        user: user,
      ).then((value) => onSelected(value)),
      child: transactionGroup.id.isEmpty
          ? TransactionGroupCard(transactionGroup: transactionGroup, user: user).emptyCard(context)
          : TransactionGroupCard(
              transactionGroup: transactionGroup,
              user: user,
              screenMode: ScreenMode.showItem,
              cropped: false,
              elevation: 0,
            ),
    );
  }

  static Future<TransactionGroup> open({
    required TransactionGroup picked,
    required BuildContext context,
    required User user,
    Size? size,
  }) async {
    var selected = TransactionGroup();
    var current = picked;

    var listItems = await TransactionGroupController(user: user).getList;

    listItems = listItems.where((g) => g.active == true).toList();

    var localSize = size ?? MediaQuery.of(context).size;

    await showDialog<TransactionGroup>(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget list = Container(
              width: localSize.width,
              height: localSize.height * 0.5,
              padding: const EdgeInsets.all(5),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: listItems.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => selected = listItems[index]);
                        Navigator.pop(context, selected);
                      },
                      child: TransactionGroupCard(
                        transactionGroup: listItems[index],
                        user: user,
                        screenMode: ScreenMode.list,
                      ),
                    );
                  },
                ),
              ),
            );

            return TebCustomModalDialog(
              child: SizedBox(
                width: localSize.width * 0.7,
                height: localSize.height * 0.6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TebText(
                      'Selecione o agrupamento',
                      textSize: 20,
                      textWeight: FontWeight.bold,
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    list,
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // original color
                          const Spacer(),
                          TebButton(
                            label: 'Cancelar',
                            buttonType: TebButtonType.outlinedButton,
                            onPressed: () => Navigator.pop(context, current),
                            padding: const EdgeInsets.only(right: 10),
                          ),
                          TebButton(
                            label: 'Selecionar',
                            onPressed: () => Navigator.pop(context, selected),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    return selected;
  }
}
