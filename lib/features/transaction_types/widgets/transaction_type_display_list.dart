// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:cashtrack/core/consts.dart';
import 'package:cashtrack/features/transaction_types/transaction_type.dart';
import 'package:cashtrack/features/transaction_types/transaction_type_controller.dart';
import 'package:cashtrack/features/transaction_types/widgets/transaction_type_card.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/teb_package.dart';

class TransactionTypePicker {

  static Widget button({
    required BuildContext context,
    required TransactionType transactionType,
    required User user,
    required void Function(TransactionType selected) onSelected,
  }) {
    return GestureDetector(
      onTap: () => TransactionTypePicker.open(
        picked: transactionType,
        context: context,
        user: user,
      ).then((value) => onSelected(value)),
      child: transactionType.id.isEmpty
          ? TransactionTypeCard(transactionType: transactionType, user: user).emptyCard(context)
          : TransactionTypeCard(
              transactionType: transactionType,
              user: user,
              screenMode: ScreenMode.showItem,
              cropped: false,
              elevation: 0,
            ),
    );
  }


  static Future<TransactionType> open({
    required TransactionType picked,
    required BuildContext context,
    required User user,
    Size? size,
  }) async {
    var selected = TransactionType();
    var current = picked;

    var listItems = await TransactionTypeController(user: user).getList;
    listItems = listItems.where((g) => g.active == true).toList();

    var localSize = size ?? MediaQuery.of(context).size;

    await showDialog<TransactionType>(
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
                      child: TransactionTypeCard(
                        transactionType: listItems[index],
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
