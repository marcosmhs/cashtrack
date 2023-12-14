import 'package:cashtrack/core/consts.dart';
import 'package:cashtrack/core/shared/cashtrack_controller.dart';
import 'package:cashtrack/features/transaction_types/transaction_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fb;
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class TransactionTypeController extends CashTrackController {
  TransactionTypeController({required super.user}) {
    super.setCollectionName(FirebaseDataseConsts.transactionTypeCollectionName);
  }

  Future<TebCustomReturn> save({required TransactionType transactionType}) async {
    try {
      if (transactionType.id.isEmpty) {
        transactionType.id = TebUidGenerator.firestoreUid;
      }
      transactionType.walletId = user.walletId;
      await fb.FirebaseFirestore.instance
          .collection(FirebaseDataseConsts.walletCollectionName)
          .doc(transactionType.walletId)
          .collection(FirebaseDataseConsts.transactionTypeCollectionName)
          .doc(transactionType.id)
          .set(transactionType.toMap);

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TebCustomReturn> delete({required TransactionType transactionType}) async {
    try {
      await fb.FirebaseFirestore.instance
          .collection(FirebaseDataseConsts.walletCollectionName)
          .doc(transactionType.walletId)
          .collection(FirebaseDataseConsts.transactionTypeCollectionName)
          .doc(transactionType.id)
          .delete();
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TransactionType> getTransactionTypeById(String transactionId) async {
    var query = await fb.FirebaseFirestore.instance
        .collection(FirebaseDataseConsts.walletCollectionName)
        .doc(user.walletId)
        .collection(FirebaseDataseConsts.transactionTypeCollectionName)
        .where("id", isEqualTo: transactionId)
        .get();

    var dataList = query.docs.map((doc) => doc.data()).toList();

    return dataList.isEmpty ? TransactionType() : TransactionType.fromMap(dataList.first);
  }

  Future<List<TransactionType>> get getList async {
    try {
      var query = fb.FirebaseFirestore.instance
          .collection(FirebaseDataseConsts.walletCollectionName)
          .doc(user.walletId)
          .collection(FirebaseDataseConsts.transactionTypeCollectionName);

      final list = await query.get();
      final dataList = list.docs.map((doc) => doc.data()).toList();

      final List<TransactionType> r = [];
      for (var item in dataList) {
        r.add(TransactionType.fromMap(item));
      }
      return r;
    } catch (e) {
      return [];
    }
  }
}
