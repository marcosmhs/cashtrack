// ignore_for_file: use_build_context_synchronously
import 'package:cashtrack/core/local_data_controller.dart';
import 'package:cashtrack/core/visualizations/wellcome_screen.dart';
import 'package:cashtrack/core/visualizations/main_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import 'package:teb_package/screen_elements/teb_custom_scaffold.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  var _initializing = true;
  var analytics = FirebaseAnalytics.instance;

  Widget _errorScreen({required String errorMessage}) {
    return TebCustomScaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Fatal error!'),
            const SizedBox(height: 20),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      analytics.logEvent(name: 'landing_entering');
      _initializing = false;
    }

    var localDataController = LocalDataController();

    //localDataController.clearUserData();
    //localDataController.clearWalletData();

    return FutureBuilder(
      future: localDataController.chechLocalData(),
      builder: (ctx, snapshot) {
        // enquanto está carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
          // em caso de erro
        } else {
          if (snapshot.error != null) {
            localDataController.clearUserData();
            analytics.logEvent(name: 'landing_error');
            return _errorScreen(errorMessage: snapshot.error.toString());
            // ao final do processo
          } else {
            // irá avaliar se o usuário possui login ou não
            return localDataController.localUser.id.isEmpty
                ? const WellcomeScreen()
                : MainScreen(
                    user: localDataController.localUser,
                    wallet: localDataController.localWallet,
                  );
          }
        }
      },
    );
  }
}
