import 'package:cashtrack/core/local_data_controller.dart';
import 'package:cashtrack/core/routes.dart';
import 'package:cashtrack/core/visualizations/landing_screen.dart';
import 'package:cashtrack/core/visualizations/main_screen.dart';
import 'package:cashtrack/core/visualizations/screen_not_found.dart';
import 'package:cashtrack/features/transaction_groups/visualizations/transaction_group_form.dart';
import 'package:cashtrack/features/transaction_groups/visualizations/transaction_group_screen.dart';
import 'package:cashtrack/features/transaction_types/visualizations/transaction_type_form.dart';
import 'package:cashtrack/features/transaction_types/visualizations/transaction_type_screen.dart';
import 'package:cashtrack/features/transactions/visualizations/transaction_form.dart';
import 'package:cashtrack/features/users/visualizations/user_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter/material.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_localizations/flutter_localizations.dart';

// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:teb_package/teb_package.dart';
import 'firebase_options.dart';

class XDPathUrlStrategy extends HashUrlStrategy {
  // Creates an instance of [PathUrlStrategy].
  // The [PlatformLocation] parameter is useful for testing to mock out browser interactions.
  XDPathUrlStrategy([
    super.platformLocation,
  ]) : _basePath = stripTrailingSlash(extractPathname(checkBaseHref(
          platformLocation.getBaseHref(),
        )));

  final String _basePath;

  @override
  String prepareExternalUrl(String internalUrl) {
    if (internalUrl.isNotEmpty && !internalUrl.startsWith('/')) {
      internalUrl = '/$internalUrl';
    }
    return '$_basePath/';
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //setUrlStrategy(XDPathUrlStrategy());

  var tebThemeController = TebThemeController(
    lightThemeAssetPath: 'assets/theme/light_theme.json',
    darkThemeAssetPath: 'assets/theme/dark_theme.json',
    useMaterial3: false,
    useDebugLog: true,
    fireStoreInstance: FirebaseFirestore.instance,
  );

  await tebThemeController.loadThemeData;

  var localThemeMode = await LocalDataController().getLocalThemeMode();

  runApp(CashTrack(
    darkThemeData: tebThemeController.darkThemeData,
    lightThemeData: tebThemeController.lightThemeData,
    localThemeMode: localThemeMode,
  ));
}

class CashTrack extends StatefulWidget {
  final ThemeData darkThemeData;
  final ThemeData lightThemeData;
  final ThemeMode? localThemeMode;
  const CashTrack({
    Key? key,
    required this.darkThemeData,
    required this.lightThemeData,
    this.localThemeMode,
  }) : super(key: key);

  @override
  State<CashTrack> createState() => _CashTrackState();

  // ignore: library_private_types_in_public_api
  static _CashTrackState? of(BuildContext context) => context.findAncestorStateOfType<_CashTrackState>();
}

class _CashTrackState extends State<CashTrack> {
  late ThemeMode _themeMode;
  @override
  void initState() {
    super.initState();
    _themeMode = widget.localThemeMode ?? ThemeMode.light;
  }

  void changeTheme({ThemeMode? localThemeMode}) {
    if (localThemeMode != null) {
      //LocalDataController().saveUserThemeMode(userThemeMode: UserThemeMode(themeName: localThemeMode.name));
      setState(() => _themeMode = localThemeMode);
      return;
    }

    if (_themeMode == ThemeMode.dark) {
      //LocalDataController().saveUserThemeMode(userThemeMode: UserThemeMode(themeName: ThemeMode.light.name));
      setState(() => _themeMode = ThemeMode.light);
    } else {
      //LocalDataController().saveUserThemeMode(userThemeMode: UserThemeMode(themeName: ThemeMode.dark.name));
      setState(() => _themeMode = ThemeMode.dark);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: widget.darkThemeData,
      theme: widget.lightThemeData,
      themeMode: _themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('pt-br', ''),
      ],
      title: 'Cash Track',
      routes: {
        Routes.landingScreen: (ctx) => const LandingScreen(),
        Routes.userForm: (ctx) => const UserForm(),
        Routes.mainScreen: (ctx) => const MainScreen(),
        Routes.transactionTypeScreen: (ctx) => const TransactionTypeScreen(),
        Routes.transactionTypeForm: (ctx) => const TransactionTypeForm(),
        Routes.transactionGroupScreen: (ctx) => const TransactionGroupScreen(),
        Routes.transactionGroupForm: (ctx) => const TransactionGroupForm(),
        Routes.transactionForm: (ctx) => const TransactionForm(),
      },
      initialRoute: Routes.landingScreen,
      // Executado quando uma tela não é encontrada
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) {
          return ScreenNotFound(settings.name.toString());
        });
      },
    );
  }
}