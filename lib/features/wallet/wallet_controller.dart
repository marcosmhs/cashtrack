import 'package:cashtrack/core/consts.dart';
import 'package:cashtrack/features/users/user.dart';
import 'package:cashtrack/features/wallet/wallet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teb_package/teb_package.dart';

class WalletController {
  final User user;

  WalletController({required this.user});

  Future<TebCustomReturn> save({required Wallet wallet}) async {
    try {
      if (wallet.id.isEmpty) wallet.id = TebUidGenerator.firestoreUid;

      await FirebaseFirestore.instance.collection(FirebaseDataseConsts.walletCollectionName).doc(wallet.id).set(wallet.toMap);
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<Wallet> getWalletById(String walletId) async {
    final dataRef = await FirebaseFirestore.instance.collection(FirebaseDataseConsts.walletCollectionName).doc(walletId).get();
    final data = dataRef.data();

    if (data == null) return Wallet();

    return Wallet.fromMap(data);
  }

  Future<TebCustomReturn> deleteAllWalletData(String walletId) async {
    try {
      await FirebaseFirestore.instance.collection(FirebaseDataseConsts.walletCollectionName).doc(walletId).delete();
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
