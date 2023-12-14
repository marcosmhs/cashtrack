// ignore_for_file: use_build_context_synchronously

import 'package:cashtrack/core/routes.dart';
import 'package:cashtrack/features/transaction_groups/transaction_group.dart';
import 'package:cashtrack/features/transaction_groups/transaction_group_controller.dart';
import 'package:cashtrack/features/transaction_types/transaction_type.dart';
import 'package:cashtrack/features/transaction_types/widgets/transaction_type_display_list.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_switch.dart';
import 'package:teb_package/visual_elements/teb_text.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

class TransactionGroupForm extends StatefulWidget {
  const TransactionGroupForm({super.key});

  @override
  State<TransactionGroupForm> createState() => _TransactionGroupFormState();
}

class _TransactionGroupFormState extends State<TransactionGroupForm> {
  final _formKey = GlobalKey<FormState>();
  var _initializing = true;
  var _user = User();
  var _transactionGroup = TransactionGroup();
  var _savingData = false;

  final TextEditingController _nameController = TextEditingController();

  void _submit() async {
    if (_savingData) return;

    _savingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _savingData = false;
      return;
    }

    var transactionGroupController = TransactionGroupController(user: _user);
    var returnStatus = TebCustomReturn.sucess;

    // salva os dados nas variáveis
    _formKey.currentState?.save();

    try {
      returnStatus = await transactionGroupController.save(transactionGroup: _transactionGroup);

      if (returnStatus.returnType == TebReturnType.error) {
        TebCustomMessage.error(context, message: returnStatus.message);
        return;
      }

      TebCustomMessage.sucess(context, message: 'Dados salvos com sucesso');
      Navigator.of(context).pushReplacementNamed(Routes.transactionTypeScreen, arguments: {'user': _user});
    } finally {
      _savingData = false;
    }
  }

  String? _textEditValidator(String? value, String errorMessage) {
    var finalValue = value ?? '';
    if (finalValue.isEmpty) {
      return errorMessage;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();
      _transactionGroup = arguments['transactionGroup'] ?? TransactionGroup();
      _nameController.text = _transactionGroup.name;
      _initializing = false;
    }

    var size = MediaQuery.of(context).size;

    return TebCustomScaffold(
      title: TebText(_transactionGroup.id.isEmpty ? 'Novo tipo' : 'Alterar dados'),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: size.width <= 650 ? 20 : size.width * 0.3,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TebText(
                'Preencha os dados abaixo',
                textSize: 15,
                padding: EdgeInsets.only(top: 30, bottom: 10),
              ),
              TebTextEdit(
                labelText: 'Nome',
                prefixIcon: TransactionGroup.icon,
                controller: _nameController,
                validator: (value) => _textEditValidator(value, 'Por favor, informe o nome do agrupamento'),
                onSave: (value) => _transactionGroup.name = value ?? '',
              ),
              TransactionTypePicker.button(
                context: context,
                transactionType: _transactionGroup.transactionType.id.isNotEmpty
                    ? _transactionGroup.transactionType
                    : TransactionType(id: _transactionGroup.transactionTypeId, name: _transactionGroup.transactionTypeName),
                user: _user,
                onSelected: (selected) => setState(() => _transactionGroup.setTransactionType(selected)),
              ),
              TebSwitch(
                context: context,
                value: _transactionGroup.active,
                title: 'Ativo',
                onChanged: (value) {
                  if (value != null) setState(() => _transactionGroup.active = value);
                },
              ),
              TebButtonsLine(
                padding: const EdgeInsets.only(top: 20),
                mainAxisAlignment: MainAxisAlignment.end,
                widthSpaceBetweenButtons: 20,
                buttons: [
                  TebButton(
                    buttonType: TebButtonType.outlinedButton,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const TebText('Cancelar', textSize: 15),
                  ),
                  TebButton(
                    buttonType: TebButtonType.elevatedButton,
                    onPressed: () => _submit(),
                    child: const TebText('Salvar', textSize: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
