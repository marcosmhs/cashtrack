import 'package:cashtrack/features/users/user.dart';
import 'package:cashtrack/features/wallet/wallet.dart';
import 'package:flutter/material.dart';

import 'package:teb_package/teb_package.dart';

class LocalDataController with ChangeNotifier {
  var _user = User();
  var _wallet = Wallet();

  User get localUser => User.fromMap(map: _user.toMap);
  Wallet get localWallet => Wallet.fromMap(_wallet.toMap);

  Future<ThemeMode> getLocalThemeMode() async {
    var userThemeData = await TebLocalStorage.readString(key: 'userThemeMode');

    if (userThemeData.isEmpty) {
      return ThemeMode.dark;
    } else {
      if (userThemeData == ThemeMode.dark.name) {
        return ThemeMode.dark;
      } else {
        return ThemeMode.light;
      }
    }
  }

  Future<void> chechLocalData() async {
    try {
      // user data
      var userMap = await TebLocalStorage.readMap(key: 'user');
      var walletMap = await TebLocalStorage.readMap(key: 'wallet');

      if (userMap.isEmpty) return;

      _user = User.fromMap(map: userMap);
      _wallet = Wallet.fromMap(walletMap);

      //se a data de criação do usuário + 5 dias é menor que a data atual significa que ele foi
      //criado a mais de 5 dias, ou seja,  ele não deve mais existi
    } catch (e) {
      clearUserData();
      clearWalletData();
    }
  }

  void saveUser({required User user}) async {
    clearUserData();
    TebLocalStorage.saveMap(key: 'user', map: user.toMap);
  }

  void saveWallet({required Wallet wallet}) async {
    clearWalletData();
    TebLocalStorage.saveMap(key: 'wallet', map: wallet.toMap);
  }

  void clearUserData() => TebLocalStorage.removeValue(key: 'user');
  void clearWalletData() => TebLocalStorage.removeValue(key: 'wallet');

  //void saveUserThemeMode({required UserThemeMode userThemeMode}) async {
  //  TebLocalStorage.saveString(key: 'userThemeMode', value: userThemeMode.themeName);
  //}
}
