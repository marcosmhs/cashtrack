// ignore_for_file: use_build_context_synchronously

import 'package:cashtrack/features/transaction_groups/widgets/transaction_group_display_list.dart';
import 'package:cashtrack/features/transaction_types/transaction_type_controller.dart';
import 'package:cashtrack/features/transaction_types/widgets/transaction_type_display_list.dart';
import 'package:cashtrack/features/transactions/transaction.dart';
import 'package:cashtrack/features/transactions/transaction_controller.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_package/teb_package.dart';

class TransactionForm extends StatefulWidget {
  final User? user;
  final bool fastForm;
  const TransactionForm({super.key, this.user, this.fastForm = false});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  var _initializing = true;
  var _savingData = false;
  var _user = User();

  var _transaction = Transaction();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _submit() async {
    if (_savingData) return;

    _savingData = true;
    if (!(_formKey.currentState?.validate() ?? true)) {
      _savingData = false;
      return;
    }

    if (_transaction.transactionGroupId.isEmpty) {
      TebCustomDialog(context: context).errorMessage(message: 'Informe o agrupamento de lançamento');
      _savingData = false;
      return;
    }

    if (_transaction.transactionTypeId.isEmpty) {
      TebCustomDialog(context: context).errorMessage(message: 'Informe o tipo de lançamento');
      _savingData = false;
      return;
    }

    if (!widget.fastForm && _transaction.date == null) {
      TebCustomDialog(context: context).errorMessage(message: 'Informe a data do lançamento');
      _savingData = false;
      return;
    }

    var transactionController = TransactionController(user: _user);
    var returnStatus = TebCustomReturn.sucess;

    // salva os dados nas variáveis
    _formKey.currentState?.save();

    try {
      if (widget.fastForm) _transaction.date = DateTime.now();
      returnStatus = await transactionController.save(transaction: _transaction);

      if (returnStatus.returnType == TebReturnType.error) {
        TebCustomMessage.error(context, message: returnStatus.message);
        return;
      }

      TebCustomMessage.sucess(context, message: 'Dados salvos com sucesso');
      if (widget.fastForm) {
        setState(() => _newTransaction());
      } else {
        Navigator.of(context).pop();
      }
    } finally {
      _savingData = false;
    }
  }

  void _newTransaction() {
    _transaction = Transaction();
    _valueController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
      _user = arguments['user'] ?? User();
      _transaction = arguments['transaction'] ?? Transaction();

      if (widget.user != null) _user = User.fromMap(map: widget.user!.toMap);
      _valueController.text = _transaction.value == 0 ? '' : _transaction.value.toString();
      _descriptionController.text = _transaction.description;
      _initializing = false;
    }

    var size = MediaQuery.of(context).size;

    var formWidget = Card(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // descrição
            TebTextEdit(
              labelText: 'Descrição',
              controller: _descriptionController,
              maxLines: widget.fastForm ? 1 : 3,
              onSave: (value) => _transaction.description = value ?? '',
            ),
            // grupo
            TransactionGroupPicker.transactionGroupButton(
              context: context,
              transactionGroup: _transaction.transactionGroup,
              user: _user,
              onSelected: (selected) {
                var transactionGroup = selected;

                TransactionTypeController(user: _user).getTransactionTypeById(transactionGroup.transactionTypeId).then((value) {
                  transactionGroup.transactionType = value;
                  setState(
                    () {
                      _transaction.setTransactionGroup(transactionGroup);
                      _transaction.setTransactionType(transactionGroup.transactionType);
                    },
                  );
                });
              },
            ),
            // tipo de lançamento, valor e botões para salvar
            if (widget.fastForm)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: size.width * 0.58,
                    child: TransactionTypePicker.button(
                      context: context,
                      transactionType: _transaction.transactionType,
                      user: _user,
                      onSelected: (selected) => setState(() => _transaction.setTransactionType(selected)),
                    ),
                  ),
                  TebTextEdit(
                    labelText: 'Valor',
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    onSave: (value) => _transaction.value = double.tryParse(value ?? '') ?? 0,
                    validator: (value) {
                      if (value != null && double.tryParse(value) == null) return 'Inform um valor válido';
                      return null;
                    },
                    width: size.width * 0.22,
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => _submit(),
                    child: Container(
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                      width: size.width * 0.1,
                      height: 50,
                      child: const Icon(FontAwesomeIcons.floppyDisk, size: 35),
                    ),
                  ),
                ],
              ),
            // tipo de lançamento (formulário normal)
            if (!widget.fastForm)
              TransactionTypePicker.button(
                context: context,
                transactionType: _transaction.transactionType,
                user: _user,
                onSelected: (selected) => setState(() => _transaction.setTransactionType(selected)),
              ),
            // valor e data
            if (!widget.fastForm)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: size.width * 0.6,
                    child: TebDateTimeSelector(context: context, onSelected: (date) => _transaction.date = date),
                  ),
                  const Spacer(),
                  TebTextEdit(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    labelText: 'Valor',
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    onSave: (value) => _transaction.value = double.tryParse(value ?? '') ?? 0,
                    validator: (value) {
                      if (value != null && double.tryParse(value) == null) return 'Inform um valor válido';
                      return null;
                    },
                    width: size.width * 0.32,
                  ),
                ],
              ),
            // lançamento válido
            if (!widget.fastForm)
              TebSwitch(
                context: context,
                value: _transaction.active,
                title: 'Lançamento válido (ativo)',
                onChanged: (value) => setState(() => _transaction.active = value ?? true),
              ),
            // recorrencia
            if (!widget.fastForm)
              TebSwitch(
                context: context,
                value: _transaction.recurring,
                title: 'Lançamento recorrente',
                onChanged: (value) => setState(() => _transaction.recurring = value ?? true),
              ),

            if (!widget.fastForm)
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
    );

    if (widget.fastForm) {
      return formWidget;
    } else {
      return TebCustomScaffold(
        showAppBar: !widget.fastForm,
        title: TebText(_transaction.id.isEmpty ? 'Novo Lançamento' : 'Alterar Lancamento'),
        body: Padding(
          padding: EdgeInsets.all(widget.fastForm ? 0 : 10),
          child: formWidget,
        ),
      );
    }
  }
}
