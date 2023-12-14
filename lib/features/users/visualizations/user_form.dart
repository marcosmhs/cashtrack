// ignore_for_file: use_build_context_synchronously

import 'package:cashtrack/core/routes.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:cashtrack/features/users/user_controller.dart';
import 'package:cashtrack/features/wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_package/messaging/teb_custom_dialog.dart';
import 'package:teb_package/messaging/teb_custom_message.dart';
import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_util.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_text.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _actualPasswordController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();
  final TextEditingController _walletInvitationCodeController = TextEditingController();
  final TextEditingController _walletNameController = TextEditingController();

  var _initializing = true;
  var _user = User();
  var _wallet = Wallet();
  var _savingData = false;

  void _submit() async {
    if (_savingData) return;

    _savingData = true;

    if (!(_formKey.currentState?.validate() ?? true)) {
      _savingData = false;
      return;
    }

    var userController = UserController();
    var returnStatus = TebCustomReturn.sucess;

    // salva os dados nas variáveis
    _formKey.currentState?.save();

    try {
      returnStatus = await userController.save(user: _user, wallet: _wallet);

      if (returnStatus.returnType == TebReturnType.error) {
        TebCustomMessage.error(context, message: returnStatus.message);
        return;
      }

      TebCustomMessage.sucess(context, message: 'Dados salvos com sucesso');
      Navigator.of(context).pushReplacementNamed(Routes.mainScreen, arguments: {'user': _user});
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
      _wallet = arguments['wallet'] ?? Wallet();
      _initializing = false;

      if (_user.id.isNotEmpty) {
        _nameController.text = _user.name;
        _emailController.text = _user.email;
      }

      _walletInvitationCodeController.text = _wallet.invitationCode;
      if (_wallet.id.isNotEmpty && _wallet.ownerUserId == _user.id) {
        _walletNameController.text = _wallet.name;
      }
    }

    var size = MediaQuery.of(context).size;

    return TebCustomScaffold(
      title: TebText(_user.id.isEmpty ? 'Novo usuário' : 'Alterar seus dados'),
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
                textSize: 20,
                padding: EdgeInsets.only(top: 30, bottom: 10),
              ),
              // nome
              TebTextEdit(
                labelText: 'Nome',
                prefixIcon: FontAwesomeIcons.user,
                controller: _nameController,
                validator: (value) => _textEditValidator(value, 'Por favor, informe seu nome'),
                onSave: (value) => _user.name = value ?? '',
              ),
              // email
              TebTextEdit(
                labelText: 'Email',
                prefixIcon: FontAwesomeIcons.envelope,
                controller: _emailController,
                validator: (value) => _textEditValidator(value, 'Por favor, informe seu e-mail'),
                onSave: (value) => _user.email = value ?? '',
              ),
              if (_user.id.isNotEmpty)
                const TebText(
                  'Se não for alterar sua senha, deixe estes campos em branco',
                  padding: EdgeInsets.only(top: 10, bottom: 5),
                ),
              if (_user.id.isNotEmpty)
                // senha atual
                TebTextEdit(
                  labelText: 'Senha atual',
                  controller: _actualPasswordController,
                  prefixIcon: FontAwesomeIcons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (_user.id.isNotEmpty && _user.password != TebUtil.encrypt(value ?? '')) {
                      return 'Senha atual inválida';
                    }
                    return null;
                  },
                ),
              // nova senha
              TebTextEdit(
                labelText: 'Nova Senha',
                prefixIcon: FontAwesomeIcons.lock,
                isPassword: true,
                controller: _passwordController,
                onSave: (value) => _user.setPassword(value ?? ''),
                validator: (value) {
                  final finalValue = value ?? '';
                  if (_actualPasswordController.text.isNotEmpty) {
                    if (finalValue.trim().isEmpty) return 'Informe a senha';
                  }

                  // em uma edição a checagem só deve ser feita se houve edição
                  if (finalValue.trim().isNotEmpty && _passwordConfirmController.text.isNotEmpty) {
                    if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                    if (finalValue != _passwordConfirmController.text) return 'As senhas digitadas não são iguais';
                  }

                  return null;
                },
              ),
              // confirmar senha
              TebTextEdit(
                labelText: 'Confirme sua nova senha',
                prefixIcon: FontAwesomeIcons.lock,
                isPassword: true,
                controller: _passwordConfirmController,
                validator: (value) {
                  final finalValue = value ?? '';
                  if (_actualPasswordController.text.isNotEmpty) {
                    if (finalValue.trim().isEmpty) return 'Confirme a senha';
                  }
                  if (finalValue.trim().isNotEmpty && _passwordController.text.isNotEmpty) {
                    if (finalValue.trim().length < 6) return 'Senha deve possuir 6 ou mais caracteres';
                    if (finalValue != _passwordController.text) return 'As senhas digitadas não são iguais';
                  }
                  return null;
                },
              ),
              if (_wallet.ownerUserId == _user.id)
                const TebText(
                  'Sua carteira',
                  textSize: 20,
                  padding: EdgeInsets.only(top: 20, bottom: 10),
                ),
              if (_wallet.ownerUserId == _user.id)
                // código carteira
                TebTextEdit(
                  labelText: 'Código de convite',
                  prefixIcon: FontAwesomeIcons.at,
                  controller: _walletInvitationCodeController,
                  validator: (value) => _textEditValidator(value, 'Por favor, o código de convite é obrigatório'),
                  onSave: (value) => _wallet.invitationCode = value ?? '',
                ),
              if (_wallet.ownerUserId == _user.id)
                // nome carteira
                TebTextEdit(
                  labelText: 'Nome da carteira',
                  prefixIcon: FontAwesomeIcons.wallet,
                  controller: _walletNameController,
                  validator: (value) => _textEditValidator(value, 'Por favor, informe o nome de sua carteira'),
                  onSave: (value) => _wallet.name = value ?? '',
                ),
              // opções
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
              const Spacer(),
              if (_user.id.isNotEmpty)
                // deletar todos os dados
                TebButton(
                  size: Size(MediaQuery.of(context).size.width * 0.95, 45),
                  buttonType: TebButtonType.outlinedButton,
                  label: 'Excluir todos os meus dados',
                  padding: const EdgeInsets.only(bottom: 10),
                  onPressed: () {
                    TebCustomDialog(context: context)
                        .confirmationDialog(
                            backgroundColor: Theme.of(context).buttonTheme.colorScheme!.inversePrimary,
                            message: "Tem certeza que deseja excluir todos os seu dados? Este processo não pode ser revertido.",
                            noButtonText: "Melhor não",
                            yesButtonText: "Eu desejo apagar tudo",
                            yesButtonHighlightColor: Theme.of(context).buttonTheme.colorScheme!.inversePrimary)
                        .then((value) {
                      if (value == true) {
                        UserController().deleteAllData(user: _user);
                        Navigator.of(context).popAndPushNamed(Routes.landingScreen);
                        return;
                      }

                      TebCustomMessage.sucess(context, message: 'Exclusão cancelada');
                    });
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}
