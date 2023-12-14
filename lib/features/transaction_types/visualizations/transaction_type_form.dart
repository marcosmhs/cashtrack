// ignore_for_file: use_build_context_synchronously

import 'package:cashtrack/core/routes.dart';
import 'package:cashtrack/features/transaction_types/transaction_type.dart';
import 'package:cashtrack/features/transaction_types/transaction_type_controller.dart';
import 'package:cashtrack/features/transactions/widgets/transaction_operation_widget.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:flutter/material.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_switch.dart';
import 'package:teb_package/visual_elements/teb_text.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

class TransactionTypeForm extends StatefulWidget {
  const TransactionTypeForm({super.key});

  @override
  State<TransactionTypeForm> createState() => _TransactionTypeFormState();
}

class _TransactionTypeFormState extends State<TransactionTypeForm> {
  final _formKey = GlobalKey<FormState>();
  var _initializing = true;
  var _user = User();
  var _transactionType = TransactionType();
  var _savingData = false;

  final TextEditingController _nameController = TextEditingController();

  void _submit() async {
    if (_savingData) return;

    _savingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _savingData = false;
      return;
    }

    var transactionTypeController = TransactionTypeController(user: _user);
    var returnStatus = TebCustomReturn.sucess;

    // salva os dados nas variáveis
    _formKey.currentState?.save();

    try {
      returnStatus = await transactionTypeController.save(transactionType: _transactionType);

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
      _transactionType = arguments['transactionType'] ?? TransactionType();
      _nameController.text = _transactionType.name;
      _initializing = false;
    }

    var size = MediaQuery.of(context).size;

    return TebCustomScaffold(
      title: TebText(_transactionType.id.isEmpty ? 'Novo tipo' : 'Alterar dados'),
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
                prefixIcon: TransactionType.icon,
                controller: _nameController,
                validator: (value) => _textEditValidator(value, 'Por favor, informe seu nome'),
                onSave: (value) => _transactionType.name = value ?? '',
              ),
              TebSwitch(
                context: context,
                value: _transactionType.active,
                title: 'Ativo',
                onChanged: (value) {
                  if (value != null) setState(() => _transactionType.active = value);
                },
              ),
              TransactionOperationWidget(
                operation: _transactionType.operation,
                onSelect: (operation) => setState(() => _transactionType.operation = operation),
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
