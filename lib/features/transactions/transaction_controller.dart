import 'package:cashtrack/core/consts.dart';
import 'package:cashtrack/core/shared/cashtrack_controller.dart';
import 'package:cashtrack/features/transactions/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fb;
import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_uid_generator.dart';

// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class TransactionController extends CashTrackController {
  TransactionController({required super.user}) {
    setCollectionName(FirebaseDataseConsts.transactionCollectionName);
  }

  List<String> getGroupList(List<Transaction> transactionlist) {
    transactionlist.sort((a, b) => a.transactionGroupName.compareTo(b.transactionGroupName));
    var transactionGroups = groupBy(transactionlist, (t) => t.transactionGroupName);
    return transactionGroups.keys.toList();
  }

  double getGroupTotalValue(List<Transaction> transactionList, String transactionGroupName) {
    double sum = 0;
    for (var t in transactionList.where((t) => t.transactionGroupName == transactionGroupName).toList()) {
      sum += t.value;
    }
    return sum;
  }

  Future<TebCustomReturn> save({required Transaction transaction}) async {
    try {
      if (transaction.id.isEmpty) {
        transaction.id = TebUidGenerator.firestoreUid;
        transaction.userId = user.id;
        transaction.walletId = user.walletId;
      }

      await fb.FirebaseFirestore.instance
          .collection(FirebaseDataseConsts.walletCollectionName)
          .doc(transaction.walletId)
          .collection(FirebaseDataseConsts.transactionCollectionName)
          .doc(transaction.id)
          .set(transaction.toMap);

      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }

  Future<TebCustomReturn> delete({required Transaction transaction}) async {
    try {
      await fb.FirebaseFirestore.instance
          .collection(FirebaseDataseConsts.walletCollectionName)
          .doc(transaction.walletId)
          .collection(FirebaseDataseConsts.transactionCollectionName)
          .doc(transaction.id)
          .delete();
      return TebCustomReturn.sucess;
    } catch (e) {
      return TebCustomReturn.error(e.toString());
    }
  }
}
