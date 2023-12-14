import 'package:cashtrack/core/consts.dart';
import 'package:cashtrack/core/shared/cashtrack_controller.dart';
import 'package:cashtrack/features/transaction_groups/transaction_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fb;
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

class TransactionGroupController extends CashTrackController {
  TransactionGroupController({required super.user}) {
    setCollectionName(FirebaseDataseConsts.transactionGroupCollectionName);
  }

  Future<TebCustomReturn> save({required TransactionGroup transactionGroup}) async {
    try {
      if (transactionGroup.id.isEmpty) {
        transactionGroup.id = TebUidGenerator.firestoreUid;
        transactionGroup.walletId = user.walletId;
      }
      await fb.FirebaseFirestore.instance
          .collection(FirebaseDataseConsts.walletCollectionName)
          .doc(transactionGroup.walletId)
          .collection(FirebaseDataseConsts.transactionGroupCollectionName)
          .doc(transactionGroup.id)
          .set(transactionGroup.toMap);
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TebCustomReturn> delete({required TransactionGroup transactionGroup}) async {
    try {
      await fb.FirebaseFirestore.instance
          .collection(FirebaseDataseConsts.walletCollectionName)
          .doc(transactionGroup.walletId)
          .collection(FirebaseDataseConsts.transactionGroupCollectionName)
          .doc(transactionGroup.id)
          .delete();
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<List<TransactionGroup>> get getList async {
    try {
      var query = fb.FirebaseFirestore.instance
          .collection(FirebaseDataseConsts.walletCollectionName)
          .doc(user.walletId)
          .collection(FirebaseDataseConsts.transactionGroupCollectionName);

      final list = await query.get();
      final dataList = list.docs.map((doc) => doc.data()).toList();

      final List<TransactionGroup> r = [];
      for (var transactionGroup in dataList) {
        r.add(TransactionGroup.fromMap(transactionGroup));
      }
      return r;
    } catch (e) {
      return [];
    }
  }
}
