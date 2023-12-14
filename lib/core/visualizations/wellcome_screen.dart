// ignore_for_file: use_build_context_synchronously

// ignore: depend_on_referenced_packages
import 'package:cashtrack/core/routes.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:cashtrack/features/users/user_controller.dart';
import 'package:cashtrack/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_package/teb_package.dart';

class WellcomeScreen extends StatefulWidget {
  const WellcomeScreen({super.key});

  @override
  State<WellcomeScreen> createState() => _WellcomeScreenState();
}

class _WellcomeScreenState extends State<WellcomeScreen> {
  var _info = TebUtil.packageInfo;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var _initializing = true;
  final _userLogin = User();

  void _login() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;

    var userController = UserController();
    var returnStatus = TebCustomReturn.sucess;

    // salva os dados nas variáveis
    _formKey.currentState?.save();

    returnStatus = await userController.login(user: _userLogin);

    if (returnStatus.returnType == TebReturnType.error) {
      TebCustomMessage(context: context, messageText: returnStatus.message, messageType: TebMessageType.error);
      return;
    }

    Navigator.of(context).pushNamed(
      Routes.mainScreen,
      arguments: {'user': userController.currentUser, 'wallet': userController.userWallet},
    );
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
      TebUtil.version.then((info) => setState(() => _info = info));
      _initializing = false;
    }

    var size = MediaQuery.of(context).size;

    return TebCustomScaffold(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const TebText('Cash Track'),
          const SizedBox(width: 10),
          TebText(
            'v${_info.version}-${_info.buildNumber}',
            textSize: Theme.of(context).textTheme.labelMedium!.fontSize,
          )
        ],
      ),
      appBarActions: [
        IconButton(
          onPressed: () => CashTrack.of(context)?.changeTheme(),
          icon: const Icon(Icons.light_mode_outlined),
        ),
      ],
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: kIsWeb
                ? size.width <= 750
                    ? size.width
                    : size.width * (size.width <= 1000 ? 0.6 : 0.4)
                : size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.moneyBill,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      TebText(
                        'CashTrack',
                        style: Theme.of(context).textTheme.headlineLarge,
                        padding: const EdgeInsets.only(left: 10),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.05),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TebTextEdit(
                        labelText: 'E-mail',
                        prefixIcon: FontAwesomeIcons.user,
                        width: size.width * 0.75,
                        controller: _emailController,
                        onSave: (value) => _userLogin.email = value ?? '',
                        validator: (value) => _textEditValidator(value, 'Informe seu e-mail'),
                      ),
                      TebTextEdit(
                        labelText: 'Senha',
                        prefixIcon: FontAwesomeIcons.lock,
                        width: size.width * 0.75,
                        controller: _passwordController,
                        isPassword: true,
                        onSave: (value) => _userLogin.password = value ?? '',
                        //validator: (value) => _textEditValidator(value, 'Informe a senha'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(height: 50, width: size.width * 0.75),
                          child: ElevatedButton(
                            onPressed: () => _login(),
                            child: const TebText('Entrar', textSize: 20, textWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tightFor(height: 50, width: size.width * 0.75),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamed(Routes.userForm),
                        child: const TebText('Acessar uma carteira', textSize: 20, textWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints.tightFor(height: 50, width: size.width * 0.75),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamed(Routes.userForm),
                        child: const TebText('Criar uma conta', textSize: 20, textWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      //bottomNavigationBar: const BottonInfo(),
    );
  }
}
