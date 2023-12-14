import 'package:cashtrack/core/consts.dart';
import 'package:cashtrack/core/local_data_controller.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:cashtrack/features/wallet/wallet.dart';
import 'package:cashtrack/features/wallet/wallet_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:teb_package/teb_package.dart';

class UserController {
  final _userCollectionName = 'user';

  late User _currentUser = User();
  late Wallet _userWallet = Wallet();

  User get currentUser => _currentUser;
  Wallet get userWallet => _userWallet;

  Future<TebCustomReturn> login({required User user}) async {
    try {
      user.password = TebUtil.encrypt(user.password);
      final credential = await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      if (credential.user != null) {
        _currentUser = await getUserbyEmail(email: user.email);
        _currentUser.token = await credential.user!.getIdToken() ?? '';

        _userWallet = await WalletController(user: _currentUser).getWalletById(_currentUser.walletId);

        LocalDataController().saveUser(user: _currentUser);
        LocalDataController().saveWallet(wallet: _userWallet);
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      return TebCustomReturn.authSignUpError(e.code);
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }

    return TebCustomReturn.sucess;
  }

  void logoff() {
    _currentUser = User();
    clearCurrentUser();
  }

  Future<User> getUserbyEmail({required String email, String setToken = ''}) async {
    var userQuery = FirebaseFirestore.instance.collection(_userCollectionName).where("email", isEqualTo: email);

    final users = await userQuery.get();
    final dataList = users.docs.map((doc) => doc.data()).toList();

    if (dataList.isEmpty) {
      return User();
    } else {
      return User.fromMap(map: dataList.first);
    }
  }

  Future<User> getUserData({required String userId, String setEmail = '', String setToken = ''}) async {
    final userDataRef = await FirebaseFirestore.instance.collection(_userCollectionName).doc(userId).get();
    final userData = userDataRef.data();

    if (userData == null) {
      return User();
    }

    return User.fromMap(map: userData, setEmail: setEmail, setToken: setToken);
  }

  Future<TebCustomReturn> save({required User user, Wallet? wallet}) async {
    try {
      var newUser = false;

      if (user.id.isEmpty) {
        final credential = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user.email,
          password: TebUtil.encrypt(user.password),
        );
        if (credential.user == null) return TebCustomReturn.error('Erro ao criar usuário');

        if (fb_auth.FirebaseAuth.instance.currentUser != null) {
          fb_auth.FirebaseAuth.instance.currentUser!.updateDisplayName(user.name);
        }

        newUser = true;
        user.id = credential.user!.uid;
      }

      if (user.isPasswordChanged) {
        if (fb_auth.FirebaseAuth.instance.currentUser != null) {
          fb_auth.FirebaseAuth.instance.currentUser!.updatePassword(user.password);
        }
      }

      if (fb_auth.FirebaseAuth.instance.currentUser != null) {
        if (user.email != fb_auth.FirebaseAuth.instance.currentUser!.email) {
          fb_auth.FirebaseAuth.instance.currentUser!.updateEmail(user.email);
        }

        if (user.name != fb_auth.FirebaseAuth.instance.currentUser!.displayName) {
          fb_auth.FirebaseAuth.instance.currentUser!.updateEmail(user.name);
        }
      }

      if (wallet != null) {
        if (wallet.id.isEmpty && newUser) {
          wallet.id = TebUidGenerator.firestoreUid;
          wallet.ownerUserId = user.id;
          user.walletId = wallet.id;
        }
        WalletController(user: user).save(wallet: wallet);
      }

      await FirebaseFirestore.instance.collection(FirebaseDataseConsts.userCollectionName).doc(user.id).set(user.toMap);

      _currentUser = User.fromMap(map: user.toMap);
      LocalDataController().saveUser(user: _currentUser);

      return TebCustomReturn.sucess;
    } on fb_auth.FirebaseException catch (e) {
      return TebCustomReturn.authSignUpError(e.code);
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  void clearCurrentUser() {
    LocalDataController().clearUserData();
    _currentUser = User();
  }

  void deleteAllData({required User user}) async {
    await WalletController(user: user).deleteAllWalletData(user.walletId);
    clearCurrentUser();
    LocalDataController().clearWalletData();
  }
}
